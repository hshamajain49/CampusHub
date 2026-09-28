import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';

abstract class AdminRepository {
  Stream<List<UserEntity>> getAllUsers();

  Future<Either<Failure, UserEntity>> createUserAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  });

  Future<Either<Failure, void>> updateUserRole({
    required String uid,
    required UserRole role,
    String? department,
  });

  // NEW
  Future<Either<Failure, void>> updateUserActiveStatus({
    required String uid,
    required bool isActive,
  });

  // NEW
  Future<Either<Failure, void>> sendPasswordReset(String email);
}
