import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/admin_repository.dart';

class DeleteUserAccountUseCase {
  final AdminRepository repository;
  const DeleteUserAccountUseCase(this.repository);

  Future<Either<Failure, void>> call(String uid) =>
      repository.deleteUserAccount(uid);
}
