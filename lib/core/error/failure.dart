import 'package:equatable/equatable.dart';

/// Base class for all "expected" errors across the app.
/// Repositories return Failure (not throw exceptions) so callers
/// must explicitly handle error cases.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// The operation failed part-way and the user has been signed out, so the
/// screen that started it is about to close.
class SignedOutFailure extends AuthFailure {
  const SignedOutFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
