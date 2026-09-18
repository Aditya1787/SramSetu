import 'package:flutter/material.dart';

/// Design tokens strictly utilizing the requested color palette:
/// - Base Background / Dark Surface: #1D1616
/// - Deep Crimson Accent / Depth:   #8E1616
/// - Vibrant Primary Red:            #D84040
/// - High-Contrast Off-White:        #EEEEEE
class AppColors {
  AppColors._();

  // User-specified primary palette
  static const Color background = Color(0xFF1D1616);
  static const Color accent = Color(0xFF8E1616);
  static const Color primary = Color(0xFFD84040);
  static const Color textPrimary = Color(0xFFEEEEEE);

  // Surface & Depth variations
  static const Color surface = Color(0xFF1D1616);
  static const Color surfaceLight = Color(0xFF261D1D);
  static const Color surfaceDark = Color(0xFF140F0F);

  // Secondary text & subtle tints
  static const Color textSecondary = Color(0xFFB5A8A8);
  static const Color textMuted = Color(0xFF7A6E6E);
  static const Color divider = Color(0xFF332525);

  // Neumorphic shadow tokens tuned for #1D1616
  static const Color shadowDark = Color(0xFF0D0909);
  static const Color shadowLight = Color(0xFF332424);
  static const Color shadowAccent = Color(0x668E1616);

  // Status & Utility
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE24F4F), Color(0xFF8E1616)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF251D1D), Color(0xFF181212)],
  );

  static const LinearGradient sunkenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF120E0E), Color(0xFF241C1C)],
  );
}
