import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/admin_repository.dart';

class SendPasswordResetUseCase {
  final AdminRepository repository;
  const SendPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) =>
      repository.sendPasswordReset(email);
}
