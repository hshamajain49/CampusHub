import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/inline_empty_note.dart';
import '../../../../core/widgets/recent_item_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../../../complaints/presentation/cubit/staff_complaints_cubit/staff_complaints_cubit.dart';
import '../../../complaints/presentation/cubit/staff_complaints_cubit/staff_complaints_state.dart';
import '../../../complaints/presentation/utils/category_ui_extension.dart';
import '../../../complaints/presentation/utils/status_ui_extension.dart';
import 'home_quick_actions.dart';
import 'quick_action_card.dart';

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
            return const LoadingView();
          }
          if (state is StaffComplaintsError) {
            return ErrorState(message: state.message);
          }
          final loaded = state as StaffComplaintsLoaded;
          final recentActive = loaded.active.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Active complaints',
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
              const SizedBox(height: 28),
              const SectionHeader(
                title: 'Quick actions',
                subtitle: 'What would you like to do?',
              ),
              const SizedBox(height: 14),
              QuickActionsRow(
                actions: [
                  HomeQuickActions.complaint(context, detailed: true),
                  HomeQuickActions.suggestions(context, detailed: true),
                ],
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Needs attention',
                subtitle: department.isEmpty ? null : department,
                actionLabel: 'View all',
                onAction: () => context.push('/staff/complaints'),
              ),
              const SizedBox(height: 12),
              if (recentActive.isEmpty)
                const InlineEmptyNote(
                  message: 'No active complaints. Nice and quiet.',
                  icon: Icons.task_alt_rounded,
                )
              else
                Column(
                  children: recentActive.take(3).map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RecentItemTile(
                        icon: c.category.icon,
                        iconColor: c.category.color,
                        title: c.title,
                        subtitle: '${c.studentName} · ${timeAgo(c.createdAt)}',
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
