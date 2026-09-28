import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/complaint_category.dart';

class CategoryChip extends StatelessWidget {
  final ComplaintCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (category) {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.divider,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  category.displayName,
                  style: AppTextStyles.body.copyWith(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
