// lib/views/themes/style_simple/theme.dart
import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.transparent,
    primaryColor: AppColors.accentPink,
    fontFamily: 'Poppins',

    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.accentPink,
      unselectedItemColor: AppColors.navInactive,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Colors.white,
      elevation: 8,
    ),

    // keep non-const to avoid const-nesting headaches
    cardTheme: CardThemeData(
      // 0xEB = 92% alpha (replaces .withOpacity(.92))
      color: const Color(0xEBFFFFFF),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide.none,
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}
