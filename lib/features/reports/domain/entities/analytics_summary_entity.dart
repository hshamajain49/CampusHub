import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../complaints/domain/entities/complaint_category.dart';
import '../../../complaints/domain/entities/complaint_status.dart';
import '../../../venues/domain/entities/booking_status.dart';
import 'daily_count.dart';

class AnalyticsSummaryEntity extends Equatable {
  // Users
  final int totalUsers;
  final Map<UserRole, int> usersByRole;

  // Complaints
  final int totalComplaints;
  final Map<ComplaintStatus, int> complaintsByStatus;
  final Map<ComplaintCategory, int> complaintsByCategory;
  final Map<String, int> complaintsByDepartment;
  final List<DailyCount> complaintsTrend30d;

  // Bookings
  final int totalBookings;
  final Map<BookingStatus, int> bookingsByStatus;
  final Map<String, int> bookingsByVenue;
  final double
  bookingApprovalRate; // approved / (approved + rejected), 0.0 if no decided bookings

  final DateTime generatedAt;

  const AnalyticsSummaryEntity({
    required this.totalUsers,
    required this.usersByRole,
    required this.totalComplaints,
    required this.complaintsByStatus,
    required this.complaintsByCategory,
    required this.complaintsByDepartment,
    required this.complaintsTrend30d,
    required this.totalBookings,
    required this.bookingsByStatus,
    required this.bookingsByVenue,
    required this.bookingApprovalRate,
    required this.generatedAt,
  });

  @override
  List<Object?> get props => [
    totalUsers,
    usersByRole,
    totalComplaints,
    complaintsByStatus,
    complaintsByCategory,
    complaintsByDepartment,
    complaintsTrend30d,
    totalBookings,
    bookingsByStatus,
    bookingsByVenue,
    bookingApprovalRate,
    generatedAt,
  ];
}
