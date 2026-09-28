import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import '../cubit/booking_detail_cubit/booking_detail_cubit.dart';
import '../cubit/booking_detail_cubit/booking_detail_state.dart';
import '../cubit/approval_action_cubit/approval_action_cubit.dart';
import '../cubit/approval_action_cubit/approval_action_state.dart';
import '../widgets/booking_status_badge.dart';

class ApprovalDetailPage extends StatelessWidget {
  final String bookingId;
  const ApprovalDetailPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<BookingDetailCubit>()..load(bookingId)),
        BlocProvider(create: (_) => sl<ApprovalActionCubit>()),
      ],
      child: const _ApprovalDetailView(),
    );
  }
}

class _ApprovalDetailView extends StatelessWidget {
  const _ApprovalDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Booking Request')),
      body: BlocConsumer<ApprovalActionCubit, ApprovalActionState>(
        listener: (context, actionState) {
          if (actionState is ApprovalActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(actionState.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (actionState is ApprovalActionSuccess) {
            final verb = actionState.booking.status == BookingStatus.approved
                ? 'approved'
                : 'rejected';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Booking $verb.')));
            context.pop();
          }
        },
        builder: (context, actionState) {
          return BlocBuilder<BookingDetailCubit, BookingDetailState>(
            builder: (context, state) {
              if (state is BookingDetailLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is BookingDetailError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTextStyles.bodySecondary,
                  ),
                );
              }
              final booking = (state as BookingDetailLoaded).booking;
              return _DetailBody(
                booking: booking,
                isSubmitting: actionState is ApprovalActionLoading,
              );
            },
          );
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final BookingEntity booking;
  final bool isSubmitting;
  const _DetailBody({required this.booking, required this.isSubmitting});

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject booking'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Reason for rejection (required)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide a reason';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop();
              context.read<ApprovalActionCubit>().reject(
                booking.id,
                controller.text.trim(),
              );
            },
            child: Text('Reject', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _fmtDate(booking.startDate) == _fmtDate(booking.endDate)
        ? _fmtDate(booking.startDate)
        : '${_fmtDate(booking.startDate)} — ${_fmtDate(booking.endDate)}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(booking.venueName, style: AppTextStyles.h1),
                ),
                BookingStatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 20),
            Text('Requested by', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(booking.studentName, style: AppTextStyles.body),
            const SizedBox(height: 16),
            Text('Purpose', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(booking.purpose, style: AppTextStyles.body),
            const SizedBox(height: 16),
            Text('Date', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(dateLabel, style: AppTextStyles.body),
            const SizedBox(height: 16),
            Text('Time', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(
              booking.isFullDay
                  ? 'Full day'
                  : '${booking.startTime} - ${booking.endTime}',
              style: AppTextStyles.body,
            ),
            if (booking.status == BookingStatus.rejected &&
                booking.rejectionReason != null) ...[
              const SizedBox(height: 16),
              Text('Rejection reason', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(booking.rejectionReason!, style: AppTextStyles.body),
            ],
            if (booking.status == BookingStatus.pending) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () => _showRejectDialog(context),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Approve',
                      isLoading: isSubmitting,
                      onPressed: () => context
                          .read<ApprovalActionCubit>()
                          .approve(booking.id),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
