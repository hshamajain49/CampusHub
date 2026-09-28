import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state_cubit.dart';
import '../../../auth/presentation/cubit/auth_state_cubit/auth_state.dart';
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(department.isEmpty ? 'Manage Complaints' : department),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Active'),
                Tab(text: 'Resolved'),
              ],
            ),
          ),
          body: BlocBuilder<StaffComplaintsCubit, StaffComplaintsState>(
            builder: (context, state) {
              if (state is StaffComplaintsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is StaffComplaintsError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      state.message,
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final loaded = state as StaffComplaintsLoaded;
              return TabBarView(
                children: [
                  _ComplaintsList(
                    complaints: loaded.active,
                    emptyMessage: 'No active complaints. Nice and quiet.',
                  ),
                  _ComplaintsList(
                    complaints: loaded.resolved,
                    emptyMessage: 'Nothing resolved yet.',
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
  final List<dynamic> complaints;
  final String emptyMessage;
  const _ComplaintsList({required this.complaints, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (complaints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            emptyMessage,
            style: AppTextStyles.bodySecondary,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: complaints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return StaffComplaintCard(
          complaint: complaint,
          onTap: () => context.push('/staff/complaint/${complaint.id}'),
        );
      },
    );
  }
}
