import '../entities/booking_entity.dart';
import '../repositories/venue_repository.dart';

class GetMyBookingsUseCase {
  final VenueRepository repository;
  const GetMyBookingsUseCase(this.repository);

  Stream<List<BookingEntity>> call(String studentId) =>
      repository.getMyBookings(studentId);
}
