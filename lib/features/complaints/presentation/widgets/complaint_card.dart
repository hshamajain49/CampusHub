import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../domain/entities/complaint_entity.dart';
import '../utils/category_ui_extension.dart';
import 'status_badge.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintEntity complaint;
  final int index;

  /// Defaults to opening the student complaint detail page.
  final VoidCallback? onTap;

  /// Shows who reported the complaint (staff view).
  final bool showReporter;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.index,
    this.onTap,
    this.showReporter = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = complaint.category;
    return FadeSlideIn(
      index: index,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap ?? () => context.push('/complaint/${complaint.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(icon: category.icon, color: category.color, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.title,
                        style: AppTextStyles.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        showReporter
                            ? '${complaint.studentName} · ${category.displayName}'
                            : category.displayName,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Meta(
                    icon: complaint.location != null
                        ? Icons.location_on_outlined
                        : Icons.schedule_rounded,
                    text: complaint.location != null
                        ? '${complaint.location!} · ${timeAgo(complaint.createdAt)}'
                        : timeAgo(complaint.createdAt),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: complaint.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
