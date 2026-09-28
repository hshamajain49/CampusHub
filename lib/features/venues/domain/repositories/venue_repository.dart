import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/venue_entity.dart';
import '../entities/booking_entity.dart';
import '../entities/booking_status.dart';

abstract class VenueRepository {
  Stream<List<VenueEntity>> getVenues();

  Future<Either<Failure, VenueEntity>> getVenueById(String id);

  Future<Either<Failure, List<BookingEntity>>> getBookingsForVenue(
    String venueId,
  );

  Future<Either<Failure, BookingEntity>> createBooking({
    required String venueId,
    required String venueName,
    required String coordinatorId,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  });
  Stream<List<BookingEntity>> getMyBookings(String studentId);

  Future<Either<Failure, BookingEntity>> getBookingById(String bookingId);

  Future<Either<Failure, BookingEntity>> updateBooking({
    required String bookingId,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
    required BookingStatus status,
  });

  Future<Either<Failure, void>> cancelBooking(String bookingId);

  Stream<List<BookingEntity>> getBookingsForCoordinator(String coordinatorId);

  Future<Either<Failure, BookingEntity>> approveBooking(String bookingId);

  Future<Either<Failure, BookingEntity>> rejectBooking(
    String bookingId,
    String reason,
  );

  Future<Either<Failure, VenueEntity>> createVenue({
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
  });

  Future<Either<Failure, VenueEntity>> updateVenue({
    required String id,
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
    required bool isActive,
  });
}
