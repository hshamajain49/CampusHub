import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/admin_repository.dart';

class GetAllUsersUseCase {
  final AdminRepository repository;
  const GetAllUsersUseCase(this.repository);

  Stream<List<UserEntity>> call() => repository.getAllUsers();
}
