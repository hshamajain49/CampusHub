import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/complaint_entity.dart';
import '../entities/complaint_status.dart';
import '../repositories/complaint_repository.dart';

/// Not yet wired to any UI — Department Staff dashboard (a future module)
/// will call this. Registered in DI now so that dashboard is a pure
/// presentation-layer addition later, with no domain/data work left to do.
class UpdateComplaintStatusUseCase {
  final ComplaintRepository repository;
  const UpdateComplaintStatusUseCase(this.repository);

  Future<Either<Failure, ComplaintEntity>> call({
    required String complaintId,
    required ComplaintStatus status,
  }) {
    return repository.updateComplaintStatus(
      complaintId: complaintId,
      status: status,
    );
  }
}
