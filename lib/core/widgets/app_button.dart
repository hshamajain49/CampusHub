import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppButtonVariant { primary, outlined, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = AppButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == AppButtonVariant.primary;
    final foreground = switch (variant) {
      AppButtonVariant.primary => Colors.white,
      AppButtonVariant.outlined => AppColors.primary,
      AppButtonVariant.danger => AppColors.error,
    };

    final Widget child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: foreground,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 19),
                  const SizedBox(width: 8),
                ],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );

    final onTap = isLoading ? null : onPressed;

    return SizedBox(
      width: double.infinity,
      child: isFilled
          ? ElevatedButton(onPressed: onTap, child: child)
          : OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: foreground,
                side: BorderSide(
                  color: variant == AppButtonVariant.danger
                      ? AppColors.error.withValues(alpha: 0.4)
                      : AppColors.divider,
                  width: 1.4,
                ),
              ),
              child: child,
            ),
    );
  }
}
