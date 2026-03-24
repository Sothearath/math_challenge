// lib/controllers/streak_controller.dart
//
// Persists daily streak + progress toward the daily goal using Hive.
// Box name: 'streak'  Keys: 'lastDate', 'streakDays', 'todayCorrect'

import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StreakController extends GetxController {
  static const _boxName     = 'streak';
  static const _keyDate     = 'lastDate';
  static const _keyStreak   = 'streakDays';
  static const _keyToday    = 'todayCorrect';
  static const _keyUnlocked = 'unlockedStages'; // "lv_st" comma-separated

  static const int dailyGoal = 50;

  // ── Observables ────────────────────────────────────────────────────────
  final RxInt streakDays    = 0.obs;
  final RxInt todayCorrect  = 0.obs;

  // stageKey → completed
  final RxMap<String, bool> completedStages = <String, bool>{}.obs;

  late Box _box;

  @override
  Future<void> onInit() async {
    super.onInit();
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
    _loadAndRollover();
  }

  // ── Public API ──────────────────────────────────────────────────────────

  double get dailyProgress =>
      (todayCorrect.value / dailyGoal).clamp(0.0, 1.0);

  bool isStageCompleted(int levelIdx, int stageIdx) =>
      completedStages['${levelIdx}_$stageIdx'] == true;

  bool isStageUnlocked(int levelIdx, int stageIdx) {
    if (levelIdx == 0 && stageIdx == 0) return true;
    // previous stage in same level
    if (stageIdx > 0) return isStageCompleted(levelIdx, stageIdx - 1);
    // first stage of a level → last stage of previous level must be done
    return isStageCompleted(levelIdx - 1, 4);
  }

  void recordSession({
    required int questionsCorrect,
    required bool stageCleared,
    required int levelIdx,
    required int stageIdx,
  }) {
    todayCorrect.value += questionsCorrect;
    _box.put(_keyToday, todayCorrect.value);

    if (stageCleared) {
      final key = '${levelIdx}_$stageIdx';
      completedStages[key] = true;
      _persistUnlocked();
    }
  }

  // ── Private ─────────────────────────────────────────────────────────────

  void _loadAndRollover() {
    final today     = _todayStr();
    final lastDate  = _box.get(_keyDate, defaultValue: '') as String;
    final streak    = _box.get(_keyStreak, defaultValue: 0) as int;
    final correct   = _box.get(_keyToday,  defaultValue: 0) as int;
    final unlocked  = _box.get(_keyUnlocked, defaultValue: '') as String;

    // Load completed stages
    if (unlocked.isNotEmpty) {
      for (final k in unlocked.split(',')) {
        if (k.isNotEmpty) completedStages[k] = true;
      }
    }

    if (lastDate == today) {
      // same day – restore
      streakDays.value   = streak;
      todayCorrect.value = correct;
    } else {
      // new day
      final yesterday = _yesterdayStr();
      if (lastDate == yesterday) {
        // consecutive day → extend streak
        streakDays.value = streak + 1;
      } else if (lastDate.isEmpty) {
        streakDays.value = 1;
      } else {
        // broke streak
        streakDays.value = 1;
      }
      todayCorrect.value = 0;
      _box.put(_keyDate,   today);
      _box.put(_keyStreak, streakDays.value);
      _box.put(_keyToday,  0);
    }
  }

  void _persistUnlocked() {
    final keys = completedStages.keys.join(',');
    _box.put(_keyUnlocked, keys);
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  String _yesterdayStr() {
    final n = DateTime.now().subtract(const Duration(days: 1));
    return '${n.year}-${n.month}-${n.day}';
  }
}
