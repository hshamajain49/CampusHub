import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/complaint_entity.dart';
import '../../domain/entities/complaint_status.dart';
import '../cubit/complaint_detail_cubit/complaint_detail_cubit.dart';
import '../cubit/complaint_detail_cubit/complaint_detail_state.dart';
import '../cubit/complaint_status_action_cubit/complaint_status_action_cubit.dart';
import '../cubit/complaint_status_action_cubit/complaint_status_action_state.dart';
import '../utils/category_ui_extension.dart';
import '../widgets/complaint_detail_sections.dart';

class ComplaintDetailPage extends StatelessWidget {
  final String complaintId;
  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ComplaintDetailCubit>()..load(complaintId),
        ),
        BlocProvider(create: (_) => sl<ComplaintStatusActionCubit>()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body:
            BlocConsumer<
              ComplaintStatusActionCubit,
              ComplaintStatusActionState
            >(
              listener: (context, actionState) {
                if (actionState is ComplaintStatusActionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(actionState.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
                if (actionState is ComplaintStatusActionSuccess) {
                  final resolved =
                      actionState.complaint.status == ComplaintStatus.resolved;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        resolved
                            ? 'Thanks! The complaint is now resolved.'
                            : 'Sent back to the department for more work.',
                      ),
                    ),
                  );
                  context.read<ComplaintDetailCubit>().load(complaintId);
                }
              },
              builder: (context, actionState) {
                return BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
                  builder: (context, state) {
                    if (state is ComplaintDetailLoading) {
                      return const LoadingView();
                    }
                    if (state is ComplaintDetailError) {
                      return ErrorState(
                        message: state.message,
                        onRetry: () => context
                            .read<ComplaintDetailCubit>()
                            .load(complaintId),
                      );
                    }

                    final complaint =
                        (state as ComplaintDetailLoaded).complaint;

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: [
                        ComplaintHeaderCard(complaint: complaint),
                        const SizedBox(height: 12),
                        if (complaint.status ==
                            ComplaintStatus.awaitingConfirmation)
                          _ReviewCard(
                            complaint: complaint,
                            isSubmitting:
                                actionState is ComplaintStatusActionLoading,
                          )
                        else
                          _StatusNote(
                            status: complaint.status,
                            department: complaint.assignedDepartment,
                          ),
                        if (complaint.status == ComplaintStatus.inProgress &&
                            complaint.rejectionReason != null) ...[
                          const SizedBox(height: 12),
                          RejectionNote(reason: complaint.rejectionReason!),
                        ],
                        const SizedBox(height: 16),
                        SectionCard(
                          title: 'Details',
                          child: Column(
                            children: [
                              InfoRow(
                                icon: complaint.category.icon,
                                color: complaint.category.color,
                                label: 'Category',
                                value: complaint.category.displayName,
                              ),
                              InfoRow(
                                icon: Icons.apartment_rounded,
                                label: 'Assigned to',
                                value: complaint.assignedDepartment,
                              ),
                              if (complaint.location != null)
                                InfoRow(
                                  icon: Icons.location_on_outlined,
                                  color: AppColors.secondary,
                                  label: 'Location',
                                  value: complaint.location!,
                                ),
                              InfoRow(
                                icon: Icons.schedule_rounded,
                                color: AppColors.textSecondary,
                                label: 'Submitted',
                                value: formatDateTime(complaint.createdAt),
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        if (complaint.description != null &&
                            complaint.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          SectionCard(
                            title: 'Description',
                            child: Text(
                              complaint.description!,
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                        if (complaint.imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ComplaintPhotos(imageUrls: complaint.imageUrls),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
      ),
    );
  }
}

/// Lets the reporter give the final say once staff mark the work done.
class _ReviewCard extends StatelessWidget {
  final ComplaintEntity complaint;
  final bool isSubmitting;
  const _ReviewCard({required this.complaint, required this.isSubmitting});

  Future<void> _reject(BuildContext context) async {
    final cubit = context.read<ComplaintStatusActionCubit>();
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _RejectDialog(),
    );
    if (reason == null) return;
    cubit.reviewResolution(complaint.id, approved: false, reason: reason);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Review the work',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'The ${complaint.assignedDepartment} says this is fixed. '
            'Is the issue resolved to your satisfaction?',
            style: AppTextStyles.body,
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Approve',
            icon: Icons.thumb_up_alt_outlined,
            isLoading: isSubmitting,
            onPressed: isSubmitting
                ? null
                : () => context
                      .read<ComplaintStatusActionCubit>()
                      .reviewResolution(complaint.id, approved: true),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Reject',
            icon: Icons.thumb_down_alt_outlined,
            variant: AppButtonVariant.danger,
            onPressed: isSubmitting ? null : () => _reject(context),
          ),
        ],
      ),
    );
  }
}

/// Asks why the work isn't satisfactory. Resolves to the reason, or null
/// when cancelled.
class _RejectDialog extends StatefulWidget {
  const _RejectDialog();

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _controller.text.trim().isNotEmpty;
    return AlertDialog(
      title: const Text('What still needs fixing?'),
      scrollable: true,
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLines: 3,
        maxLength: 300,
        decoration: const InputDecoration(
          hintText: 'e.g. The projector still flickers',
        ),
        onChanged: (_) => setState(() {}),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: canSubmit
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: const Text('Reject'),
        ),
      ],
    );
  }
}

/// A one-line, plain-language explanation of where the complaint stands.
class _StatusNote extends StatelessWidget {
  final ComplaintStatus status;
  final String department;
  const _StatusNote({required this.status, required this.department});

  @override
  Widget build(BuildContext context) {
    final (icon, color, text) = switch (status) {
      ComplaintStatus.pendingReview || ComplaintStatus.unassigned => (
        Icons.hourglass_top_rounded,
        AppColors.statusYellow,
        'Waiting for the $department to pick this up.',
      ),
      ComplaintStatus.inProgress => (
        Icons.construction_rounded,
        AppColors.statusOrange,
        'The $department is working on it.',
      ),
      // Shown as _ReviewCard instead; kept for exhaustiveness.
      ComplaintStatus.awaitingConfirmation => (
        Icons.rate_review_outlined,
        AppColors.primary,
        'The $department marked this as done. Please review it.',
      ),
      ComplaintStatus.resolved => (
        Icons.celebration_outlined,
        AppColors.statusGreen,
        'This issue has been resolved. Thanks for reporting it!',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.onTint(color)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(
                color: AppColors.onTint(color),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
