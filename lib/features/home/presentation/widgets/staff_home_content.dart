import 'package:campus_hub/features/home/presentation/widgets/quick_action_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/inline_empty_note.dart';
import '../../../../core/widgets/recent_item_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../../../complaints/presentation/cubit/staff_complaints_cubit/staff_complaints_cubit.dart';
import '../../../complaints/presentation/cubit/staff_complaints_cubit/staff_complaints_state.dart';
import '../../../complaints/presentation/utils/status_ui_extension.dart';

class StaffHomeContent extends StatelessWidget {
  const StaffHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = sl<AuthStateCubit>().state;
    final department = authState is AuthAuthenticated
        ? (authState.user.department ?? '')
        : '';

    return BlocProvider(
      create: (_) => sl<StaffComplaintsCubit>()..load(department),
      child: BlocBuilder<StaffComplaintsCubit, StaffComplaintsState>(
        builder: (context, state) {
          if (state is StaffComplaintsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StaffComplaintsError) {
            return Center(child: Text(state.message));
          }
          final loaded = state as StaffComplaintsLoaded;
          final recentActive = loaded.active.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              if (department.isNotEmpty) ...[
                Text(
                  department,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Active Complaints',
                      value: '${loaded.active.length}',
                      icon: Icons.build_outlined,
                      color: AppColors.statusOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Resolved',
                      value: '${loaded.resolved.length}',
                      icon: Icons.check_circle_outline_rounded,
                      color: AppColors.statusGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                      // const SizedBox(width: 12),
                      // Expanded(
                      //   child: QuickActionCard(
                      //     icon: Icons.event_available_outlined,
                      //     title: 'Book Venue',
                      //     // subtitle: 'Reserve a space',
                      //     iconColor: Colors.blueAccent,
                      //     backgroundColor: const Color(0xFFF0F6FF),
                      //     onTap: () => context.push('/venues'),
                      //   ),
                      // ),
                      // const SizedBox(width: 12),
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
              const SizedBox(height: 24),
              SectionHeader(
                icon: Icons.build_outlined,
                title: 'Needs Attention',
                actionLabel: 'View all',
                onAction: () => context.push('/staff/complaints'),
              ),
              const SizedBox(height: 12),
              if (recentActive.isEmpty)
                const InlineEmptyNote(
                  message: 'No active complaints. Nice and quiet.',
                )
              else
                Column(
                  children: recentActive.take(3).map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RecentItemTile(
                        icon: Icons.build_outlined,
                        iconColor: AppColors.statusOrange,
                        title: c.title,
                        subtitle: c.studentName,
                        statusLabel: c.status.displayName,
                        statusColor: c.status.color,
                        onTap: () => context.push('/staff/complaint/${c.id}'),
                      ),
                    );
                  }).toList(),
                ),
            ],
          );
        },
      ),
    );
  }
}
