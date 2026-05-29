// lib/core/constants.dart
//
// FlexiArithmetic: Brainy Challenge
// Single source of truth for route names, storage keys, brand colors,
// and layout constants.  No logic lives here — only const values.

import 'package:flutter/material.dart';

// ─── App identity ─────────────────────────────────────────────────────────────

abstract class AppInfo {
  AppInfo._();
  static const name        = 'FlexiArithmetic';
  static const subtitle    = 'Brainy Challenge';
  static const fullName    = 'FlexiArithmetic: Brainy Challenge';
  static const mascotName  = 'Brainy';
  static const version     = '1.0.0';
}

// ─── Routes ───────────────────────────────────────────────────────────────────

abstract class Routes {
  Routes._();

  static const dashboard      = '/';
  static const game           = '/game';
  static const result         = '/result';
  static const levelMap       = '/level-map';
  static const gameMap        = '/game-map';
  static const dailyChallenge = '/daily-challenge';
  static const awards         = '/awards';
  static const settings       = '/settings';
}

// ─── Storage keys ─────────────────────────────────────────────────────────────

abstract class StorageKeys {
  StorageKeys._();

  // Game progress
  static const currentLevel      = 'current_level';
  static const hearts            = 'hearts';
  static const bestResult        = 'best_result';       // int: correct answers
  static const lastResult        = 'last_result';       // int: correct answers
  static const totalQuestions    = 'total_questions';   // int: denominator
  static const mathSessionHistory = 'math_session_history'; // List<Map>

  // Dashboard stats
  static const trainingMinutes   = 'training_minutes';  // int
  static const difficultyPct     = 'difficulty_pct';    // int 5–100 (Complexity)
  static const conditionSecs     = 'condition_secs';    // int (legacy; now Focus Score)
  static const avgAccuracy = 'avg_accuracy'; // int 0–100 (rolling EMA %)
  // Streak
  static const currentStreak    = 'current_streak';    // int
  static const lastStreakDate   = 'last_streak_date';  // String yyyy-MM-dd

  // Daily challenge
  static const dailyCompleted   = 'daily_completed_count';
  static const lastDailyMonth   = 'last_daily_month';  // 'yyyy-M'
  static const lastDailyDay     = 'last_daily_day';    // 'yyyy-MM-dd'
  static const weeklyDays       = 'weekly_completed_days'; // List<String>

  // Awards
  static const monthlyTrophies  = 'monthly_trophies';  // List<Map>

  // Theme
  static const isDarkMode       = 'is_dark_mode';
}

// ─── Spring Green Harmony palette ────────────────────────────────────────────
//
// All views reference AppColors.* — never a raw hex literal.
// Dark surface tokens are for the main dashboard scaffold.
// Light surface tokens are for the white activity card and awards screen.

abstract class AppColors {
  AppColors._();

  // ── A. Dark surfaces (dashboard scaffold) ─────────────────────────────────
  static const darkBg        = Color(0xFF0D1F18);
  static const darkCard      = Color(0xFF142B20);
  static const darkCard2     = Color(0xFF1C3528);
  static const darkDivider   = Color(0xFF1F3D2C);

  // ── B. Mint accent (dashboard CTA, progress, Brainy) ─────────────────────
  static const mint          = Color(0xFF2ED1A2);
  static const mintDark      = Color(0xFF1BAC84);
  static const mintGlow      = Color(0xFF6BEDD0);
  static const mintText      = Color(0xFF0A3D28);
  static const mintDim       = Color(0xFF9EC4B0);
  static const mintFaint     = Color(0xFF4D7A62);

  // ── Brainy mascot character colours ──────────────────────────────────────
  /// Brainy's body green — intentionally distinct from `mint` so the
  /// character can be recoloured independently of UI chrome.
  static const brainyBody    = Color(0xFF00C896);

  /// Brainy's deepest shadow — inner detail, eye pupils, frown path.
  static const brainyDark    = Color(0xFF0D1F18); // reuses darkBg

  // ── C. Light surfaces (activity card, awards, dashboard card) ─────────────
  static const lightBg       = Color(0xFFF5F7F5);
  static const lightCard     = Colors.white;
  static const lightDivider  = Color(0xFFF0F0F0);

  // ── D. Playful Citrus & Sky (game screen palette) ─────────────────────────

  /// Brainy Yellow — stars, milestones, numpad press-pulse, XP counter.
  static const sunflower     = Color(0xFFFFB61D);

  /// Sunflower highlight — lighter end of the progress-bar gradient.
  static const sunflowerLight = Color(0xFFFFD55A);

  /// Cobalt Blue — equation text, numpad digits, submit button, titles.
  static const cobalt        = Color(0xFF2A65A9);

  /// Cobalt light — lighter end of the submit-button gradient.
  static const cobaltLight   = Color(0xFF3578C8);

  /// Cobalt dark — pressed state of the submit button.
  static const cobaltDark    = Color(0xFF1A4E8A);

  /// Aqua Teal — top of the game-screen background gradient.
  static const gradientTop   = Color(0xFF6AD7C5);

  /// Soft Sky Blue — bottom of the game-screen background gradient.
  static const gradientBottom = Color(0xFF68B2F4);

  /// Deeper Sky Blue — pressed/shadow state of gradientBottom,
  /// also used as the VS Machine button shadow.
  static const gradientBottomDark = Color(0xFF4A90D9);

  /// Crisp white — numpad key surface, equation card, answer field.
  static const keyWhite      = Color(0xFFFFFFFF);

  /// Correct green — combo-active border glow on the answer field.
  static const correctGreen  = Color(0xFF34C759);

  // ── E. Semantic / shared ──────────────────────────────────────────────────
  static const heartRed      = Color(0xFFEF4444);
  static const heartDanger   = Color(0xFFFF3B30);
  static const streakGreen   = Color(0xFF0F5E42);
  static const streakBg      = Color(0xFFD4F2E7);
  static const goldTrophy    = Color(0xFFFFD700);
  static const starAmber     = Color(0xFFEF9F27);
  static const starBg        = Color(0xFFFFF8E6);
  static const starText      = Color(0xFF7A4F08);
  static const starLabel     = Color(0xFFB47A15);
  static const errorRed      = Color(0xFFDC2626);

  // ── F. Text & card surfaces ───────────────────────────────────────────────
  static const cardTitle     = Color(0xFF111111);
  static const badgeBg       = Color(0xFFF5F6F5);
  static const badgeLabel    = Color(0xFF999999);
  static const badgeNum      = Color(0xFF111111);
  static const badgeSub      = Color(0xFFBBBBBB);

  // ── G. Day dot states ─────────────────────────────────────────────────────
  static const dotDoneBg     = Color(0xFF111E17);
  static const dotMissBorder = Color(0xFFDDEEDD);
  static const dotMissText   = Color(0xFFBBCCBB);
  static const dotDayLabel   = Color(0xFFAAAAAA);

  // ── H. Shadows (pre-computed with opacity for BoxShadow) ──────────────────
  static const cobaltShadow16  = Color(0x292A65A9);
  static const cobaltShadow18  = Color(0x2E2A65A9);
  static const cobaltShadow40  = Color(0x662A65A9);
  static const sunflowerGlow45 = Color(0x73FFB61D);
  static const correctGlow40   = Color(0x6634C759);
  static const mintGlow30      = Color(0x4D2ED1A2);

  // ── I. On-gradient text ───────────────────────────────────────────────────
  /// White @ 75% — muted labels on the Aqua→Sky gradient background.
  static const mutedOnGrad    = Color(0xBFFFFFFF);

  // ── J. Level-map node palette ─────────────────────────────────────────────
  static const List<Color> levelColors = [
    Color(0xFF2A65A9), // cobalt        — Level 1
    Color(0xFF00C896), // mint-green    — Level 2
    Color(0xFFFFB61D), // sunflower     — Level 3
    Color(0xFFFF6B6B), // coral         — Level 4
    Color(0xFF9C6FDE), // violet        — Level 5
    Color(0xFF34C759), // correct-green — Level 6
    Color(0xFF6AD7C5), // aqua teal     — Level 7
    Color(0xFFFF9500), // orange        — Level 8
  ];

  static const List<Color> levelColorsDark = [
    Color(0xFF1A4E8A), // cobalt dark
    Color(0xFF1BAC84), // mint dark
    Color(0xFFCC8E00), // sunflower dark
    Color(0xFFCC3333), // coral dark
    Color(0xFF7A50B8), // violet dark
    Color(0xFF1E8A3A), // green dark
    Color(0xFF3DB5A5), // teal dark
    Color(0xFFCC6A00), // orange dark
  ];
}

// ─── Dashboard stat labels ─────────────────────────────────────────────────────
//
// Math-specific terminology — referenced by _StatCell in the view.

abstract class DashboardLabels {
  DashboardLabels._();

  static const trainingTime = 'Training time';  // minutes per session
  static const complexity   = 'Complexity';     // difficulty tier 5–100%
  static const focusScore   = 'Focus score';    // accuracy × speed index

  // Activity card badges
  static const avgAccuracy    = 'Avg accuracy';
  static const topScore       = 'Top score';
  static const latestSession  = 'Latest session';

  // Badge sub-labels
  static const equations      = 'equations';
  static const correct        = 'correct';
  static const personalBest   = 'personal best';

  // CTA button
  static const beginChallenge = 'Begin challenge';

  // Streak
  static const noStreak       = 'No streak yet';
  static String streakOf(int n) => '$n-day streak';
}

// ─── Layout constants ─────────────────────────────────────────────────────────

abstract class AppLayout {
  AppLayout._();

  static const horizontalPadding = 16.0;
  static const cardRadius        = 20.0;
  static const pillRadius        = 100.0;
  static const statBarRadius     = 16.0;
  static const badgeRadius       = 12.0;
  static const bubbleRadius      = 12.0;
  static const bottomNavHeight   = 64.0;
}