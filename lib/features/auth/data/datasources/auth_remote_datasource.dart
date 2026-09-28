import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> login({required String email, required String password});

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final now = DateTime.now();

      final userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: UserRole.student,
        department: null,
        createdAt: now,
      );

      await firestore.collection('users').doc(uid).set(userModel.toJson());
      return userModel;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw ServerException('Registration failed. Please try again.');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        await firebaseAuth.signOut();
        throw const AuthException('User profile not found. Contact admin.');
      }

      final user = UserModel.fromJson(doc.data()!);
      if (!user.isActive) {
        await firebaseAuth.signOut();
        throw const AuthException(
          'Your account has been deactivated. Contact an administrator.',
        );
      }

      return user;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e));
    } on AuthException {
      rethrow; // NEW: without this, the generic catch below would swallow our own AuthException
      // (this was a pre-existing latent bug for the "profile not found" case too)
    } catch (e) {
      throw ServerException('Login failed. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw const ServerException('Logout failed. Please try again.');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
    if (!doc.exists) return null;

    final user = UserModel.fromJson(doc.data()!);
    if (!user.isActive) {
      await firebaseAuth.signOut();
      return null;
    }
    return user;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      final doc = await firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) return null;

      final user = UserModel.fromJson(doc.data()!);
      if (!user.isActive) {
        // Deactivated while a session already existed (e.g. Admin toggled it just now,
        // or the app was relaunched with a stale session). Force sign-out; this itself
        // fires another authStateChanges event with a null user right after.
        firebaseAuth.signOut();
        return null;
      }
      return user;
    });
  }

  String _mapFirebaseAuthError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Contact admin.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
