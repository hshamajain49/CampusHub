import '../entities/venue_entity.dart';
import '../repositories/venue_repository.dart';

class GetVenuesUseCase {
  final VenueRepository repository;
  const GetVenuesUseCase(this.repository);

  Stream<List<VenueEntity>> call() => repository.getVenues();
}
