import 'package:flutter/material.dart';
import 'colors.dart';



class AppText {
  static const TextStyle greeting = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    height: 1.2,
  );

  static const TextStyle tinyDate = TextStyle(
    fontSize: 12,
    color: Colors.white70,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle smallMuted = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle chipBold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
