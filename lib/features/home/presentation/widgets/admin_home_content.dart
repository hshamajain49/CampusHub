import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../../../reports/presentation/cubit/reports_cubit.dart';
import '../../../reports/presentation/cubit/reports_state.dart';
import 'home_quick_actions.dart';
import 'quick_action_card.dart';

class AdminHomeContent extends StatelessWidget {
  const AdminHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..load(),
      child: BlocBuilder<ReportsCubit, ReportsState>(
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
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
                    label: 'Approval rate',
                    value: '${(summary.bookingApprovalRate * 100).round()}%',
                    icon: Icons.verified_outlined,
                    color: AppColors.statusGreen,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: 'Administration',
                subtitle: 'Manage people, spaces and insights',
                actionLabel: 'Admin panel',
                onAction: () => context.push('/admin'),
              ),
              const SizedBox(height: 14),
              QuickActionsRow(
                actions: [
                  QuickActionCard(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Users',
                    color: AppColors.primary,
                    onTap: () => context.push('/admin/users'),
                  ),
                  QuickActionCard(
                    icon: Icons.domain_rounded,
                    title: 'Venues',
                    color: AppColors.venues,
                    onTap: () => context.push('/admin/venues'),
                  ),
                  QuickActionCard(
                    icon: Icons.insights_rounded,
                    title: 'Reports',
                    color: const Color(0xFF7C3AED),
                    onTap: () => context.push('/admin/reports'),
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
                  HomeQuickActions.complaint(context),
                  HomeQuickActions.bookVenue(context),
                  HomeQuickActions.suggestions(context),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
