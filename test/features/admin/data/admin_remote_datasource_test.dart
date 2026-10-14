import 'package:campus_hub/core/error/exceptions.dart';
import 'package:campus_hub/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:campus_hub/features/auth/data/datasources/account_data_cleaner.dart';
import 'package:campus_hub/features/auth/domain/entities/user_role.dart';
import 'package:campus_hub/features/notifications/data/notification_writer.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/firestore_fixtures.dart';

void main() {
  late FakeFirebaseFirestore db;
  late Fixtures fx;

  setUp(() async {
    db = FakeFirebaseFirestore();
    fx = Fixtures(db);
    await fx.addUser('admin', role: UserRole.admin);
    await fx.addUser('student');
  });

  AdminRemoteDataSourceImpl signedInAs(String uid) {
    return AdminRemoteDataSourceImpl(
      firestore: db,
      firebaseAuth: MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: uid, email: '$uid@campus.edu'),
      ),
      accountDataCleaner: AccountDataCleaner(
        firestore: db,
        notificationWriter: NotificationWriter(db),
      ),
    );
  }

  Matcher serverError(Object message) => throwsA(
    isA<ServerException>().having((e) => e.message, 'message', message),
  );

  test("an admin deletes another user's account and data", () async {
    await fx.addNotification('n1', recipientId: 'student');

    await signedInAs('admin').deleteUserAccount('student');

    expect(await fx.data('users', 'student'), isNull);
    expect(await fx.data('notifications', 'n1'), isNull);
    expect(
      (await fx.data('deleted_accounts', 'student'))!['deletedBy'],
      'admin',
    );
  });

  test('non-admins cannot delete accounts', () async {
    await fx.addUser('other');

    await expectLater(
      signedInAs('other').deleteUserAccount('student'),
      serverError("Only administrators can delete other users' accounts."),
    );
    expect(await fx.data('users', 'student'), isNotNull);
  });

  test('a deactivated admin cannot delete accounts', () async {
    await fx.addUser('former', role: UserRole.admin, isActive: false);

    await expectLater(
      signedInAs('former').deleteUserAccount('student'),
      serverError("Only administrators can delete other users' accounts."),
    );
    expect(await fx.data('users', 'student'), isNotNull);
  });

  test('admins use the self-service flow for their own account', () async {
    await expectLater(
      signedInAs('admin').deleteUserAccount('admin'),
      serverError(contains('My Account')),
    );
    expect(await fx.data('users', 'admin'), isNotNull);
  });

  test('reports an account that is already gone', () async {
    await expectLater(
      signedInAs('admin').deleteUserAccount('ghost'),
      serverError('This account has already been deleted.'),
    );
  });

  test('refuses to orphan venues', () async {
    await fx.addUser('coord', role: UserRole.venueCoordinator);
    await fx.addVenue('hall', coordinatorId: 'coord');

    await expectLater(
      signedInAs('admin').deleteUserAccount('coord'),
      serverError(contains('Manage Venues')),
    );
    expect(await fx.data('users', 'coord'), isNotNull);
  });
}
