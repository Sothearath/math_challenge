// lib/services/storage_service.dart
//
// Every GetStorage read/write goes through this service.
// Controllers and views never import get_storage directly.
//
// Benefits:
//  • All storage keys centralised (via StorageKeys constants)
//  • Easy to mock in tests — swap this service for a fake
//  • Type-safe getters prevent silent null/cast bugs

import 'package:get/get.dart';
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
}
