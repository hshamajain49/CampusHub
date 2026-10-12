import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/booking_entity.dart';
import 'booking_status_badge.dart';
import 'venue_banner.dart';

/// Venue banner + name + status, shown at the top of booking detail pages.
class BookingHeaderCard extends StatelessWidget {
  final BookingEntity booking;
  const BookingHeaderCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VenueBanner(
            seed: booking.venueId,
            height: 84,
            iconSize: 36,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.venueName, style: AppTextStyles.h2),
                const SizedBox(height: 8),
                BookingStatusBadge(status: booking.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tinted callout used for rejection reasons and read-only notices.
class BookingNotice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? title;
  final String message;

  const BookingNotice({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.onTint(color);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppTextStyles.label.copyWith(color: textColor),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: AppTextStyles.body.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
