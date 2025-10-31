import 'package:flutter/material.dart';

class AppColors {
  // 🌅 Unified background gradient for ALL screens
  static const Color bgTop = Color(0xFFFFB4C6);
  static const Color bgMid = Color(0xFFFFC8B9);
  static const Color bgBottom = Color(0xFFF6E2C9);

  // 🎨 General colors
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF6B6B6B);

  // 🌈 Accent colors
  static const Color accentPink = Color(0xFFFF6E9A);
  static const Color accentGreen = Color(0xFF2DBE7B);
  static const Color accentBlue = Color(0xFF4BA3FF);
  static const Color accentOrange = Color(0xFFFFB74D);
  static const Color accentPurple = Color(0xFFBD69C7); // 💜 added for activities/habits theme

  // 🧭 Navigation
  static const Color navInactive = Color(0xFF9D9D9D);
  static const Color navActive = accentPurple;

  // 🎯 Utility aliases for quick access
  static const Color primary = accentPurple;
  static const Color success = accentGreen;
  static const Color warning = accentOrange;
  static const Color info = accentBlue;
  static const Color error = accentPink;
}
