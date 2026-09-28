import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../repositories/admin_repository.dart';

class CreateManagedUserUseCase {
  final AdminRepository repository;
  const CreateManagedUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  }) {
    return repository.createUserAccount(
      name: name,
      email: email,
      password: password,
      role: role,
      department: department,
    );
  }
}
