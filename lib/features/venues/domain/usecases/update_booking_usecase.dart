import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/booking_entity.dart';
import '../entities/booking_status.dart';
import '../repositories/venue_repository.dart';

class UpdateBookingUseCase {
  final VenueRepository repository;
  const UpdateBookingUseCase(this.repository);

  Future<Either<Failure, BookingEntity>> call({
    required BookingEntity original,
    required String purpose,
    required DateTime startDate,
    required DateTime endDate,
    required bool isFullDay,
    String? startTime,
    String? endTime,
  }) async {
    final dateTimeChanged =
        !_isSameDay(original.startDate, startDate) ||
        !_isSameDay(original.endDate, endDate) ||
        original.isFullDay != isFullDay ||
        original.startTime != startTime ||
        original.endTime != endTime;

    final newStatus =
        (original.status == BookingStatus.approved && dateTimeChanged)
        ? BookingStatus.pending
        : original.status;

    if (dateTimeChanged) {
      final existingResult = await repository.getBookingsForVenue(
        original.venueId,
      );

      Failure? conflictFailure;
      existingResult.fold((failure) => conflictFailure = failure, (
        existingBookings,
      ) {
        final candidate = BookingEntity(
          id: original.id,
          venueId: original.venueId,
          venueName: original.venueName,
          studentId: original.studentId,
          studentName: original.studentName,
          coordinatorId: original
              .coordinatorId, // <-- added: fixes missing_required_argument
          purpose: purpose,
          startDate: startDate,
          endDate: endDate,
          isFullDay: isFullDay,
          startTime: startTime,
          endTime: endTime,
          status: newStatus,
          createdAt: original.createdAt,
          updatedAt: DateTime.now(),
        );

        final hasConflict = existingBookings
            .where((b) => b.id != original.id) // exclude self
            .any((b) => candidate.overlapsWith(b));

        if (hasConflict) {
          conflictFailure = const ServerFailure(
            'This venue is already booked for the selected date/time. Please choose a different slot.',
          );
        }
      });

      if (conflictFailure != null) {
        return Left(conflictFailure!);
      }
    }

    return repository.updateBooking(
      bookingId: original.id,
      purpose: purpose,
      startDate: startDate,
      endDate: endDate,
      isFullDay: isFullDay,
      startTime: startTime,
      endTime: endTime,
      status: newStatus,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
