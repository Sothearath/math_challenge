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

  // ── Dark surfaces (dashboard scaffold) ───────────────────────────────────
  static const darkBg       = Color(0xFF0D1F18);  // deepest bg
  static const darkCard     = Color(0xFF142B20);  // stat bar, bubble
  static const darkCard2    = Color(0xFF1C3528);  // slightly lighter card
  static const darkDivider  = Color(0xFF1F3D2C);  // borders on dark

  // ── Mint accent ───────────────────────────────────────────────────────────
  static const mint         = Color(0xFF2ED1A2);  // CTA, accents, day dots
  static const mintDark     = Color(0xFF1BAC84);  // pressed / shadow state
  static const mintGlow     = Color(0xFF6BEDD0);  // highlight lobe on Brainy
  static const mintText     = Color(0xFF0A3D28);  // text ON mint surfaces
  static const mintDim      = Color(0xFF9EC4B0);  // muted text on dark bg
  static const mintFaint    = Color(0xFF4D7A62);  // very muted label text

  // ── Light surfaces (activity card, awards) ────────────────────────────────
  static const lightBg      = Color(0xFFF5F7F5);
  static const lightCard    = Colors.white;
  static const lightDivider = Color(0xFFF0F0F0);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const heartRed     = Color(0xFFEF4444);  // hearts / lives
  static const streakGreen  = Color(0xFF0F5E42);  // streak badge text
  static const streakBg     = Color(0xFFD4F2E7);  // streak badge background
  static const goldTrophy   = Color(0xFFFFD700);  // earned trophy
  static const starAmber    = Color(0xFFEF9F27);  // star icon in badge
  static const starBg       = Color(0xFFFFF8E6);  // star badge background
  static const starText     = Color(0xFF7A4F08);  // star badge numeral
  static const starLabel    = Color(0xFFB47A15);  // star badge label
  static const errorRed     = Color(0xFFDC2626);

  // ── Text on white activity card ───────────────────────────────────────────
  static const cardTitle    = Color(0xFF111111);
  static const badgeBg      = Color(0xFFF5F6F5);
  static const badgeLabel   = Color(0xFF999999);
  static const badgeNum     = Color(0xFF111111);
  static const badgeSub     = Color(0xFFBBBBBB);

  // ── Day dot states ─────────────────────────────────────────────────────────
  static const dotDoneBg    = Color(0xFF111E17);  // completed day
  static const dotMissBorder = Color(0xFFDDEEDD); // future/missed border
  static const dotMissText  = Color(0xFFBBCCBB);  // future/missed text
  static const dotDayLabel  = Color(0xFFAAAAAA);  // Mon / Tue label
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