import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../repositories/admin_repository.dart';

class UpdateUserRoleUseCase {
  final AdminRepository repository;
  const UpdateUserRoleUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String uid,
    required UserRole role,
    String? department,
  }) {
    return repository.updateUserRole(
      uid: uid,
      role: role,
      department: department,
    );
  }
}
