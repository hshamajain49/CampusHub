import '../entities/complaint_entity.dart';
import '../repositories/complaint_repository.dart';

class GetMyComplaintsUseCase {
  final ComplaintRepository repository;
  const GetMyComplaintsUseCase(this.repository);

  Stream<List<ComplaintEntity>> call(String studentId) {
    return repository.getMyComplaints(studentId);
  }
}
