import '../entities/complaint_entity.dart';
import '../repositories/complaint_repository.dart';

class GetComplaintsByDepartmentUseCase {
  final ComplaintRepository repository;
  const GetComplaintsByDepartmentUseCase(this.repository);

  Stream<List<ComplaintEntity>> call(String department) =>
      repository.getComplaintsByDepartment(department);
}
