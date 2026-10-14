import 'package:campus_hub/core/error/exceptions.dart';
import 'package:campus_hub/features/auth/data/datasources/account_data_cleaner.dart';
import 'package:campus_hub/features/auth/domain/entities/user_role.dart';
import 'package:campus_hub/features/notifications/data/notification_writer.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/firestore_fixtures.dart';

void main() {
  late FakeFirebaseFirestore db;
  late Fixtures fx;
  late AccountDataCleaner cleaner;

  setUp(() {
    db = FakeFirebaseFirestore();
    fx = Fixtures(db);
    cleaner = AccountDataCleaner(
      firestore: db,
      notificationWriter: NotificationWriter(db),
    );
  });

  group('purge', () {
    setUp(() async {
      await fx.addUser('student');
      await fx.addUser('other');
      await fx.addUser('coord', role: UserRole.venueCoordinator);
      await fx.addVenue('hall', coordinatorId: 'coord');
    });

    test('removes the profile and writes a tombstone', () async {
      await cleaner.purge(uid: 'student', deletedBy: 'admin');

      expect(await fx.data('users', 'student'), isNull);
      final tombstone = await fx.data('deleted_accounts', 'student');
      expect(tombstone, isNotNull);
      expect(tombstone!['uid'], 'student');
      expect(tombstone['deletedBy'], 'admin');
      expect(
        tombstone.keys,
        unorderedEquals(['uid', 'deletedBy', 'deletedAt']),
      );
      expect(await cleaner.isDeleted('student'), isTrue);
      expect(await cleaner.isDeleted('other'), isFalse);
    });

    test("deletes the user's notifications and suggestions only", () async {
      await fx.addNotification('n1', recipientId: 'student');
      await fx.addNotification('n2', recipientId: 'other');
      await fx.addSuggestion('s1', authorId: 'student');
      await fx.addSuggestion('s2', authorId: 'other');

      await cleaner.purge(uid: 'student', deletedBy: 'student');

      expect(await fx.data('notifications', 'n1'), isNull);
      expect(await fx.data('notifications', 'n2'), isNotNull);
      expect(await fx.data('suggestions', 's1'), isNull);
      expect(await fx.data('suggestions', 's2'), isNotNull);
    });

    test("removes the user's votes but keeps everyone else's", () async {
      await fx.addSuggestion(
        's2',
        authorId: 'other',
        upvotedBy: ['student', 'coord'],
      );

      await cleaner.purge(uid: 'student', deletedBy: 'student');

      expect((await fx.data('suggestions', 's2'))!['upvotedBy'], ['coord']);
    });

    test('anonymises complaints but keeps them for staff', () async {
      await fx.addComplaint('c1', studentId: 'student');
      await fx.addComplaint('c2', studentId: 'other');

      await cleaner.purge(uid: 'student', deletedBy: 'student');

      final mine = await fx.data('complaints', 'c1');
      expect(mine, isNotNull);
      expect(mine!['studentName'], AccountDataCleaner.deletedUserName);
      expect(mine['title'], 'Broken projector');
      expect(mine['status'], 'pending_review');
      expect((await fx.data('complaints', 'c2'))!['studentName'], 'User other');
    });

    test(
      'cancels bookings that still hold a venue and anonymises all',
      () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        await fx.addBooking('pending', studentId: 'student');
        await fx.addBooking(
          'upcoming',
          studentId: 'student',
          status: 'approved',
        );
        await fx.addBooking(
          'past',
          studentId: 'student',
          status: 'approved',
          endDate: yesterday,
        );
        await fx.addBooking(
          'rejected',
          studentId: 'student',
          status: 'rejected',
        );
        await fx.addBooking('others', studentId: 'other');

        await cleaner.purge(uid: 'student', deletedBy: 'student');

        Future<Map<String, dynamic>> booking(String id) async =>
            (await fx.data('bookings', id))!;
        expect((await booking('pending'))['status'], 'cancelled');
        expect((await booking('upcoming'))['status'], 'cancelled');
        expect((await booking('past'))['status'], 'approved');
        expect((await booking('rejected'))['status'], 'rejected');
        for (final id in ['pending', 'upcoming', 'past', 'rejected']) {
          expect(
            (await booking(id))['studentName'],
            AccountDataCleaner.deletedUserName,
          );
        }
        expect((await booking('others'))['status'], 'pending');
        expect((await booking('others'))['studentName'], 'User other');
      },
    );

    test('tells the coordinator about bookings it cancelled', () async {
      await fx.addBooking('upcoming', studentId: 'student', status: 'approved');

      await cleaner.purge(uid: 'student', deletedBy: 'student');

      final notes = await db
          .collection('notifications')
          .where('recipientId', isEqualTo: 'coord')
          .get();
      expect(notes.docs, hasLength(1));
      expect(notes.docs.single['type'], 'booking_cancelled');
      expect(notes.docs.single['actionRoute'], '/approval/upcoming');
    });

    test(
      "hands a departing coordinator's pending requests to the venue's new coordinator",
      () async {
        await fx.addUser('coord2', role: UserRole.venueCoordinator);
        await fx.addVenue('lab', coordinatorId: 'coord2');
        await fx.addBooking(
          'stale',
          studentId: 'other',
          venueId: 'lab',
          coordinatorId: 'coord',
        );
        await fx.addBooking(
          'decided',
          studentId: 'other',
          venueId: 'lab',
          coordinatorId: 'coord',
          status: 'approved',
        );

        await cleaner.purge(uid: 'coord', deletedBy: 'admin');

        expect(
          (await fx.data('bookings', 'stale'))!['coordinatorId'],
          'coord2',
        );
        expect(
          (await fx.data('bookings', 'decided'))!['coordinatorId'],
          'coord',
        );
      },
    );

    test('can run again after a partial failure (idempotent)', () async {
      await fx.addComplaint('c1', studentId: 'student');
      await fx.addBooking('pending', studentId: 'student');

      await cleaner.purge(uid: 'student', deletedBy: 'student');
      await fx.addUser('student'); // as if the final step had not happened
      await cleaner.purge(uid: 'student', deletedBy: 'student');

      expect(await fx.data('users', 'student'), isNull);
      expect(
        (await fx.data('complaints', 'c1'))!['studentName'],
        AccountDataCleaner.deletedUserName,
      );
      expect((await fx.data('bookings', 'pending'))!['status'], 'cancelled');
    });
  });

  group('ensureDeletable', () {
    test('blocks a coordinator who still manages venues', () async {
      final coord = await fx.addUser('coord', role: UserRole.venueCoordinator);
      await fx.addVenue('hall', coordinatorId: 'coord');
      await fx.addVenue('lab', coordinatorId: 'coord');

      expect(
        () => cleaner.ensureDeletable(coord, isSelf: true),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains("You're the coordinator for 2 venues"),
          ),
        ),
      );
      expect(
        () => cleaner.ensureDeletable(coord, isSelf: false),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Manage Venues'),
          ),
        ),
      );
    });

    test('allows a coordinator with no venues', () async {
      final coord = await fx.addUser('coord', role: UserRole.venueCoordinator);
      await expectLater(
        cleaner.ensureDeletable(coord, isSelf: true),
        completes,
      );
    });

    test('blocks deleting the last active admin', () async {
      final admin = await fx.addUser('admin', role: UserRole.admin);
      await fx.addUser('retired', role: UserRole.admin, isActive: false);

      expect(
        () => cleaner.ensureDeletable(admin, isSelf: true),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('only active admin'),
          ),
        ),
      );
    });

    test(
      'allows deleting an admin while another active admin remains',
      () async {
        final admin = await fx.addUser('admin', role: UserRole.admin);
        await fx.addUser('admin2', role: UserRole.admin);
        await expectLater(
          cleaner.ensureDeletable(admin, isSelf: true),
          completes,
        );
      },
    );

    test('students are always deletable', () async {
      final student = await fx.addUser('student');
      await expectLater(
        cleaner.ensureDeletable(student, isSelf: false),
        completes,
      );
    });
  });
}
