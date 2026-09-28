import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../di/injection_container.dart';
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Approval Requests'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'History'),
              ],
            ),
          ),
          body:
              BlocBuilder<CoordinatorApprovalsCubit, CoordinatorApprovalsState>(
                builder: (context, state) {
                  if (state is CoordinatorApprovalsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is CoordinatorApprovalsError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.bodySecondary,
                      ),
                    );
                  }
                  final loaded = state as CoordinatorApprovalsLoaded;
                  return TabBarView(
                    children: [
                      _BookingsList(
                        bookings: loaded.pending,
                        emptyMessage: 'No pending requests right now.',
                      ),
                      _BookingsList(
                        bookings: loaded.history,
                        emptyMessage: 'No past decisions yet.',
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
  final List<dynamic> bookings;
  final String emptyMessage;
  const _BookingsList({required this.bookings, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: AppTextStyles.bodySecondary),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return ApprovalBookingCard(
          booking: booking,
          onTap: () => context.push('/approval/${booking.id}'),
        );
      },
    );
  }
}
