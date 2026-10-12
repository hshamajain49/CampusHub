import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/info_row.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../di/injection_container.dart';
import '../../domain/entities/complaint_status.dart';
import '../cubit/complaint_detail_cubit/complaint_detail_cubit.dart';
import '../cubit/complaint_detail_cubit/complaint_detail_state.dart';
import '../utils/category_ui_extension.dart';
import '../widgets/complaint_detail_sections.dart';

class ComplaintDetailPage extends StatelessWidget {
  final String complaintId;
  const ComplaintDetailPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ComplaintDetailCubit>()..load(complaintId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Complaint Details')),
        body: BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
          builder: (context, state) {
            if (state is ComplaintDetailLoading) {
              return const LoadingView();
            }
            if (state is ComplaintDetailError) {
              return ErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<ComplaintDetailCubit>().load(complaintId),
              );
            }

            final complaint = (state as ComplaintDetailLoaded).complaint;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                ComplaintHeaderCard(complaint: complaint),
                const SizedBox(height: 12),
                _StatusNote(
                  status: complaint.status,
                  department: complaint.assignedDepartment,
                ),
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
        ),
      ),
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
