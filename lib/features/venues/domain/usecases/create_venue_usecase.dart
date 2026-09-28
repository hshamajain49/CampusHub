import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/venue_entity.dart';
import '../repositories/venue_repository.dart';

class CreateVenueUseCase {
  final VenueRepository repository;
  const CreateVenueUseCase(this.repository);

  Future<Either<Failure, VenueEntity>> call({
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
  }) {
    return repository.createVenue(
      name: name,
      description: description,
      capacity: capacity,
      building: building,
      amenities: amenities,
      coordinatorId: coordinatorId,
    );
  }
}
