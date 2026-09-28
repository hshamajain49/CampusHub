import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/complaint_entity.dart';
import '../repositories/complaint_repository.dart';

class GetComplaintByIdUseCase {
  final ComplaintRepository repository;
  const GetComplaintByIdUseCase(this.repository);

  Future<Either<Failure, ComplaintEntity>> call(String id) {
    return repository.getComplaintById(id);
  }
}
