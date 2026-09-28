import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/complaint_entity.dart';
import 'status_badge.dart';

class StaffComplaintCard extends StatelessWidget {
  final ComplaintEntity complaint;
  final VoidCallback onTap;
  const StaffComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: complaint.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(complaint.studentName, style: AppTextStyles.caption),
                  const SizedBox(width: 12),
                  Text(
                    complaint.category.displayName,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
              if (complaint.location != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(complaint.location!, style: AppTextStyles.caption),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Text(
                _formatDate(complaint.createdAt),
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
