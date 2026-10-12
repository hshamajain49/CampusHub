import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/segmented_tab_bar.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/booking_entity.dart';
import '../cubit/coordinator_approvals_cubit/coordinator_approvals_cubit.dart';
import '../cubit/coordinator_approvals_cubit/coordinator_approvals_state.dart';
import '../widgets/approval_booking_card.dart';

class CoordinatorDashboardPage extends StatelessWidget {
  const CoordinatorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CoordinatorApprovalsCubit>(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(title: const Text('Approval Requests')),
          body:
              BlocBuilder<CoordinatorApprovalsCubit, CoordinatorApprovalsState>(
                builder: (context, state) {
                  if (state is CoordinatorApprovalsLoading) {
                    return const LoadingView();
                  }
                  if (state is CoordinatorApprovalsError) {
                    return ErrorState(message: state.message);
                  }
                  final loaded = state as CoordinatorApprovalsLoaded;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: SegmentedTabBar(
                          tabs: [
                            SegmentedTab(
                              label: 'Pending',
                              count: loaded.pending.length,
                            ),
                            SegmentedTab(
                              label: 'History',
                              count: loaded.history.length,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _BookingsList(
                              bookings: loaded.pending,
                              emptyIcon: Icons.task_alt_rounded,
                              emptyTitle: "You're all caught up",
                              emptyMessage: 'No pending requests right now.',
                            ),
                            _BookingsList(
                              bookings: loaded.history,
                              emptyIcon: Icons.history_rounded,
                              emptyTitle: 'No history yet',
                              emptyMessage:
                                  'Requests you approve or reject appear here.',
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

class _BookingsList extends StatelessWidget {
  final List<BookingEntity> bookings;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  const _BookingsList({
    required this.bookings,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        color: AppColors.venues,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return ApprovalBookingCard(
          booking: booking,
          index: index,
          onTap: () => context.push('/approval/${booking.id}'),
        );
      },
    );
  }
}
