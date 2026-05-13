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
  static const neonGreen    = Color(0xFF4ADE80);
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
  static const duoGreen     = Color(0xFF58CC02);
  static const duoGreenDark = Color(0xFF46A302);
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

  // ── Spring Green Harmony (FlexiArithmetic dashboard) ────────────────────

  // Dark surfaces
  static const darkGreenBg       = Color(0xFF0D1F18);  // scaffold bg
  static const darkGreenCard     = Color(0xFF142B20);  // stat bar, bubble
  static const darkGreenCard2    = Color(0xFF1C3528);  // lighter card variant
  static const darkGreenDivider  = Color(0xFF1F3D2C);  // borders on dark

  // Mint accent
  static const mint              = Color(0xFF2ED1A2);  // CTA, accents, day dots
  static const mintDark          = Color(0xFF1BAC84);  // pressed / shadow
  static const mintGlow          = Color(0xFF6BEDD0);  // brain highlight lobe
  static const mintText          = Color(0xFF0A3D28);  // text ON mint surfaces
  static const mintDim           = Color(0xFF9EC4B0);  // muted text on dark bg
  static const mintFaint         = Color(0xFF4D7A62);  // very muted label text

  // Light surfaces (activity card, awards screen)
  static const greenLightBg      = Color(0xFFF5F7F5);
  static const greenLightCard    = Color(0xFFFFFFFF);
  static const greenLightDivider = Color(0xFFF0F0F0);

  // Streak badge
  static const streakBadgeBg    = Color(0xFFD4F2E7);
  static const streakBadgeText  = Color(0xFF0F5E42);

  // Score badges (avg / latest)
  static const badgeBg          = Color(0xFFF5F6F5);
  static const badgeLabel       = Color(0xFF999999);
  static const badgeNum         = Color(0xFF111111);
  static const badgeSub         = Color(0xFFBBBBBB);

  // Star (top score) badge
  static const starBadgeBg      = Color(0xFFFFF8E6);
  static const starBadgeText    = Color(0xFF7A4F08);
  static const starBadgeLabel   = Color(0xFFB47A15);
  static const starAmber        = Color(0xFFEF9F27);

  // Trophy / awards
  static const goldTrophy       = Color(0xFFFFD700);

  // Weekly day dot states
  static const dotDoneBg        = Color(0xFF111E17);
  static const dotMissBorder    = Color(0xFFDDEEDD);
  static const dotMissText      = Color(0xFFBBCCBB);
  static const dotDayLabel      = Color(0xFFAAAAAA);

  // Lavender (AwardsView trophy highlights, legacy Brainy v1 palette)
  static const lavender         = Color(0xFFC7A8FF);
  static const lavenderDark     = Color(0xFFA880FF);
  static const lavenderText     = Color(0xFF2D1B69);
}

class AppTheme {
  static TextTheme _text(TextTheme base) =>
      GoogleFonts.nunitoTextTheme(base).copyWith(
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
            fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      );

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