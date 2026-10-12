import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class AmenityChip extends StatelessWidget {
  final String label;
  final bool dense;
  const AmenityChip({super.key, required this.label, this.dense = false});

  IconData? get _icon {
    final l = label.toLowerCase();
    if (l.contains('projector')) return Icons.videocam_outlined;
    if (l.contains('board')) return Icons.edit_note_rounded;
    if (l == 'ac' || l.contains('air')) return Icons.ac_unit_rounded;
    if (l.contains('wifi') || l.contains('wi-fi')) return Icons.wifi_rounded;
    if (l.contains('mic') || l.contains('sound') || l.contains('speaker')) {
      return Icons.mic_none_rounded;
    }
    if (l.contains('stage')) return Icons.theater_comedy_outlined;
    if (l.contains('computer') || l.contains('pc')) {
      return Icons.computer_rounded;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final icon = dense ? null : _icon;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 12,
        vertical: dense ? 3 : 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: dense ? 0.08 : 0.1),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.onTint(AppColors.secondary)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.onTint(AppColors.secondary),
              fontWeight: FontWeight.w600,
              fontSize: dense ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
