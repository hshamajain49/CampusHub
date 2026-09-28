import 'package:equatable/equatable.dart';
import 'booking_status.dart';

class BookingEntity extends Equatable {
  final String id;
  final String venueId;
  final String venueName;
  final String studentId;
  final String studentName;
  final String purpose; // event/reason for booking
  final DateTime startDate;
  final DateTime endDate;
  final bool isFullDay;
  final String? startTime; // e.g. "14:00" — null if isFullDay
  final String? endTime; // e.g. "16:00" — null if isFullDay
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String coordinatorId;
  final String? rejectionReason;

  const BookingEntity({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.studentId,
    required this.studentName,
    required this.purpose,
    required this.startDate,
    required this.endDate,
    required this.isFullDay,
    this.startTime,
    this.endTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.coordinatorId,
    this.rejectionReason,
  });

  /// Checks if this booking's date+time range overlaps with another's.
  /// Used for client-side conflict detection before submitting a request.
  bool overlapsWith(BookingEntity other) {
    // Only compare against bookings still "live" (not rejected/cancelled).
    if (other.status == BookingStatus.rejected ||
        other.status == BookingStatus.cancelled) {
      return false;
    }

    // Step 1: Do the date ranges overlap at all?
    final dateOverlap =
        startDate.isBefore(other.endDate.add(const Duration(days: 1))) &&
        endDate.isAfter(other.startDate.subtract(const Duration(days: 1)));

    if (!dateOverlap) return false;

    // Step 2: If either booking is full-day, any date overlap = conflict.
    if (isFullDay || other.isFullDay) return true;

    // Step 3: Both have specific times — check time range overlap.
    final thisStart = _timeToMinutes(startTime!);
    final thisEnd = _timeToMinutes(endTime!);
    final otherStart = _timeToMinutes(other.startTime!);
    final otherEnd = _timeToMinutes(other.endTime!);

    return thisStart < otherEnd && thisEnd > otherStart;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  List<Object?> get props => [
    id,
    venueId,
    venueName,
    studentId,
    studentName,
    purpose,
    startDate,
    endDate,
    isFullDay,
    startTime,
    endTime,
    status,
    createdAt,
    updatedAt,
    coordinatorId,
    rejectionReason,
  ];
}
