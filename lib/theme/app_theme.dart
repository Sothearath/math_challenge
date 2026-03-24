// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Dark palette ────────────────────────────────────────────────────────
  static const darkBg       = Color(0xFF0F1117);
  static const darkSurface  = Color(0xFF1C1E2A);
  static const darkCard     = Color(0xFF252836);
  static const darkBorder   = Color(0xFF333650);

  // Neon accents
  static const neonGreen    = Color(0xFF4ADE80);   // correct / mint
  static const neonBlue     = Color(0xFF38BDF8);
  static const neonPink     = Color(0xFFF472B6);
  static const neonYellow   = Color(0xFFFBBF24);
  static const neonOrange   = Color(0xFFFB923C);

  // ── Light palette ───────────────────────────────────────────────────────
  static const lightBg      = Color(0xFFF0F4FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard    = Color(0xFFE8EDFB);
  static const lightBorder  = Color(0xFFCDD5F3);

  // Brand accents (light)
  static const duoGreen     = Color(0xFF58CC02);   // Duolingo green
  static const duoGreenDark = Color(0xFF46A302);   // button shadow
  static const sunsetOrange = Color(0xFFFF6B35);
  static const heartRed     = Color(0xFFFF4B4B);
  static const heartRedDark = Color(0xFFCC2222);
  static const goldStar     = Color(0xFFFFD700);
  static const skyBlue      = Color(0xFF1CB0F6);
  static const skyBlueDark  = Color(0xFF0A91D4);

  // ── Semantic ────────────────────────────────────────────────────────────
  static const correct      = Color(0xFF58CC02);
  static const correctDark  = Color(0xFF46A302);
  static const wrong        = Color(0xFFFF4B4B);
  static const wrongDark    = Color(0xFFCC2222);

  // ── Level path colours (cycles) ─────────────────────────────────────────
  static const List<Color> levelColors = [
    Color(0xFF58CC02),
    Color(0xFF1CB0F6),
    Color(0xFFFF9600),
    Color(0xFFCE82FF),
    Color(0xFFFF4B4B),
    Color(0xFFFFD700),
  ];
  static const List<Color> levelColorsDark = [
    Color(0xFF46A302),
    Color(0xFF0A91D4),
    Color(0xFFCC7700),
    Color(0xFFAA55DD),
    Color(0xFFCC2222),
    Color(0xFFCCAA00),
  ];
}

class AppTheme {
  static TextTheme _text(TextTheme base) => GoogleFonts.nunitoTextTheme().copyWith(
    displayLarge: GoogleFonts.nunito(
        fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.5),
    displayMedium: GoogleFonts.nunito(
        fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
    titleLarge: GoogleFonts.nunito(
        fontSize: 22, fontWeight: FontWeight.w800),
    titleMedium: GoogleFonts.nunito(
        fontSize: 17, fontWeight: FontWeight.w700),
    bodyLarge: GoogleFonts.nunito(
        fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium: GoogleFonts.nunito(
        fontSize: 14, fontWeight: FontWeight.w500),
    labelLarge: GoogleFonts.nunito(
        fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),);


  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonGreen,
      secondary: AppColors.neonBlue,
      error: AppColors.heartRed,
      surface: AppColors.darkSurface,
    ),
    textTheme: _text(ThemeData.dark().textTheme),
    cardColor: AppColors.darkCard,
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.duoGreen,
      secondary: AppColors.skyBlue,
      error: AppColors.heartRed,
      surface: AppColors.lightSurface,
    ),
    textTheme: _text(ThemeData.light().textTheme),
    cardColor: AppColors.lightSurface,
  );
}
