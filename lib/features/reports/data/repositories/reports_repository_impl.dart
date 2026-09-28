import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../complaints/data/models/complaint_model.dart';
import '../../../complaints/domain/entities/complaint_category.dart';
import '../../../complaints/domain/entities/complaint_status.dart';
import '../../../venues/data/models/booking_model.dart';
import '../../../venues/domain/entities/booking_status.dart';
import '../../domain/entities/analytics_summary_entity.dart';
import '../../domain/entities/daily_count.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;
  const ReportsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AnalyticsSummaryEntity>> getAnalyticsSummary() async {
    try {
      final results = await Future.wait([
        remoteDataSource.getAllComplaints(),
        remoteDataSource.getAllBookings(),
        remoteDataSource.getAllUsersOnce(),
      ]);

      final complaints = results[0] as List<ComplaintModel>;
      final bookings = results[1] as List<BookingModel>;
      final users = results[2] as List<UserModel>;

      return Right(_buildSummary(complaints, bookings, users));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(
        ServerFailure('Something went wrong while building the report.'),
      );
    }
  }

  AnalyticsSummaryEntity _buildSummary(
    List<ComplaintModel> complaints,
    List<BookingModel> bookings,
    List<UserModel> users,
  ) {
    // --- Users ---
    final usersByRole = <UserRole, int>{for (final r in UserRole.values) r: 0};
    for (final u in users) {
      usersByRole[u.role] = (usersByRole[u.role] ?? 0) + 1;
    }

    // --- Complaints ---
    final complaintsByStatus = <ComplaintStatus, int>{
      for (final s in ComplaintStatus.values) s: 0,
    };
    final complaintsByCategory = <ComplaintCategory, int>{
      for (final c in ComplaintCategory.values) c: 0,
    };
    final complaintsByDepartment = <String, int>{};
    for (final c in complaints) {
      complaintsByStatus[c.status] = (complaintsByStatus[c.status] ?? 0) + 1;
      complaintsByCategory[c.category] =
          (complaintsByCategory[c.category] ?? 0) + 1;
      complaintsByDepartment[c.assignedDepartment] =
          (complaintsByDepartment[c.assignedDepartment] ?? 0) + 1;
    }
    final complaintsTrend = _dailyTrend(complaints.map((c) => c.createdAt));

    // --- Bookings ---
    final bookingsByStatus = <BookingStatus, int>{
      for (final s in BookingStatus.values) s: 0,
    };
    final bookingsByVenue = <String, int>{};
    for (final b in bookings) {
      bookingsByStatus[b.status] = (bookingsByStatus[b.status] ?? 0) + 1;
      bookingsByVenue[b.venueName] = (bookingsByVenue[b.venueName] ?? 0) + 1;
    }
    final approved = bookingsByStatus[BookingStatus.approved] ?? 0;
    final rejected = bookingsByStatus[BookingStatus.rejected] ?? 0;
    final decided = approved + rejected;
    final approvalRate = decided == 0 ? 0.0 : approved / decided;

    return AnalyticsSummaryEntity(
      totalUsers: users.length,
      usersByRole: usersByRole,
      totalComplaints: complaints.length,
      complaintsByStatus: complaintsByStatus,
      complaintsByCategory: complaintsByCategory,
      complaintsByDepartment: complaintsByDepartment,
      complaintsTrend30d: complaintsTrend,
      totalBookings: bookings.length,
      bookingsByStatus: bookingsByStatus,
      bookingsByVenue: bookingsByVenue,
      bookingApprovalRate: approvalRate,
      generatedAt: DateTime.now(),
    );
  }

  /// Buckets the given timestamps into a 30-day (today inclusive) daily count series.
  List<DailyCount> _dailyTrend(Iterable<DateTime> timestamps) {
    final today = DateTime.now();
    final startDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: 29));

    final buckets = <DateTime, int>{
      for (int i = 0; i < 30; i++) startDay.add(Duration(days: i)): 0,
    };

    for (final ts in timestamps) {
      final day = DateTime(ts.year, ts.month, ts.day);
      if (!day.isBefore(startDay)) {
        buckets[day] = (buckets[day] ?? 0) + 1;
      }
    }

    final entries = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => DailyCount(date: e.key, count: e.value)).toList();
  }
}
