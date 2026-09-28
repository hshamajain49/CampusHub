import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/complaint_entity.dart';
import '../../domain/entities/complaint_status.dart';
import '../cubit/complaint_detail_cubit/complaint_detail_cubit.dart';
import '../cubit/complaint_detail_cubit/complaint_detail_state.dart';
import '../cubit/complaint_status_action_cubit/complaint_status_action_cubit.dart';
import '../cubit/complaint_status_action_cubit/complaint_status_action_state.dart';
import '../widgets/status_badge.dart';

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
      backgroundColor: AppColors.background,
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is ComplaintDetailError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.bodySecondary,
                      ),
                    );
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

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(complaint.title, style: AppTextStyles.h1)),
                StatusBadge(status: complaint.status),
              ],
            ),
            const SizedBox(height: 20),
            Text('Reported by', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(complaint.studentName, style: AppTextStyles.body),
            const SizedBox(height: 16),
            Text('Category', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(complaint.category.displayName, style: AppTextStyles.body),
            if (complaint.location != null) ...[
              const SizedBox(height: 16),
              Text('Location', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(complaint.location!, style: AppTextStyles.body),
            ],
            if (complaint.description != null &&
                complaint.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Description', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(complaint.description!, style: AppTextStyles.body),
            ],
            const SizedBox(height: 16),
            Text('Reported', style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(_fmtDate(complaint.createdAt), style: AppTextStyles.body),
            if (complaint.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: complaint.imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      complaint.imageUrls[index],
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            _buildActionArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea(BuildContext context) {
    switch (complaint.status) {
      case ComplaintStatus.pendingReview:
      case ComplaintStatus.unassigned:
        return AppButton(
          label: 'Start Progress',
          isLoading: isSubmitting,
          onPressed: () => context
              .read<ComplaintStatusActionCubit>()
              .updateStatus(complaint.id, ComplaintStatus.inProgress),
        );
      case ComplaintStatus.inProgress:
        return AppButton(
          label: 'Mark Resolved',
          isLoading: isSubmitting,
          onPressed: () => context
              .read<ComplaintStatusActionCubit>()
              .updateStatus(complaint.id, ComplaintStatus.resolved),
        );
      case ComplaintStatus.resolved:
        return OutlinedButton(
          onPressed: isSubmitting
              ? null
              : () => context.read<ComplaintStatusActionCubit>().updateStatus(
                  complaint.id,
                  ComplaintStatus.inProgress,
                ),
          child: const Text('Reopen'),
        );
    }
  }
}
