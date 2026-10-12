import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../domain/entities/booking_entity.dart';
import 'booking_status_badge.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final int index;

  /// Defaults to opening the student booking detail page.
  final VoidCallback? onTap;

  /// Shows who requested the booking (coordinator view).
  final bool showRequester;

  const BookingCard({
    super.key,
    required this.booking,
    this.index = 0,
    this.onTap,
    this.showRequester = false,
  });

  String get _whenLabel {
    final time = booking.isFullDay
        ? 'Full day'
        : '${booking.startTime} – ${booking.endTime}';
    return '${formatDateRange(booking.startDate, booking.endDate)} · $time';
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      index: index,
      child: AppCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap ?? () => context.push('/booking/${booking.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingDateBlock(date: booking.startDate),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.venueName,
                    style: AppTextStyles.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    booking.purpose,
                    style: AppTextStyles.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showRequester) ...[
                    const SizedBox(height: 6),
                    _Meta(
                      icon: Icons.person_outline_rounded,
                      text: booking.studentName,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _Meta(icon: Icons.schedule_rounded, text: _whenLabel),
                  const SizedBox(height: 10),
                  BookingStatusBadge(status: booking.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Calendar-page style block showing month + day.
class BookingDateBlock extends StatelessWidget {
  final DateTime date;
  const BookingDateBlock({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            monthShort(date).toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: AppColors.secondary,
              fontSize: 10,
            ),
          ),
          Text(
            '${date.day}',
            style: AppTextStyles.h2.copyWith(
              color: AppColors.onTint(AppColors.secondary),
              height: 1.15,
            ),
          ),
        ],
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
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 5),
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
