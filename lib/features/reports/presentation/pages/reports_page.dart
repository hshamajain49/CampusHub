import 'package:campus_hub/core/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/utils/user_role_ui_extension.dart';
import '../../../complaints/presentation/utils/category_ui_extension.dart';
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
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<ReportsCubit>().load(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading || state is ReportsInitial) {
            return const LoadingView();
          }
          if (state is ReportsError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<ReportsCubit>().load(),
            );
          }

          final summary = (state as ReportsLoaded).summary;
          return RefreshIndicator(
            onRefresh: () => context.read<ReportsCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                _GeneratedAtPill(time: summary.generatedAt),
                const SizedBox(height: 16),

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
                      label: 'Total users',
                      value: '${summary.totalUsers}',
                      icon: Icons.people_outline_rounded,
                      color: AppColors.primary,
                    ),
                    StatCard(
                      label: 'Total complaints',
                      value: '${summary.totalComplaints}',
                      icon: Icons.report_gmailerrorred_rounded,
                      color: AppColors.complaints,
                    ),
                    StatCard(
                      label: 'Total bookings',
                      value: '${summary.totalBookings}',
                      icon: Icons.meeting_room_outlined,
                      color: AppColors.venues,
                    ),
                    StatCard(
                      label: 'Booking approval rate',
                      value: '${(summary.bookingApprovalRate * 100).round()}%',
                      icon: Icons.verified_outlined,
                      color: AppColors.statusGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                const SectionHeader(
                  icon: Icons.report_gmailerrorred_rounded,
                  title: 'Complaints',
                ),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By status',
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
                const SizedBox(height: 14),
                HorizontalBarListCard(
                  title: 'By category',
                  maxItems: 7,
                  data: summary.complaintsByCategory.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key.displayName,
                          value: e.value,
                          color: e.key.color,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                HorizontalBarListCard(
                  title: 'By department',
                  maxItems: 7,
                  data: summary.complaintsByDepartment.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key,
                          value: e.value,
                          color: AppColors.primary,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 14),
                TrendChartCard(
                  title: 'Last 30 days',
                  data: summary.complaintsTrend30d,
                ),
                const SizedBox(height: 28),

                const SectionHeader(
                  icon: Icons.meeting_room_outlined,
                  title: 'Venue bookings',
                ),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By status',
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
                const SizedBox(height: 14),
                HorizontalBarListCard(
                  title: 'Most-booked venues',
                  maxItems: 5,
                  data: summary.bookingsByVenue.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key,
                          value: e.value,
                          color: AppColors.venues,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 28),

                const SectionHeader(
                  icon: Icons.people_outline_rounded,
                  title: 'Users',
                ),
                const SizedBox(height: 12),
                DonutChartCard(
                  title: 'By role',
                  data: summary.usersByRole.entries
                      .map(
                        (e) => ChartDatum(
                          label: e.key.displayName,
                          value: e.value,
                          color: e.key.color,
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
}

class _GeneratedAtPill extends StatelessWidget {
  final DateTime time;
  const _GeneratedAtPill({required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.update_rounded,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Generated ${formatDateTime(time)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
