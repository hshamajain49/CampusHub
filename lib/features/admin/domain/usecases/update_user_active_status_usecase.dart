import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/admin_repository.dart';

class UpdateUserActiveStatusUseCase {
  final AdminRepository repository;
  const UpdateUserActiveStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String uid,
    required bool isActive,
  }) {
    return repository.updateUserActiveStatus(uid: uid, isActive: isActive);
  }
}
