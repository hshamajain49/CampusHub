import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/segmented_tab_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state.dart';
import '../../domain/entities/complaint_entity.dart';
import '../cubit/staff_complaints_cubit/staff_complaints_cubit.dart';
import '../cubit/staff_complaints_cubit/staff_complaints_state.dart';
import '../widgets/staff_complaint_card.dart';

class StaffComplaintDashboardPage extends StatelessWidget {
  const StaffComplaintDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = sl<AuthStateCubit>().state;
    final department = authState is AuthAuthenticated
        ? (authState.user.department ?? '')
        : '';

    return BlocProvider(
      create: (_) => sl<StaffComplaintsCubit>()..load(department),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(department.isEmpty ? 'Manage Complaints' : department),
          ),
          body: BlocBuilder<StaffComplaintsCubit, StaffComplaintsState>(
            builder: (context, state) {
              if (state is StaffComplaintsLoading) {
                return const LoadingView();
              }
              if (state is StaffComplaintsError) {
                return ErrorState(message: state.message);
              }
              final loaded = state as StaffComplaintsLoaded;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    child: SegmentedTabBar(
                      tabs: [
                        SegmentedTab(
                          label: 'Active',
                          count: loaded.active.length,
                        ),
                        SegmentedTab(
                          label: 'Resolved',
                          count: loaded.resolved.length,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _ComplaintsList(
                          complaints: loaded.active,
                          emptyIcon: Icons.task_alt_rounded,
                          emptyTitle: 'Nice and quiet',
                          emptyMessage: 'There are no active complaints.',
                        ),
                        _ComplaintsList(
                          complaints: loaded.resolved,
                          emptyIcon: Icons.inventory_2_outlined,
                          emptyTitle: 'Nothing resolved yet',
                          emptyMessage:
                              'Resolved complaints will be listed here.',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ComplaintsList extends StatelessWidget {
  final List<ComplaintEntity> complaints;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  const _ComplaintsList({
    required this.complaints,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        color: AppColors.secondary,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: complaints.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return StaffComplaintCard(
          complaint: complaint,
          index: index,
          onTap: () => context.push('/staff/complaint/${complaint.id}'),
        );
      },
    );
  }
}
