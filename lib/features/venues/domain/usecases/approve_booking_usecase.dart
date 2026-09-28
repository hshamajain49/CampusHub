import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/booking_entity.dart';
import '../repositories/venue_repository.dart';

class ApproveBookingUseCase {
  final VenueRepository repository;
  const ApproveBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(String bookingId) =>
      repository.approveBooking(bookingId);
}
