class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
}

/// The operation failed part-way and the user has been signed out.
class SignedOutException extends AuthException {
  const SignedOutException(super.message);
}
