import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../repositories/venue_repository.dart';

class CancelBookingUseCase {
  final VenueRepository repository;
  const CancelBookingUseCase(this.repository);

  Future<Either<Failure, void>> call(String bookingId) =>
      repository.cancelBooking(bookingId);
}
