import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  const AdminRepositoryImpl(this.remoteDataSource);

  @override
  Stream<List<UserEntity>> getAllUsers() => remoteDataSource.getAllUsers();

  @override
  Future<Either<Failure, UserEntity>> createUserAccount({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  }) async {
    try {
      final user = await remoteDataSource.createUserAccount(
        name: name,
        email: email,
        password: password,
        role: role,
        department: department,
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserRole({
    required String uid,
    required UserRole role,
    String? department,
  }) async {
    try {
      await remoteDataSource.updateUserRole(
        uid: uid,
        role: role,
        department: department,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserActiveStatus({
    required String uid,
    required bool isActive,
  }) async {
    try {
      await remoteDataSource.updateUserActiveStatus(
        uid: uid,
        isActive: isActive,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordReset(String email) async {
    try {
      await remoteDataSource.sendPasswordReset(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
