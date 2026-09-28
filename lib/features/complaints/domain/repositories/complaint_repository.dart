import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/complaint_entity.dart';
import '../entities/complaint_category.dart';
import '../entities/complaint_status.dart';

abstract class ComplaintRepository {
  Future<Either<Failure, ComplaintEntity>> createComplaint({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  });

  Stream<List<ComplaintEntity>> getMyComplaints(String studentId);

  Future<Either<Failure, ComplaintEntity>> getComplaintById(String id);

  Future<Either<Failure, ComplaintEntity>> updateComplaintStatus({
    required String complaintId,
    required ComplaintStatus status,
  });

  Stream<List<ComplaintEntity>> getComplaintsByDepartment(String department);
}
