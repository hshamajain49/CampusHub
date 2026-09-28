import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/venue_entity.dart';
import '../repositories/venue_repository.dart';

class UpdateVenueUseCase {
  final VenueRepository repository;
  const UpdateVenueUseCase(this.repository);

  Future<Either<Failure, VenueEntity>> call({
    required String id,
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
    required bool isActive,
  }) {
    return repository.updateVenue(
      id: id,
      name: name,
      description: description,
      capacity: capacity,
      building: building,
      amenities: amenities,
      coordinatorId: coordinatorId,
      isActive: isActive,
    );
  }
}
