import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
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

class StaffComplaintDetailPage extends StatelessWidget {
  final String complaintId;
  const StaffComplaintDetailPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ComplaintDetailCubit>()..load(complaintId),
        ),
        BlocProvider(create: (_) => sl<ComplaintStatusActionCubit>()),
      ],
      child: const _StaffComplaintDetailView(),
    );
  }
}

class _StaffComplaintDetailView extends StatelessWidget {
  const _StaffComplaintDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint')),
      body:
          BlocConsumer<ComplaintStatusActionCubit, ComplaintStatusActionState>(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Marked as ${actionState.complaint.status.displayName}.',
                    ),
                  ),
                );
                context.read<ComplaintDetailCubit>().load(
                  actionState.complaint.id,
                );
              }
            },
            builder: (context, actionState) {
              return BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
                builder: (context, state) {
                  if (state is ComplaintDetailLoading) {
                    return const LoadingView();
                  }
                  if (state is ComplaintDetailError) {
                    return ErrorState(message: state.message);
                  }
                  final complaint = (state as ComplaintDetailLoaded).complaint;
                  return _DetailBody(
                    complaint: complaint,
                    isSubmitting: actionState is ComplaintStatusActionLoading,
                  );
                },
              );
            },
          ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final ComplaintEntity complaint;
  final bool isSubmitting;
  const _DetailBody({required this.complaint, required this.isSubmitting});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              ComplaintHeaderCard(complaint: complaint),
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
                      icon: Icons.person_outline_rounded,
                      label: 'Reported by',
                      value: complaint.studentName,
                    ),
                    InfoRow(
                      icon: complaint.category.icon,
                      color: complaint.category.color,
                      label: 'Category',
                      value: complaint.category.displayName,
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
                      label: 'Reported',
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
          ),
        ),
        BottomActionBar(child: _buildActionArea(context)),
      ],
    );
  }

  Widget _buildActionArea(BuildContext context) {
    switch (complaint.status) {
      case ComplaintStatus.pendingReview:
      case ComplaintStatus.unassigned:
        return AppButton(
          label: 'Start Progress',
          icon: Icons.play_arrow_rounded,
          isLoading: isSubmitting,
          onPressed: () => context
              .read<ComplaintStatusActionCubit>()
              .updateStatus(complaint.id, ComplaintStatus.inProgress),
        );
      case ComplaintStatus.inProgress:
        return AppButton(
          label: 'Mark Work Done',
          icon: Icons.check_circle_outline_rounded,
          isLoading: isSubmitting,
          onPressed: () => context
              .read<ComplaintStatusActionCubit>()
              .updateStatus(complaint.id, ComplaintStatus.awaitingConfirmation),
        );
      case ComplaintStatus.awaitingConfirmation:
        // Final approval belongs to the reporter, not staff.
        return AppButton(
          label: 'Waiting for ${complaint.studentName} to approve',
          icon: Icons.rate_review_outlined,
          variant: AppButtonVariant.outlined,
          onPressed: null,
        );
      case ComplaintStatus.resolved:
        return AppButton(
          label: 'Reopen',
          icon: Icons.replay_rounded,
          variant: AppButtonVariant.outlined,
          isLoading: isSubmitting,
          onPressed: () => context
              .read<ComplaintStatusActionCubit>()
              .updateStatus(complaint.id, ComplaintStatus.inProgress),
        );
    }
  }
}
