import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/complaint_entity.dart';
import '../../domain/entities/complaint_category.dart';
import '../../domain/entities/complaint_status.dart';
import '../../domain/repositories/complaint_repository.dart';
import '../datasources/complaint_remote_datasource.dart';

class ComplaintRepositoryImpl implements ComplaintRepository {
  final ComplaintRemoteDataSource remoteDataSource;
  const ComplaintRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, ComplaintEntity>> createComplaint({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  }) async {
    try {
      final complaint = await remoteDataSource.createComplaint(
        title: title,
        description: description,
        category: category,
        location: location,
        imagePaths: imagePaths,
      );
      return Right(complaint);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Something went wrong. Please try again.'));
    }
  }

  @override
  Stream<List<ComplaintEntity>> getMyComplaints(String studentId) {
    return remoteDataSource.getMyComplaints(studentId);
  }

  @override
  Future<Either<Failure, ComplaintEntity>> getComplaintById(String id) async {
    try {
      final complaint = await remoteDataSource.getComplaintById(id);
      return Right(complaint);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ComplaintEntity>> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
  }) async {
    try {
      final complaint = await remoteDataSource.updateComplaintStatus(
        complaintId: complaintId,
        status: status,
      );
      return Right(complaint);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<ComplaintEntity>> getComplaintsByDepartment(String department) {
    return remoteDataSource.getComplaintsByDepartment(department);
  }
}
