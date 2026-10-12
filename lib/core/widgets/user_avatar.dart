import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Circle with the person's initials, tinted with [color].
class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color color;

  /// Solid white-on-colour variant (for gradient headers).
  final bool filled;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.color = AppColors.primary,
    this.filled = false,
  });

  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : color.withValues(alpha: 0.13),
      ),
      child: Text(
        initialsOf(name),
        style: GoogleFonts.poppins(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: filled ? Colors.white : AppColors.onTint(color),
        ),
      ),
    );
  }
}
