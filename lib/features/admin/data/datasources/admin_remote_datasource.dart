import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/datasources/account_data_cleaner.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_role.dart';

abstract class AdminRemoteDataSource {
  Stream<List<UserModel>> getAllUsers();

  Future<UserModel> createUserAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  });

  Future<void> updateUserRole({
    required String uid,
    required UserRole role,
    String? department,
  });

  Future<void> updateUserActiveStatus({
    required String uid,
    required bool isActive,
  }); // NEW
  Future<void> sendPasswordReset(String email); // NEW

  /// Deletes another user's account and data. The caller must be an active
  /// admin; admins delete their own account through the self-service flow.
  Future<void> deleteUserAccount(String uid);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth; // NEW — needed for sendPasswordResetEmail
  final AccountDataCleaner accountDataCleaner;
  AdminRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.accountDataCleaner,
  });

  CollectionReference get _usersRef => firestore.collection('users');

  @override
  Stream<List<UserModel>> getAllUsers() {
    return _usersRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  @override
  Future<UserModel> createUserAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  }) async {
    FirebaseApp? tempApp;
    try {
      tempApp = await Firebase.initializeApp(
        name: 'admin_create_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      final credential = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final user = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: role,
        department: role == UserRole.departmentStaff ? department : null,
        createdAt: DateTime.now(),
      );

      await _usersRef.doc(uid).set(user.toJson());

      await tempAuth.signOut();
      return user;
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Failed to create account.');
    } catch (e) {
      throw ServerException('Failed to create account: ${e.toString()}');
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  @override
  Future<void> updateUserRole({
    required String uid,
    required UserRole role,
    String? department,
  }) async {
    try {
      await _usersRef.doc(uid).update({
        'role': role.value,
        'department': role == UserRole.departmentStaff ? department : null,
      });
    } catch (e) {
      throw const ServerException('Failed to update user.');
    }
  }

  @override
  Future<void> updateUserActiveStatus({
    required String uid,
    required bool isActive,
  }) async {
    try {
      await _usersRef.doc(uid).update({'isActive': isActive});
    } catch (e) {
      throw const ServerException('Failed to update account status.');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        e.message ?? 'Failed to send password reset email.',
      );
    } catch (e) {
      throw const ServerException('Failed to send password reset email.');
    }
  }

  @override
  Future<void> deleteUserAccount(String uid) async {
    final caller = firebaseAuth.currentUser;
    if (caller == null) {
      throw const ServerException(
        'Your session has expired. Please sign in again.',
      );
    }
    if (caller.uid == uid) {
      throw const ServerException(
        'To delete your own account, use My Account instead.',
      );
    }

    const server = GetOptions(source: Source.server);
    final DocumentSnapshot callerDoc;
    final DocumentSnapshot targetDoc;
    try {
      // Re-check the caller's role on the server rather than trusting the
      // cached session (the security rules enforce this too).
      callerDoc = await _usersRef.doc(caller.uid).get(server);
      targetDoc = await _usersRef.doc(uid).get(server);
    } on FirebaseException catch (e) {
      throw ServerException(AccountDataCleaner.messageFor(e));
    }

    final callerData = callerDoc.data() as Map<String, dynamic>?;
    final callerIsAdmin =
        callerData != null &&
        callerData['role'] == UserRole.admin.value &&
        (callerData['isActive'] as bool? ?? true);
    if (!callerIsAdmin) {
      throw const ServerException(
        "Only administrators can delete other users' accounts.",
      );
    }

    final targetData = targetDoc.data() as Map<String, dynamic>?;
    if (targetData == null) {
      throw const ServerException('This account has already been deleted.');
    }

    final target = UserModel.fromJson(targetData);
    await accountDataCleaner.ensureDeletable(target, isSelf: false);
    await accountDataCleaner.purge(uid: uid, deletedBy: caller.uid);
  }
}
