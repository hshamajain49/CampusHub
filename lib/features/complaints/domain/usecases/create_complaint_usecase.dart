import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/complaint_entity.dart';
import '../entities/complaint_category.dart';
import '../repositories/complaint_repository.dart';

class CreateComplaintUseCase {
  final ComplaintRepository repository;
  const CreateComplaintUseCase(this.repository);

  Future<Either<Failure, ComplaintEntity>> call({
    required String title,
    String? description,
    required ComplaintCategory category,
    String? location,
    required List<String> imagePaths,
  }) {
    return repository.createComplaint(
      title: title,
      description: description,
      category: category,
      location: location,
      imagePaths: imagePaths,
    );
  }
}
