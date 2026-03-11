// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Dark palette
  static const darkBg = Color(0xFF0D0D0F);
  static const darkSurface = Color(0xFF1A1A1F);
  static const darkCard = Color(0xFF242429);
  static const neonGreen = Color(0xFF00F5A0);
  static const neonBlue = Color(0xFF00C9FF);
  static const neonPink = Color(0xFFFF2D78);
  static const neonYellow = Color(0xFFFFE000);

  // Light palette
  static const lightBg = Color(0xFFF5F5F7);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFEEEEF2);
  static const accentBlue = Color(0xFF0071E3);
  static const accentGreen = Color(0xFF34C759);
  static const accentRed = Color(0xFFFF3B30);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonGreen,
          secondary: AppColors.neonBlue,
          error: AppColors.neonPink,
          surface: AppColors.darkSurface,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme,
        ),
        cardColor: AppColors.darkCard,
        dividerColor: Colors.white12,
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accentBlue,
          secondary: AppColors.accentGreen,
          error: AppColors.accentRed,
          surface: AppColors.lightSurface,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.light().textTheme,
        ),
        cardColor: AppColors.lightCard,
        dividerColor: Colors.black12,
      );
}
