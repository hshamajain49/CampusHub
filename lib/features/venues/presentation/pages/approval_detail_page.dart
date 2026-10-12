import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/booking_status.dart';
import '../cubit/booking_detail_cubit/booking_detail_cubit.dart';
import '../cubit/booking_detail_cubit/booking_detail_state.dart';
import '../cubit/approval_action_cubit/approval_action_cubit.dart';
import '../cubit/approval_action_cubit/approval_action_state.dart';
import '../utils/booking_status_ui_extension.dart';
import '../widgets/booking_header_card.dart';

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
                return const LoadingView();
              }
              if (state is BookingDetailError) {
                return ErrorState(message: state.message);
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

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject booking'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${booking.studentName} will see this reason.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: controller,
                maxLines: 3,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Reason for rejection (required)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a reason';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(0, 44),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.of(dialogContext).pop();
              context.read<ApprovalActionCubit>().reject(
                booking.id,
                controller.text.trim(),
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPending = booking.status == BookingStatus.pending;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              BookingHeaderCard(booking: booking),
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    UserAvatar(name: booking.studentName, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Requested by', style: AppTextStyles.caption),
                          Text(booking.studentName, style: AppTextStyles.title),
                        ],
                      ),
                    ),
                    Text(
                      formatDate(booking.createdAt),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Details',
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.edit_calendar_outlined,
                      label: 'Purpose',
                      value: booking.purpose,
                    ),
                    InfoRow(
                      icon: Icons.date_range_outlined,
                      color: AppColors.venues,
                      label: 'Date',
                      value: formatDateRange(
                        booking.startDate,
                        booking.endDate,
                      ),
                    ),
                    InfoRow(
                      icon: Icons.schedule_rounded,
                      color: AppColors.venues,
                      label: 'Time',
                      value: booking.isFullDay
                          ? 'Full day'
                          : '${booking.startTime} – ${booking.endTime}',
                      isLast: true,
                    ),
                  ],
                ),
              ),
              if (booking.status == BookingStatus.rejected &&
                  booking.rejectionReason != null) ...[
                const SizedBox(height: 12),
                BookingNotice(
                  icon: Icons.info_outline_rounded,
                  color: booking.status.color,
                  title: 'Rejection reason',
                  message: booking.rejectionReason!,
                ),
              ],
            ],
          ),
        ),
        if (isPending)
          BottomActionBar(
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Reject',
                    icon: Icons.close_rounded,
                    variant: AppButtonVariant.danger,
                    onPressed: isSubmitting
                        ? null
                        : () => _showRejectDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Approve',
                    icon: Icons.check_rounded,
                    isLoading: isSubmitting,
                    onPressed: () =>
                        context.read<ApprovalActionCubit>().approve(booking.id),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
