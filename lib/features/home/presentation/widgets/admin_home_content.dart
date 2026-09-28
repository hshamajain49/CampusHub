import 'package:campus_hub/features/home/presentation/widgets/quick_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../di/injection_container.dart';
import '../../../reports/presentation/cubit/reports_cubit.dart';
import '../../../reports/presentation/cubit/reports_state.dart';

class AdminHomeContent extends StatelessWidget {
  const AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..load(),
      child: BlocBuilder<ReportsCubit, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading || state is ReportsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportsError) {
            return Center(child: Text(state.message));
          }
          final summary = (state as ReportsLoaded).summary;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
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
                    label: 'Approval Rate',
                    value: '${(summary.bookingApprovalRate * 100).round()}%',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.statusGreen,
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/admin'),
                      icon: const Icon(Icons.admin_panel_settings_outlined),
                      label: const Text('Admin Panel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.push('/admin/reports'),
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: const Text('Full Report'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'What would you like to do?',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.report_problem_outlined,
                          title: 'Complaint',
                          // subtitle: 'Report an issue',
                          iconColor: Colors.redAccent,
                          backgroundColor: const Color(0xFFFFF1F1),
                          onTap: () => context.push('/new-complaint'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.event_available_outlined,
                          title: 'Book Venue',
                          // subtitle: 'Reserve a space',
                          iconColor: Colors.blueAccent,
                          backgroundColor: const Color(0xFFF0F6FF),
                          onTap: () => context.push('/venues'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.lightbulb_outline_rounded,
                          title: 'Suggestions',
                          // subtitle: 'Share your idea',
                          iconColor: Colors.amber.shade800,
                          backgroundColor: const Color(0xFFFFF8E7),
                          onTap: () => context.push('/suggestions'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
