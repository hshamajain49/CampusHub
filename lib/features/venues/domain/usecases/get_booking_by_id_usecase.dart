import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/booking_entity.dart';
import '../repositories/venue_repository.dart';

class GetBookingByIdUseCase {
  final VenueRepository repository;
  const GetBookingByIdUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call(String bookingId) =>
      repository.getBookingById(bookingId);
}
