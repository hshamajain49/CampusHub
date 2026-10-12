import 'package:flutter/material.dart';
import '../../domain/entities/complaint_category.dart';

/// Maps ComplaintCategory -> icon + colour for UI display.
/// Kept separate from the Domain enum since Domain must stay Flutter-free.
extension CategoryUiExtension on ComplaintCategory {
  IconData get icon {
    switch (this) {
      case ComplaintCategory.electrical:
        return Icons.electrical_services_outlined;
      case ComplaintCategory.plumbing:
        return Icons.plumbing_outlined;
      case ComplaintCategory.itNetwork:
        return Icons.wifi_outlined;
      case ComplaintCategory.furniture:
        return Icons.chair_outlined;
      case ComplaintCategory.cleanliness:
        return Icons.cleaning_services_outlined;
      case ComplaintCategory.civilInfrastructure:
        return Icons.foundation_outlined;
      case ComplaintCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ComplaintCategory.electrical:
        return const Color(0xFFE09B10);
      case ComplaintCategory.plumbing:
        return const Color(0xFF2F7BD8);
      case ComplaintCategory.itNetwork:
        return const Color(0xFF5B5BD6);
      case ComplaintCategory.furniture:
        return const Color(0xFFB0703A);
      case ComplaintCategory.cleanliness:
        return const Color(0xFF1F9D63);
      case ComplaintCategory.civilInfrastructure:
        return const Color(0xFF64748B);
      case ComplaintCategory.other:
        return const Color(0xFFE5654B);
    }
  }
}
