import 'package:flutter/material.dart';

/// Gradient banner for a venue. Uses the venue photo when one exists,
/// otherwise a gradient picked deterministically from the venue id so each
/// venue keeps a recognisable colour across the app.
class VenueBanner extends StatelessWidget {
  final String seed;
  final String imageUrl;
  final double height;
  final double iconSize;
  final BorderRadius? borderRadius;
  final Widget? child;

  const VenueBanner({
    super.key,
    required this.seed,
    this.imageUrl = '',
    this.height = 96,
    this.iconSize = 44,
    this.borderRadius,
    this.child,
  });

  static const List<List<Color>> _palettes = [
    [Color(0xFF1E3A8A), Color(0xFF0D9488)],
    [Color(0xFF3730A3), Color(0xFF6D28D9)],
    [Color(0xFF0F766E), Color(0xFF15803D)],
    [Color(0xFF1D4ED8), Color(0xFF0891B2)],
    [Color(0xFFB45309), Color(0xFFDC2626)],
    [Color(0xFF334155), Color(0xFF1E3A8A)],
  ];

  static List<Color> paletteFor(String seed) {
    final hash = seed.codeUnits.fold<int>(
      0,
      (h, c) => (h * 31 + c) & 0x7fffffff,
    );
    return _palettes[hash % _palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = paletteFor(seed);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
              ),
            ),
            Positioned(
              right: -height * 0.25,
              top: -height * 0.35,
              child: Container(
                width: height * 1.3,
                height: height * 1.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                    width: height * 0.16,
                  ),
                ),
              ),
            ),
            Positioned(
              right: height * 0.28,
              bottom: height * 0.14,
              child: Icon(
                Icons.meeting_room_rounded,
                size: iconSize,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
