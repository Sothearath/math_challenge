// lib/controllers/awards_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class MonthlyTrophy {
  final String month;       // e.g. "Jan 2025"
  final int    year;
  final int    monthIndex;  // 1–12
  bool         isEarned;

  MonthlyTrophy({
    required this.month,
    required this.year,
    required this.monthIndex,
    this.isEarned = false,
  });

  Map<String, dynamic> toJson() => {
    'month':      month,
    'year':       year,
    'monthIndex': monthIndex,
    'isEarned':   isEarned,
  };

  factory MonthlyTrophy.fromJson(Map<String, dynamic> j) => MonthlyTrophy(
    month:      j['month']      as String,
    year:       j['year']       as int,
    monthIndex: j['monthIndex'] as int,
    isEarned:   j['isEarned']   as bool? ?? false,
  );
}

// ─── Controller ───────────────────────────────────────────────────────────────

class AwardsController extends GetxController {
  // ── storage ─────────────────────────────────────────────────────────────────
  final _box = GetStorage();

  static const _kDailyCompleted = 'daily_completed_count';  // int
  static const _kLastDailyDate  = 'last_daily_date';        // String yyyy-MM-dd
  static const _kTrophies       = 'monthly_trophies';       // List<Map>
  static const _kCurrentLevel   = 'current_level';
  static const _kHearts         = 'hearts';

  // ── observables ─────────────────────────────────────────────────────────────

  /// How many daily challenges completed this month (0..31)
  final RxInt dailyCompletedThisMonth = 0.obs;

  /// Target for the monthly award – using the actual days in the current month
  int get dailyGoal => _daysInCurrentMonth();

  /// Progress towards monthly trophy (0.0 – 1.0)
  double get monthlyProgress =>
      (dailyCompletedThisMonth.value / dailyGoal).clamp(0.0, 1.0);

  /// All-time trophy list (one entry per past month)
  final RxList<MonthlyTrophy> trophies = <MonthlyTrophy>[].obs;

  /// Reactive hearts & level (shared source of truth with HeartController)
  final RxInt lives        = 3.obs;
  final RxInt currentLevel = 1.obs;

  // ── lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  // ── private helpers ──────────────────────────────────────────────────────────

  void _loadAll() {
    // Hearts & level
    lives.value        = _box.read<int>(_kHearts)       ?? 3;
    currentLevel.value = _box.read<int>(_kCurrentLevel) ?? 1;

    // Daily count – reset if we're in a new month
    final savedMonth = _box.read<String>(_kLastDailyDate);
    final now        = DateTime.now();
    final nowMonthKey = '${now.year}-${now.month}';

    if (savedMonth == null || savedMonth != nowMonthKey) {
      // New month – check if last month's run earns a trophy
      if (savedMonth != null) {
        _tryAwardTrophyForMonth(savedMonth);
      }
      dailyCompletedThisMonth.value = 0;
      _box.write(_kLastDailyDate, nowMonthKey);
      _box.write(_kDailyCompleted, 0);
    } else {
      dailyCompletedThisMonth.value = _box.read<int>(_kDailyCompleted) ?? 0;
    }

    // Trophies
    final rawList = _box.read<List>(_kTrophies);
    if (rawList != null) {
      trophies.assignAll(
        rawList
            .map((e) => MonthlyTrophy.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } else {
      _seedTrophies();
    }
  }

  /// Pre-populate the current and last 11 months so the grid always shows 12.
  void _seedTrophies() {
    final now    = DateTime.now();
    final result = <MonthlyTrophy>[];
    for (int i = 11; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      result.add(MonthlyTrophy(
        month:      _monthLabel(d),
        year:       d.year,
        monthIndex: d.month,
        isEarned:   false,
      ));
    }
    trophies.assignAll(result);
    _saveTrophies();
  }

  void _saveTrophies() {
    _box.write(_kTrophies, trophies.map((t) => t.toJson()).toList());
  }

  /// Called at month rollover – award trophy if the user hit the goal.
  void _tryAwardTrophyForMonth(String monthKey) {
    final parts = monthKey.split('-');
    final year  = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final goal  = _daysInMonth(year, month);
    final count = _box.read<int>(_kDailyCompleted) ?? 0;

    if (count >= goal) {
      final idx = trophies.indexWhere(
          (t) => t.year == year && t.monthIndex == month);
      if (idx != -1) {
        trophies[idx].isEarned = true;
        trophies.refresh();
        _saveTrophies();
      }
    }
  }

  static String _monthLabel(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  static int _daysInCurrentMonth() {
    final now = DateTime.now();
    return _daysInMonth(now.year, now.month);
  }

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;

  // ── public API ───────────────────────────────────────────────────────────────

  /// Call this when the user successfully finishes today's daily challenge.
  void markDailyChallengeComplete() {
    // Guard: only once per calendar day
    final today    = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final lastDay  = _box.read<String>('last_daily_day') ?? '';

    if (lastDay == todayKey) return; // already claimed today

    _box.write('last_daily_day', todayKey);
    dailyCompletedThisMonth.value++;
    _box.write(_kDailyCompleted, dailyCompletedThisMonth.value);

    // Check if this completion finishes the monthly goal right now
    if (dailyCompletedThisMonth.value >= dailyGoal) {
      final now = DateTime.now();
      final idx = trophies.indexWhere(
          (t) => t.year == now.year && t.monthIndex == now.month);
      if (idx != -1 && !trophies[idx].isEarned) {
        trophies[idx].isEarned = true;
        trophies.refresh();
        _saveTrophies();
        Get.snackbar(
          '🏆 Trophy Earned!',
          'You completed every challenge this month!',
          backgroundColor: const Color(0xFFFFD700),
          colorText: Colors.black87,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// Saves current lives to storage (call from HeartController or game end)
  void saveLives(int value) {
    lives.value = value;
    _box.write(_kHearts, value);
  }

  void saveLevel(int value) {
    currentLevel.value = value;
    _box.write(_kCurrentLevel, value);
  }

  /// Reset hearts to full (e.g. after ad revive or new session)
  void restoreHearts() => saveLives(3);

  bool get monthlyGoalAchieved =>
      dailyCompletedThisMonth.value >= dailyGoal;
}
