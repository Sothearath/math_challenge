// lib/core/theme/app_theme.dart
//
// AppTheme wires AppColors into Flutter's ThemeData and exposes
// reusable decoration helpers for widgets.
//
// Rules:
//   • No hex literals here — every color comes from AppColors.
//   • Widgets import AppColors for one-off colors (e.g. AppColors.mint).
//   • Widgets import AppTheme for shared decorations and radii
//     (e.g. AppTheme.cardShadows, AppTheme.radiusCard).
//
// Usage in main.dart:
//   MaterialApp(theme: AppTheme.light, ...)
//
// Usage in a widget:
//   Container(decoration: AppTheme.gradientBackground)
//   Text('hi', style: TextStyle(color: AppColors.cobalt))

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

abstract class AppTheme {
  AppTheme._();

  // ── Border radii ──────────────────────────────────────────────────────────
  static const double radiusCard    = 24.0;
  static const double radiusButton  = 20.0;
  static const double radiusInput   = 20.0;
  static const double radiusKey     = 18.0;
  static const double radiusPill    = 20.0;
  static const double radiusDialog  = 28.0;
  static const double radiusBadge   = 20.0;

  // ── Gradients ─────────────────────────────────────────────────────────────

  /// Game screen background — Aqua Teal → Soft Sky Blue.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gradientTop, AppColors.gradientBottom],
  );

  /// Progress bar fill — Sunflower → lighter Sunflower.
  static const LinearGradient progressGradient = LinearGradient(
    colors: [AppColors.sunflower, AppColors.sunflowerLight],
  );

  /// Submit-button gradient — Cobalt → lighter Cobalt.
  static const LinearGradient submitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cobalt, AppColors.cobaltLight],
  );

  /// Submit-button gradient — pressed state (darker).
  static const LinearGradient submitGradientPressed = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cobalt, AppColors.cobaltDark],
  );

  // ── BoxDecoration helpers ─────────────────────────────────────────────────

  /// Full-screen game gradient — wrap the Scaffold body with this.
  static BoxDecoration get gradientBackground =>
      const BoxDecoration(gradient: backgroundGradient);

  /// White card with cobalt drop shadow.
  static BoxDecoration get card => BoxDecoration(
    color: AppColors.keyWhite,
    borderRadius: BorderRadius.circular(radiusCard),
    boxShadow: cardShadows,
  );

  /// White answer-field — normal state.
  static BoxDecoration get answerField => BoxDecoration(
    color: AppColors.keyWhite,
    borderRadius: BorderRadius.circular(radiusInput),
    border: Border.all(
        color: AppColors.cobalt.withOpacity(0.20), width: 1.5),
    boxShadow: cardShadows,
  );

  /// White answer-field — combo-active state (green glow).
  static BoxDecoration get answerFieldCombo => BoxDecoration(
    color: AppColors.keyWhite,
    borderRadius: BorderRadius.circular(radiusInput),
    border: Border.all(color: AppColors.correctGreen, width: 2.5),
    boxShadow: correctGlow,
  );

  // ── Shadow lists ──────────────────────────────────────────────────────────

  static List<BoxShadow> get cardShadows => const [
    BoxShadow(
      color: AppColors.cobaltShadow16,
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get keyShadows => const [
    BoxShadow(
      color: AppColors.cobaltShadow18,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get submitShadow => const [
    BoxShadow(
      color: AppColors.cobaltShadow40,
      blurRadius: 12,
      offset: Offset(0, 5),
    ),
  ];

  static List<BoxShadow> get progressGlow => const [
    BoxShadow(
      color: AppColors.sunflowerGlow45,
      blurRadius: 8,
    ),
  ];

  static List<BoxShadow> get correctGlow => const [
    BoxShadow(
      color: AppColors.correctGlow40,
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get mintCTAGlow => const [
    BoxShadow(
      color: AppColors.mintGlow30,
      blurRadius: 28,
      spreadRadius: 4,
    ),
  ];

  // ── ThemeData ─────────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.cobalt,
        primary:   AppColors.cobalt,
        secondary: AppColors.sunflower,
        surface:   AppColors.keyWhite,
        brightness: Brightness.light,
      ),
    );

    return base.copyWith(
      // Scaffold colour is overridden per-screen with the gradient container.
      // Set a neutral fallback so nothing flashes on load.
      scaffoldBackgroundColor: AppColors.gradientTop,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Nunito for all text; colors follow AppColors.
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge:  GoogleFonts.nunito(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.cobalt),
        displayMedium: GoogleFonts.nunito(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.cobalt),
        headlineLarge: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.cobalt),
        headlineMedium:GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.cobalt),
        titleLarge:    GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.cobalt),
        bodyLarge:     GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.cobalt),
        bodyMedium:    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.cobalt),
        labelLarge:    GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.cobalt),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cobalt,
          foregroundColor: AppColors.keyWhite,
          elevation: 4,
          shadowColor: AppColors.cobaltShadow40,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cobalt,
          side: BorderSide(color: AppColors.cobalt.withOpacity(0.4), width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.keyWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: AppColors.cobalt.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: BorderSide(color: AppColors.cobalt.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusInput),
          borderSide: const BorderSide(color: AppColors.cobalt, width: 2),
        ),
        hintStyle: GoogleFonts.nunito(
            color: AppColors.cobalt.withOpacity(0.35),
            fontWeight: FontWeight.w600),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      cardTheme: CardThemeData(
        color: AppColors.keyWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard)),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.keyWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusDialog)),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sunflower,
        linearTrackColor: AppColors.cobaltShadow16,
      ),
    );
  }

  // ── Dashboard ThemeData (dark) ────────────────────────────────────────────
  // Used by BrainyDashboardView — keeps the dark mint aesthetic
  // while sharing the same Nunito text styles.

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.mint,
        primary:   AppColors.mint,
        secondary: AppColors.sunflower,
        surface:   AppColors.darkCard,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
        titleLarge:    GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
        bodyLarge:     GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.mintDim),
        bodyMedium:    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.mintFaint),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: AppColors.mintText,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusButton)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusCard)),
        margin: EdgeInsets.zero,
      ),
    );
  }
}