import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const AppLogo({super.key, this.size = 88, this.showWordmark = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'CH',
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
                color: AppColors.surface,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        if (showWordmark) ...[
          SizedBox(height: size * 0.22),
          Text('CampusHub', style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text('Your Campus, Simplified.', style: AppTextStyles.bodySecondary),
        ],
      ],
    );
  }
}
