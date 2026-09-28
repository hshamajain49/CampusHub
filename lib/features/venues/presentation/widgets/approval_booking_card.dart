import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/booking_entity.dart';
import 'booking_status_badge.dart';

class ApprovalBookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onTap;
  const ApprovalBookingCard({
    super.key,
    required this.booking,
    required this.onTap,
  });

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String get _dateLabel {
    final start = _fmtDate(booking.startDate);
    final end = _fmtDate(booking.endDate);
    return start == end ? start : '$start — $end';
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
                      booking.venueName,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  BookingStatusBadge(status: booking.status),
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
                  Text(booking.studentName, style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                booking.purpose,
                style: AppTextStyles.bodySecondary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.date_range_outlined,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(_dateLabel, style: AppTextStyles.caption),
                  const SizedBox(width: 12),
                  Icon(
                    booking.isFullDay
                        ? Icons.wb_sunny_outlined
                        : Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking.isFullDay
                        ? 'Full day'
                        : '${booking.startTime} - ${booking.endTime}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
