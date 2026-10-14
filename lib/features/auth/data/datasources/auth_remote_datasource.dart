import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_role.dart';
import '../models/user_model.dart';
import 'account_data_cleaner.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerStudent({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> login({required String email, required String password});

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  /// Permanently deletes the signed-in user's account after confirming
  /// [password]. Only ever acts on the current user.
  Future<void> deleteAccount({required String password});

  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final fb_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final AccountDataCleaner accountDataCleaner;

  /// True while [deleteAccount] runs, so the profile listener in
  /// [authStateChanges] doesn't sign out (which would block the final
  /// Firebase Auth deletion) when it sees the profile disappear.
  bool _deletingCurrentAccount = false;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.accountDataCleaner,
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
        if (await accountDataCleaner.isDeleted(uid)) {
          // An admin deleted this account but couldn't remove the sign-in
          // itself (that needs the owner's fresh session), so finish it now.
          try {
            await credential.user!.delete();
          } catch (_) {
            await firebaseAuth.signOut();
          }
          throw const AuthException('This account has been deleted.');
        }
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
  Future<void> deleteAccount({required String password}) async {
    final firebaseUser = firebaseAuth.currentUser;
    final email = firebaseUser?.email;
    if (firebaseUser == null || email == null) {
      throw const AuthException(
        'Your session has expired. Please sign in again.',
      );
    }

    // Confirms it's really the account owner, and satisfies Firebase's
    // "recent login" requirement for deleting the Auth user.
    try {
      await firebaseUser.reauthenticateWithCredential(
        fb_auth.EmailAuthProvider.credential(email: email, password: password),
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapReauthenticationError(e));
    }

    final uid = firebaseUser.uid;
    _deletingCurrentAccount = true;
    try {
      final Map<String, dynamic>? profile;
      try {
        final doc = await firestore
            .collection('users')
            .doc(uid)
            .get(const GetOptions(source: Source.server));
        profile = doc.data();
      } on FirebaseException catch (e) {
        throw ServerException(AccountDataCleaner.messageFor(e));
      }
      if (profile != null) {
        await accountDataCleaner.ensureDeletable(
          UserModel.fromJson(profile),
          isSelf: true,
        );
      }
      await accountDataCleaner.purge(uid: uid, deletedBy: uid);

      try {
        await firebaseUser.delete();
      } on fb_auth.FirebaseAuthException {
        // The data is gone; the tombstone lets the next sign-in finish the job.
        await firebaseAuth.signOut();
        throw const SignedOutException(
          'Your data was deleted, but your sign-in could not be removed. '
          'Sign in once more to finish deleting your account.',
        );
      }
    } finally {
      _deletingCurrentAccount = false;
    }
  }

  /// The signed-in user's profile, kept live: role changes apply at once, and
  /// a deactivated or deleted account is signed out of every open session.
  @override
  Stream<UserModel?> get authStateChanges {
    StreamSubscription<fb_auth.User?>? authSubscription;
    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    profileSubscription;
    late final StreamController<UserModel?> controller;

    void watchProfile(String uid) {
      var hadProfile = false;
      profileSubscription = firestore
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen(
            (doc) {
              final data = doc.data();
              if (data == null) {
                if (_deletingCurrentAccount) return;
                // Missing before it was ever seen: registration is still
                // writing it. Missing after: the account was deleted.
                controller.add(null);
                if (hadProfile) unawaited(firebaseAuth.signOut());
                return;
              }
              hadProfile = true;

              final UserModel user;
              try {
                user = UserModel.fromJson(data);
              } catch (_) {
                controller.add(null);
                return;
              }
              if (!user.isActive) {
                // Signing out fires another auth event with a null user.
                controller.add(null);
                unawaited(firebaseAuth.signOut());
                return;
              }
              controller.add(user);
            },
            // e.g. permission denied as the session ends.
            onError: (Object _) => controller.add(null),
          );
    }

    controller = StreamController<UserModel?>(
      onListen: () {
        authSubscription = firebaseAuth.authStateChanges().listen((
          firebaseUser,
        ) {
          profileSubscription?.cancel();
          profileSubscription = null;
          if (firebaseUser == null) {
            controller.add(null);
          } else {
            watchProfile(firebaseUser.uid);
          }
        }, onError: controller.addError);
      },
      onCancel: () async {
        await profileSubscription?.cancel();
        await authSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  String _mapReauthenticationError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please try again.';
      case 'user-mismatch':
      case 'user-not-found':
      case 'user-token-expired':
        return 'Your session has expired. Please sign in again.';
      default:
        return _mapFirebaseAuthError(e);
    }
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
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
