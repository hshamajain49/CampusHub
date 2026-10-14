import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Brand (matches the logo: navy -> teal) ---
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF172554);
  static const Color primaryLight = Color(0xFFE8EDFA);
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFFE1F4F1);
  static const Color accent = Color(0xFFF59E0B);
  static const Color splashBackground = Color(0xFF0B1633);

  // --- Neutrals ---
  static const Color background = Color(0xFFF4F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFF2F8);
  static const Color textPrimary = Color(0xFF141B2D);
  static const Color textSecondary = Color(0xFF5E6A82);
  static const Color textTertiary = Color(0xFF98A2B6);
  static const Color divider = Color(0xFFE4E8F1);

  // --- Status ---
  static const Color statusRed = Color(0xFFDC4A4A);
  static const Color statusOrange = Color(0xFFEA8A1E);
  static const Color statusYellow = Color(0xFFD9A10B);
  static const Color statusGreen = Color(0xFF1F9D63);
  static const Color error = statusRed;

  // --- Feature accents (used consistently for icons/tiles per module) ---
  static const Color complaints = Color(0xFFE5654B);
  static const Color venues = secondary;
  static const Color suggestions = accent;
  static const Color admin = primary;
  static const Color reports = Color(0xFF7C3AED);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF1B5C9C), secondary],
    stops: [0.0, 0.6, 1.0],
  );

  /// Darker variant of [color] for text drawn on a light tint of itself,
  /// keeping small labels (status pills, chips) readable.
  static Color onTint(Color color) => Color.lerp(color, Colors.black, 0.22)!;
}
