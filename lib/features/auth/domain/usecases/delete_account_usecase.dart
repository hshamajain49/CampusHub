import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository repository;
  const DeleteAccountUseCase(this.repository);

  Future<Either<Failure, void>> call({required String password}) {
    if (password.isEmpty) {
      return Future.value(
        const Left(AuthFailure('Enter your password to confirm.')),
      );
    }
    return repository.deleteAccount(password: password);
  }
}
