import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/complaint_entity.dart';
import '../repositories/complaint_repository.dart';

/// The student who filed a complaint gives the final approval (or rejection)
/// once staff mark the work as done.
class ReviewComplaintResolutionUseCase {
  final ComplaintRepository repository;
  const ReviewComplaintResolutionUseCase(this.repository);

  Future<Either<Failure, ComplaintEntity>> call({
    required String complaintId,
    required bool approved,
    String? reason,
  }) {
    return repository.reviewResolution(
      complaintId: complaintId,
      approved: approved,
      reason: reason,
    );
  }
}
