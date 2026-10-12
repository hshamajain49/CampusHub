import 'package:flutter/material.dart';

/// An icon on a soft tint of its own colour — the standard leading visual for
/// cards, list tiles and stats.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool circular;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.circular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}
