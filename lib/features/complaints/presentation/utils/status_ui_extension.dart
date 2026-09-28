import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/complaint_status.dart';

/// Maps ComplaintStatus -> color + icon for UI display.
/// Kept separate from the Domain enum since Domain must stay Flutter-free.
extension StatusUiExtension on ComplaintStatus {
  Color get color {
    switch (this) {
      case ComplaintStatus.unassigned:
        return AppColors.statusRed;
      case ComplaintStatus.pendingReview:
        return AppColors.statusYellow;
      case ComplaintStatus.inProgress:
        return AppColors.statusOrange;
      case ComplaintStatus.resolved:
        return AppColors.statusGreen;
    }
  }

  IconData get icon {
    switch (this) {
      case ComplaintStatus.unassigned:
        return Icons.error_outline_rounded;
      case ComplaintStatus.pendingReview:
        return Icons.hourglass_empty_rounded;
      case ComplaintStatus.inProgress:
        return Icons.build_outlined;
      case ComplaintStatus.resolved:
        return Icons.check_circle_outline_rounded;
    }
  }
}
