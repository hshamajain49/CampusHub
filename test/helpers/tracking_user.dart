// MockUser is mutable by design (see firebase_auth_mocks).
// ignore_for_file: must_be_immutable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

/// [MockUser] that records deletions and can fail re-authentication or
/// deletion on demand.
class TrackingUser extends MockUser {
  TrackingUser({required super.uid, super.email});

  int deleteCalls = 0;
  FirebaseAuthException? reauthenticateError;
  FirebaseAuthException? deleteError;

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential? credential,
  ) {
    if (reauthenticateError != null) throw reauthenticateError!;
    return super.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> delete() {
    if (deleteError != null) throw deleteError!;
    deleteCalls++;
    return super.delete();
  }
}
