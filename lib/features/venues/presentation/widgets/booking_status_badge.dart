import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/booking_status.dart';
import '../utils/booking_status_ui_extension.dart';

class BookingStatusBadge extends StatelessWidget {
  final BookingStatus status;
  const BookingStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 13, color: status.color),
          const SizedBox(width: 5),
          Text(
            status.displayName,
            style: AppTextStyles.caption.copyWith(
              color: status.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
