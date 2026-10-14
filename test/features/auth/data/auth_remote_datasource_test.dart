import 'package:campus_hub/core/error/exceptions.dart';
import 'package:campus_hub/features/auth/data/datasources/account_data_cleaner.dart';
import 'package:campus_hub/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:campus_hub/features/auth/data/models/user_model.dart';
import 'package:campus_hub/features/auth/domain/entities/user_role.dart';
import 'package:campus_hub/features/notifications/data/notification_writer.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/firestore_fixtures.dart';
import '../../../helpers/tracking_user.dart';

void main() {
  late FakeFirebaseFirestore db;
  late Fixtures fx;
  late TrackingUser user;

  setUp(() {
    db = FakeFirebaseFirestore();
    fx = Fixtures(db);
    user = TrackingUser(uid: 'student', email: 'student@campus.edu');
  });

  AuthRemoteDataSourceImpl dataSource(MockFirebaseAuth auth) {
    return AuthRemoteDataSourceImpl(
      firebaseAuth: auth,
      firestore: db,
      accountDataCleaner: AccountDataCleaner(
        firestore: db,
        notificationWriter: NotificationWriter(db),
      ),
    );
  }

  Matcher authError(String message) => throwsA(
    isA<AuthException>().having((e) => e.message, 'message', message),
  );

  group('deleteAccount', () {
    test('deletes the data, the profile and the sign-in', () async {
      final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
      await fx.addUser('student');
      await fx.addComplaint('c1', studentId: 'student');
      await fx.addNotification('n1', recipientId: 'student');

      await dataSource(auth).deleteAccount(password: 'secret');

      expect(await fx.data('users', 'student'), isNull);
      expect(await fx.data('deleted_accounts', 'student'), isNotNull);
      expect(await fx.data('notifications', 'n1'), isNull);
      expect(
        (await fx.data('complaints', 'c1'))!['studentName'],
        AccountDataCleaner.deletedUserName,
      );
      expect(user.deleteCalls, 1);
    });

    test('a wrong password changes nothing', () async {
      final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
      await fx.addUser('student');
      user.reauthenticateError = FirebaseAuthException(
        code: 'invalid-credential',
      );

      await expectLater(
        dataSource(auth).deleteAccount(password: 'wrong'),
        authError('Incorrect password. Please try again.'),
      );
      expect(await fx.data('users', 'student'), isNotNull);
      expect(await fx.data('deleted_accounts', 'student'), isNull);
      expect(user.deleteCalls, 0);
    });

    test('is refused while the user still coordinates venues', () async {
      final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
      await fx.addUser('student', role: UserRole.venueCoordinator);
      await fx.addVenue('hall', coordinatorId: 'student');

      await expectLater(
        dataSource(auth).deleteAccount(password: 'secret'),
        throwsA(isA<ServerException>()),
      );
      expect(await fx.data('users', 'student'), isNotNull);
      expect(user.deleteCalls, 0);
    });

    test('signs out with guidance if the sign-in cannot be removed', () async {
      final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
      await fx.addUser('student');
      user.deleteError = FirebaseAuthException(code: 'network-request-failed');

      await expectLater(
        dataSource(auth).deleteAccount(password: 'secret'),
        throwsA(
          isA<SignedOutException>().having(
            (e) => e.message,
            'message',
            contains('Sign in once more'),
          ),
        ),
      );
      expect(await fx.data('deleted_accounts', 'student'), isNotNull);
      expect(auth.currentUser, isNull);
    });

    test('requires a signed-in user', () async {
      await expectLater(
        dataSource(MockFirebaseAuth()).deleteAccount(password: 'secret'),
        authError('Your session has expired. Please sign in again.'),
      );
    });
  });

  group('login', () {
    test(
      'finishes an admin deletion by removing the leftover sign-in',
      () async {
        final auth = MockFirebaseAuth(mockUser: user);
        await db.collection('deleted_accounts').doc('student').set({
          'uid': 'student',
          'deletedBy': 'admin',
          'deletedAt': DateTime(2026, 1, 1),
        });

        await expectLater(
          dataSource(
            auth,
          ).login(email: 'student@campus.edu', password: 'secret'),
          authError('This account has been deleted.'),
        );
        expect(user.deleteCalls, 1);
      },
    );

    test(
      'a missing profile without a tombstone keeps the old behaviour',
      () async {
        final auth = MockFirebaseAuth(mockUser: user);

        await expectLater(
          dataSource(
            auth,
          ).login(email: 'student@campus.edu', password: 'secret'),
          authError('User profile not found. Contact admin.'),
        );
        expect(user.deleteCalls, 0);
        expect(auth.currentUser, isNull);
      },
    );

    test('returns the profile for an active account', () async {
      final auth = MockFirebaseAuth(mockUser: user);
      await fx.addUser('student');

      final result = await dataSource(
        auth,
      ).login(email: 'student@campus.edu', password: 'secret');
      expect(result.uid, 'student');
    });
  });

  group('authStateChanges', () {
    Matcher userWith(String uid, UserRole role) => isA<UserModel>()
        .having((u) => u.uid, 'uid', uid)
        .having((u) => u.role, 'role', role);

    test('emits the profile and follows role changes live', () async {
      final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
      await fx.addUser('student');
      final stream = dataSource(auth).authStateChanges;

      final expectation = expectLater(
        stream,
        emitsInOrder([
          userWith('student', UserRole.student),
          userWith('student', UserRole.admin),
        ]),
      );
      await Future<void>.delayed(Duration.zero);
      await db.collection('users').doc('student').update({'role': 'admin'});
      await expectation;
    });

    test('signs out a session whose account gets deactivated', () async {
      final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
      await fx.addUser('student');
      final stream = dataSource(auth).authStateChanges;

      final expectation = expectLater(
        stream,
        emitsInOrder([userWith('student', UserRole.student), isNull]),
      );
      await Future<void>.delayed(Duration.zero);
      await db.collection('users').doc('student').update({'isActive': false});
      await expectation;
      expect(auth.currentUser, isNull);
    });

    test('signs out a session whose account gets deleted', () async {
      final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
      await fx.addUser('student');
      final stream = dataSource(auth).authStateChanges;

      final expectation = expectLater(
        stream,
        emitsInOrder([userWith('student', UserRole.student), isNull]),
      );
      await Future<void>.delayed(Duration.zero);
      await db.collection('users').doc('student').delete();
      await expectation;
      await Future<void>.delayed(Duration.zero);
      expect(auth.currentUser, isNull);
    });

    test(
      'waits for a profile that is still being written (registration)',
      () async {
        final auth = MockFirebaseAuth(signedIn: true, mockUser: user);
        final stream = dataSource(auth).authStateChanges;

        final expectation = expectLater(
          stream,
          emitsInOrder([isNull, userWith('student', UserRole.student)]),
        );
        await Future<void>.delayed(Duration.zero);
        await fx.addUser('student');
        await expectation;
        expect(auth.currentUser, isNotNull);
      },
    );
  });
}
