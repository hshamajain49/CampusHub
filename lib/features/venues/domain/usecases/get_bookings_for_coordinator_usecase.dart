import '../entities/booking_entity.dart';
import '../repositories/venue_repository.dart';

class GetBookingsForCoordinatorUseCase {
  final VenueRepository repository;
  const GetBookingsForCoordinatorUseCase(this.repository);

  Stream<List<BookingEntity>> call(String coordinatorId) =>
      repository.getBookingsForCoordinator(coordinatorId);
}
