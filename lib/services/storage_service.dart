import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get_storage/get_storage.dart';

import '../core/constants.dart';

class StorageService extends GetxService {
  final _box = GetStorage();

  // ── Initialisation ─────────────────────────────────────────────────────────
  // Call StorageService.init() before runApp() — wraps GetStorage.init().
  static Future<void> init() => GetStorage.init();

  // ── Generic helpers ────────────────────────────────────────────────────────

  T? read<T>(String key) => _box.read<T>(key);

  void write(String key, dynamic value) => _box.write(key, value);

  void remove(String key) => _box.remove(key);

  bool hasKey(String key) => _box.hasData(key);

  // ── Typed accessors ────────────────────────────────────────────────────────

  // Hearts
  int   get hearts         => _box.read<int>(StorageKeys.hearts)         ?? 3;
  set   hearts(int v)      => _box.write(StorageKeys.hearts, v);

  // Level
  int   get currentLevel   => _box.read<int>(StorageKeys.currentLevel)   ?? 1;
  set   currentLevel(int v) => _box.write(StorageKeys.currentLevel, v);

  // Results
  int   get bestResult     => _box.read<int>(StorageKeys.bestResult)     ?? 0;
  set   bestResult(int v)  => _box.write(StorageKeys.bestResult, v);

  int   get lastResult     => _box.read<int>(StorageKeys.lastResult)     ?? 0;
  set   lastResult(int v)  => _box.write(StorageKeys.lastResult, v);

  int   get totalQuestions => _box.read<int>(StorageKeys.totalQuestions) ?? 28;
  set   totalQuestions(int v) => _box.write(StorageKeys.totalQuestions, v);

  // Stats
  int   get trainingMinutes => _box.read<int>(StorageKeys.trainingMinutes) ?? 2;
  set   trainingMinutes(int v) => _box.write(StorageKeys.trainingMinutes, v);

  int   get difficultyPct  => _box.read<int>(StorageKeys.difficultyPct)  ?? 25;
  set   difficultyPct(int v) => _box.write(StorageKeys.difficultyPct, v);

  int   get conditionSecs  => _box.read<int>(StorageKeys.conditionSecs)  ?? 12;
  set   conditionSecs(int v) => _box.write(StorageKeys.conditionSecs, v);

  // Streak
  int   get currentStreak  => _box.read<int>(StorageKeys.currentStreak)  ?? 0;
  set   currentStreak(int v) => _box.write(StorageKeys.currentStreak, v);

  String? get lastStreakDate => _box.read<String>(StorageKeys.lastStreakDate);
  set     lastStreakDate(String? v) =>
      v == null ? _box.remove(StorageKeys.lastStreakDate)
          : _box.write(StorageKeys.lastStreakDate, v);

  // Daily challenge
  int   get dailyCompleted => _box.read<int>(StorageKeys.dailyCompleted) ?? 0;
  set   dailyCompleted(int v) => _box.write(StorageKeys.dailyCompleted, v);

  String? get lastDailyMonth => _box.read<String>(StorageKeys.lastDailyMonth);
  set     lastDailyMonth(String? v) =>
      v == null ? _box.remove(StorageKeys.lastDailyMonth)
          : _box.write(StorageKeys.lastDailyMonth, v);

  String? get lastDailyDay => _box.read<String>(StorageKeys.lastDailyDay);
  set     lastDailyDay(String? v) =>
      v == null ? _box.remove(StorageKeys.lastDailyDay)
          : _box.write(StorageKeys.lastDailyDay, v);

  List<String> get weeklyDays =>
      (_box.read<List>(StorageKeys.weeklyDays) ?? []).cast<String>();
  set weeklyDays(List<String> v) => _box.write(StorageKeys.weeklyDays, v);

  // Trophies
  List<Map<String, dynamic>> get monthlyTrophies {
    final raw = _box.read<List>(StorageKeys.monthlyTrophies);
    if (raw == null) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
  set monthlyTrophies(List<Map<String, dynamic>> v) =>
      _box.write(StorageKeys.monthlyTrophies, v);

  // Theme
  bool  get isDarkMode     => _box.read<bool>(StorageKeys.isDarkMode)    ?? false;
  set   isDarkMode(bool v) => _box.write(StorageKeys.isDarkMode, v);

  // ── Gamification stats (used by DashboardController) ──────────────────────
  //
  // getWeekStreak()   — days completed this calendar week (Mon–Sun).
  //                     Delegates to currentStreak; add week-reset logic here
  //                     if you want a separate weekly window.
  //
  // getTopScore()     — highest correct-answer count across all sessions,
  //                     maps to the existing bestResult key.
  //
  // getLatestSession()— correct answers in the most recent session,
  //                     maps to the existing lastResult key.
  //
  // getAvgAccuracy()  — rolling average (0–100) stored after each session.

  int getWeekStreak()    => currentStreak;

  int getTopScore()      => bestResult;

  int getLatestSession() => lastResult;

  int getAvgAccuracy()   =>
      _box.read<int>(StorageKeys.avgAccuracy) ?? 0;

  set _avgAccuracy(int v) => _box.write(StorageKeys.avgAccuracy, v);

  // ── saveSession() ──────────────────────────────────────────────────────────
  //
  // Call this at the end of every game round (from ArithmeticController).
  // Updates: lastResult, bestResult, trainingMinutes, avgAccuracy, streak.
  //
  // Parameters
  //   level  — completed level number (used to advance currentLevel)
  //   score  — correct answers this round
  //   xp     — XP earned (reserved for a future XP bar; stored but not yet
  //             surfaced in the UI)
  //   total  — total questions in the round (defaults to totalQuestions)

  void saveSession({
    required int level,
    required int score,
    required int xp,
    int? total,
  }) {
    final roundTotal = total ?? totalQuestions;

    // ── 1. Per-session results ──────────────────────────────────────────────
    lastResult = score;
    if (score > bestResult) bestResult = score;

    // ── 2. Advance level if this round was completed ────────────────────────
    if (level > currentLevel) currentLevel = level;

    // ── 3. Training time — add 1 minute per session (adjust if you track
    //       actual elapsed seconds via ArithmeticController.timeLeft) ────────
    trainingMinutes = trainingMinutes + 1;

    // ── 4. Rolling average accuracy (percentage, 0–100) ────────────────────
    //       Uses an exponential moving average with α = 0.3 so recent
    //       sessions carry more weight without wiping older history.
    const alpha   = 0.3;
    final pct     = roundTotal > 0 ? ((score / roundTotal) * 100).round() : 0;
    final prev    = getAvgAccuracy();
    final updated = prev == 0
        ? pct                                         // first-ever session
        : ((alpha * pct) + ((1 - alpha) * prev)).round();
    _avgAccuracy  = updated;

    // ── 5. Daily streak ─────────────────────────────────────────────────────
    //       Increments streak if this is the first session today.
    //       Resets to 1 if a day was skipped.
    _updateStreak();
  }

  // ── Internal streak helper ────────────────────────────────────────────────
  void _updateStreak() {
    final today     = _todayKey();
    final lastDate  = lastStreakDate;

    if (lastDate == today) {
      // Already logged today — nothing to change.
      return;
    }

    final yesterday = _offsetDayKey(-1);
    if (lastDate == yesterday) {
      // Consecutive day — extend the streak.
      currentStreak = currentStreak + 1;
    } else {
      // Gap of 2+ days (or very first session) — reset.
      currentStreak = 1;
    }

    lastStreakDate = today;

    // Keep the weeklyDays list in sync (used by the week-dot row on dashboard).
    _markTodayInWeeklyDays(today);
  }

  void _markTodayInWeeklyDays(String today) {
    final days = List<String>.from(weeklyDays);
    if (!days.contains(today)) {
      days.add(today);
      // Trim to last 7 entries so the list never grows unbounded.
      if (days.length > 7) days.removeAt(0);
      weeklyDays = days;
    }
  }

  /// Returns a string key for today: "YYYY-MM-DD".
  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)}';
  }

  /// Returns a string key offset by [days] from today.
  String _offsetDayKey(int days) {
    final d = DateTime.now().add(Duration(days: days));
    return '${d.year}-${_pad(d.month)}-${_pad(d.day)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}