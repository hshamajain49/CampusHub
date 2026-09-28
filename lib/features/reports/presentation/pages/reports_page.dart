import 'package:campus_hub/core/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../complaints/presentation/utils/status_ui_extension.dart';
import '../../../venues/presentation/utils/booking_status_ui_extension.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import '../widgets/chart_datum.dart';
import '../widgets/donut_chart_card.dart';
import '../widgets/horizontal_bar_list_card.dart';
import '../widgets/trend_chart_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..load(),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ReportsCubit>().load(),
          ),
        ],
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading || state is ReportsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ReportsCubit>().load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final summary = (state as ReportsLoaded).summary;
          return RefreshIndicator(
            onRefresh: () => context.read<ReportsCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _GeneratedAtPill(time: summary.generatedAt),
                const SizedBox(height: 20),

                // --- Overview: 2x2 grid, height-safe regardless of label length ---
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    StatCard(
                      label: 'Total Users',
                      value: '${summary.totalUsers}',
                      icon: Icons.people_outline_rounded,
                      color: AppColors.primary,
                    ),
                    StatCard(
                      label: 'Total Complaints',
                      value: '${summary.totalComplaints}',
                      icon: Icons.report_problem_outlined,
                      color: AppColors.statusOrange,
                    ),
                    StatCard(
                      label: 'Total Bookings',
                      value: '${summary.totalBookings}',
                      icon: Icons.meeting_room_outlined,
                      color: AppColors.secondary,
                    ),
                    StatCard(
                      label: 'Booking Approval Rate',
                      value: '${(summary.bookingApprovalRate * 100).round()}%',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.statusGreen,
                    ),
                  ],
                ),

                // const SizedBox(height: 10),
                const _SectionHeader(
                  icon: Icons.report_problem_outlined,
                  title: 'Complaints',
                ),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By Status',
                  data: summary.complaintsByStatus.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key.displayName,
                          value: e.value,
                          color: e.key.color,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                HorizontalBarListCard(
                  title: 'By Category',
                  maxItems: 7,
                  data: summary.complaintsByCategory.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key.displayName,
                          value: e.value,
                          color: AppColors.primary,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                HorizontalBarListCard(
                  title: 'By Department',
                  maxItems: 7,
                  data: summary.complaintsByDepartment.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key,
                          value: e.value,
                          color: AppColors.secondary,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                TrendChartCard(
                  title: 'Last 30 Days',
                  data: summary.complaintsTrend30d,
                ),
                const SizedBox(height: 28),

                const _SectionHeader(
                  icon: Icons.meeting_room_outlined,
                  title: 'Venue Bookings',
                ),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By Status',
                  data: summary.bookingsByStatus.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key.displayName,
                          value: e.value,
                          color: e.key.color,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                HorizontalBarListCard(
                  title: 'Most-Booked Venues',
                  maxItems: 5,
                  data: summary.bookingsByVenue.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key,
                          value: e.value,
                          color: AppColors.primary,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 28),

                const _SectionHeader(
                  icon: Icons.people_outline_rounded,
                  title: 'Users',
                ),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By Role',
                  data: summary.usersByRole.entries
                      .map(
                        (e) => ChartDatum(
                          label: _roleLabel(e.key),
                          value: e.value,
                          color: _roleColor(e.key),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.departmentStaff:
        return 'Department Staff';
      case UserRole.venueCoordinator:
        return 'Venue Coordinator';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.primary;
      case UserRole.departmentStaff:
        return AppColors.statusOrange;
      case UserRole.venueCoordinator:
        return AppColors.secondary;
      case UserRole.admin:
        return AppColors.statusGreen;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.h2),
      ],
    );
  }
}

class _GeneratedAtPill extends StatelessWidget {
  final DateTime time;
  const _GeneratedAtPill({required this.time});

  @override
  Widget build(BuildContext context) {
    final label =
        'Generated ${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')} · '
        '${time.day}/${time.month}/${time.year}';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.update_rounded,
              size: 13,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
