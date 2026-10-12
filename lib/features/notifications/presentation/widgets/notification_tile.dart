import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/icon_badge.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'new_booking_request':
        return Icons.event_note_outlined;
      case 'booking_approved':
        return Icons.event_available_rounded;
      case 'booking_rejected':
        return Icons.event_busy_rounded;
      case 'complaint_status':
        return Icons.report_gmailerrorred_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'new_booking_request':
        return AppColors.venues;
      case 'booking_approved':
        return AppColors.statusGreen;
      case 'booking_rejected':
        return AppColors.error;
      case 'complaint_status':
        return AppColors.complaints;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    final radius = BorderRadius.circular(AppRadius.lg);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFF7F9FF) : AppColors.surface,
        borderRadius: radius,
        border: Border.all(
          color: unread
              ? AppColors.primary.withValues(alpha: 0.18)
              : AppColors.divider.withValues(alpha: 0.8),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(
                  icon: _icon,
                  color: _iconColor,
                  size: 42,
                  circular: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTextStyles.title.copyWith(
                                fontSize: 14,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeAgo(notification.createdAt),
                            style: AppTextStyles.caption.copyWith(
                              color: unread
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notification.body,
                        style: AppTextStyles.bodySecondary.copyWith(
                          fontSize: 13,
                        ),
                      ),
                      if (notification.actionRoute != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'View details',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (unread)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8, top: 6),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
