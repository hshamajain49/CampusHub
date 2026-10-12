import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/user_role.dart';

/// Maps UserRole -> label, colour and icon for UI display.
/// Kept separate from the Domain enum since Domain must stay Flutter-free.
extension UserRoleUiExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.departmentStaff:
        return 'Department Staff';
      case UserRole.venueCoordinator:
        return 'Venue Coordinator';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.departmentStaff:
        return 'Dept. Staff';
      case UserRole.venueCoordinator:
        return 'Coordinator';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Color get color {
    switch (this) {
      case UserRole.student:
        return AppColors.primary;
      case UserRole.departmentStaff:
        return AppColors.statusOrange;
      case UserRole.venueCoordinator:
        return AppColors.secondary;
      case UserRole.admin:
        return const Color(0xFF7C3AED);
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.student:
        return Icons.school_outlined;
      case UserRole.departmentStaff:
        return Icons.engineering_outlined;
      case UserRole.venueCoordinator:
        return Icons.event_available_outlined;
      case UserRole.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }
}
