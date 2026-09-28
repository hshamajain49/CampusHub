import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/venue_entity.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import '../../domain/repositories/venue_repository.dart';
import '../datasources/venue_remote_datasource.dart';
import '../datasources/booking_remote_datasource.dart';

class VenueRepositoryImpl implements VenueRepository {
  final VenueRemoteDataSource venueDataSource;
  final BookingRemoteDataSource bookingDataSource;

  const VenueRepositoryImpl({
    required this.venueDataSource,
    required this.bookingDataSource,
  });

  @override
  Stream<List<VenueEntity>> getVenues() => venueDataSource.getVenues();

  @override
  Future<Either<Failure, VenueEntity>> getVenueById(String id) async {
    try {
      final venue = await venueDataSource.getVenueById(id);
      return Right(venue);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getBookingsForVenue(
    String venueId,
  ) async {
    try {
      final bookings = await bookingDataSource.getBookingsForVenue(venueId);
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
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
  }) async {
    try {
      final booking = await bookingDataSource.createBooking(
        venueId: venueId,
        venueName: venueName,
        coordinatorId: coordinatorId,
        purpose: purpose,
        startDate: startDate,
        endDate: endDate,
        isFullDay: isFullDay,
        startTime: startTime,
        endTime: endTime,
      );
      return Right(booking);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<BookingEntity>> getMyBookings(String studentId) =>
      bookingDataSource.getMyBookings(studentId);

  @override
  Future<Either<Failure, BookingEntity>> getBookingById(
    String bookingId,
  ) async {
    try {
      final booking = await bookingDataSource.getBookingById(bookingId);
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> updateBooking({
    required String bookingId,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
    required BookingStatus status,
  }) async {
    try {
      final booking = await bookingDataSource.updateBooking(
        bookingId: bookingId,
        purpose: purpose,
        startDate: startDate,
        endDate: endDate,
        isFullDay: isFullDay,
        startTime: startTime,
        endTime: endTime,
        status: status,
      );
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> cancelBooking(String bookingId) async {
    try {
      await bookingDataSource.cancelBooking(bookingId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<BookingEntity>> getBookingsForCoordinator(String coordinatorId) {
    return bookingDataSource.getBookingsForCoordinator(coordinatorId);
  }

  @override
  Future<Either<Failure, BookingEntity>> approveBooking(
    String bookingId,
  ) async {
    try {
      final booking = await bookingDataSource.approveBooking(bookingId);
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> rejectBooking(
    String bookingId,
    String reason,
  ) async {
    try {
      final booking = await bookingDataSource.rejectBooking(bookingId, reason);
      return Right(booking);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, VenueEntity>> createVenue({
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
  }) async {
    try {
      final venue = await venueDataSource.createVenue(
        name: name,
        description: description,
        capacity: capacity,
        building: building,
        amenities: amenities,
        coordinatorId: coordinatorId,
      );
      return Right(venue);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, VenueEntity>> updateVenue({
    required String id,
    required String name,
    required String description,
    required int capacity,
    required String building,
    required List<String> amenities,
    required String coordinatorId,
    required bool isActive,
  }) async {
    try {
      final venue = await venueDataSource.updateVenue(
        id: id,
        name: name,
        description: description,
        capacity: capacity,
        building: building,
        amenities: amenities,
        coordinatorId: coordinatorId,
        isActive: isActive,
      );
      return Right(venue);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
