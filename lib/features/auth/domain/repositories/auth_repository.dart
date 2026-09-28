import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';

/// Defines WHAT auth operations exist — not HOW (that's the Data layer's job).
/// Presentation layer (Cubits) depends on this interface, never on Firebase directly.
abstract class AuthRepository {
  /// Registers a new Student account.
  Future<Either<Failure, UserEntity>> registerStudent({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  /// Returns the currently logged-in user, or null if not logged in.
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Real-time stream of auth state changes (login/logout events).
  Stream<UserEntity?> get authStateChanges;
}
