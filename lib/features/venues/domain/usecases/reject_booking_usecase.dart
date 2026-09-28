import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/booking_entity.dart';
import '../repositories/venue_repository.dart';

class RejectBookingUseCase {
  final VenueRepository repository;
  const RejectBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(
    String bookingId,
    String reason,
  ) => repository.rejectBooking(bookingId, reason);
}
