import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/booking_status.dart';

extension BookingStatusUiExtension on BookingStatus {
  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return AppColors.statusYellow;
      case BookingStatus.approved:
        return AppColors.statusGreen;
      case BookingStatus.rejected:
        return AppColors.statusRed;
      case BookingStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Icons.hourglass_empty_rounded;
      case BookingStatus.approved:
        return Icons.check_circle_outline_rounded;
      case BookingStatus.rejected:
        return Icons.cancel_outlined;
      case BookingStatus.cancelled:
        return Icons.block_rounded;
    }
  }
}
