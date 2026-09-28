import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/error/exceptions.dart';
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
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth; // NEW — needed for sendPasswordResetEmail
  AdminRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
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
}
