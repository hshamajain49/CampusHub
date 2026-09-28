import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterStudentUseCase {
  final AuthRepository repository;
  const RegisterStudentUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
  }) {
    return repository.registerStudent(
      name: name,
      email: email,
      password: password,
    );
  }
}
