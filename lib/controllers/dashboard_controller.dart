// lib/controllers/dashboard_controller.dart
//
// FlexiArithmetic: Brainy Challenge
// Math-specific score tracking — avg accuracy, top score, focus score,
// adaptive complexity, and weekly session history.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class MathSession {
  final int correct;
  final int total;
  final DateTime timestamp;

  const MathSession({
    required this.correct,
    required this.total,
    required this.timestamp,
  });

  double get accuracy => total == 0 ? 0.0 : correct / total;

  Map<String, dynamic> toJson() => {
    'correct':   correct,
    'total':     total,
    'ts':        timestamp.toIso8601String(),
  };

  factory MathSession.fromJson(Map<String, dynamic> j) => MathSession(
    correct:   j['correct']  as int,
    total:     j['total']    as int,
    timestamp: DateTime.parse(j['ts'] as String),
  );
}

// ─── Controller ───────────────────────────────────────────────────────────────

class DashboardController extends GetxController
    with GetTickerProviderStateMixin {

  StorageService get _s => Get.find<StorageService>();

  // ── Reactive state ───────────────────────────────────────────────────────────

  /// Rolling weekly average: correct / total equations.
  final RxInt avgCorrect  = 0.obs;
  final RxInt avgTotal    = 28.obs;

  /// All-time personal best session.
  final RxInt topCorrect  = 0.obs;
  final RxInt topTotal    = 28.obs;

  /// Most recent completed session.
  final RxInt lastCorrect = 0.obs;
  final RxInt lastTotal   = 28.obs;

  /// Training session length in minutes.
  final RxInt trainingMinutes = 2.obs;

  /// Complexity: 5–100 — auto-adjusts after each session.
  final RxInt complexityPct = 25.obs;

  /// Focus score: accuracy-weighted speed index (0–100).
  final RxInt focusScore = 0.obs;

  /// Completed-day flags for Mon–Sun of the current ISO week.
  final completedDays = List.generate(7, (_) => false).obs;

  final RxInt currentStreak = 0.obs;

  // ── Start button animation ────────────────────────────────────────────────

  late final AnimationController startAnim;
  late final Animation<double>   startScale;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _buildAnim();
    _load();
  }

  @override
  void onClose() {
    startAnim.dispose();
    super.onClose();
  }

  void _buildAnim() {
    startAnim = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 110),
    );
    startScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: startAnim, curve: Curves.easeOut),
    );
  }

  void _load() {
    trainingMinutes.value = _s.trainingMinutes;
    complexityPct.value   = _s.difficultyPct;
    currentStreak.value   = _s.currentStreak;
    topCorrect.value      = _s.bestResult;
    topTotal.value        = _s.totalQuestions;
    lastCorrect.value     = _s.lastResult;
    lastTotal.value       = _s.totalQuestions;

    _recomputeAvg();
    _loadWeeklyDays();
    _computeFocusScore();
  }

  // ── Weekly day tracker ────────────────────────────────────────────────────

  void _loadWeeklyDays() {
    final saved  = _s.weeklyDays;
    final monday = _mondayOfWeek();
    for (int i = 0; i < 7; i++) {
      final d = monday.add(Duration(days: i));
      completedDays[i] = saved.contains(_dateKey(d));
    }
    completedDays.refresh();
  }

  void _markTodayComplete() {
    final today   = _dateKey(DateTime.now());
    final days    = _s.weeklyDays;
    if (days.contains(today)) return;

    final cutoff  = DateTime.now().subtract(const Duration(days: 7));
    final pruned  = days.where((s) {
      try { return !DateTime.parse(s).isBefore(cutoff); } catch (_) { return false; }
    }).toList()..add(today);
    _s.weeklyDays = pruned;
    _loadWeeklyDays();
  }

  // ── Streak ────────────────────────────────────────────────────────────────

  void _updateStreak() {
    final yesterday = _dateKey(
        DateTime.now().subtract(const Duration(days: 1)));
    final days = _s.weeklyDays;
    currentStreak.value = days.contains(yesterday)
        ? currentStreak.value + 1
        : 1;
    _s.currentStreak = currentStreak.value;
  }

  // ── Score computation ─────────────────────────────────────────────────────

  // Session history is stored under a private key in GetStorage.
  static const _kHistory = 'math_session_history';

  List<MathSession> _loadHistory() {
    final raw = _s.read<List>(_kHistory);
    if (raw == null) return [];
    return raw
        .map((e) => MathSession.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  void _saveHistory(List<MathSession> list) {
    // Keep the last 30 sessions (one month of daily play).
    final trimmed = list.length > 30 ? list.sublist(list.length - 30) : list;
    _s.write(_kHistory, trimmed.map((s) => s.toJson()).toList());
  }

  void _recomputeAvg() {
    final history = _loadHistory();
    if (history.isEmpty) {
      avgCorrect.value = 0;
      avgTotal.value   = _s.totalQuestions;
      return;
    }
    final totalCorrect = history.fold<int>(0, (acc, s) => acc + s.correct);
    avgCorrect.value = (totalCorrect / history.length).round();
    avgTotal.value   = history.last.total;
  }

  /// Focus score = last session accuracy × 100, clamped 0–100.
  /// Extend this with a speed factor once GameController tracks response time.
  void _computeFocusScore() {
    if (lastTotal.value == 0) { focusScore.value = 0; return; }
    focusScore.value =
        (lastCorrect.value / lastTotal.value * 100).round().clamp(0, 100);
  }

  /// Adaptive difficulty: nudge complexity after each session.
  void _nudgeComplexity(double accuracy) {
    int delta = 0;
    if (accuracy >= 0.90)      delta = 5;   // ace it → harder
    else if (accuracy >= 0.75) delta = 2;   // good   → slightly harder
    else if (accuracy < 0.50)  delta = -5;  // tough  → easier
    complexityPct.value = (complexityPct.value + delta).clamp(5, 100);
    _s.difficultyPct    = complexityPct.value;
  }

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Call from ResultView or GameController at the end of every math session.
  ///
  /// [correct]  — number of equations solved correctly.
  /// [total]    — total equations in the session.
  void recordSession(int correct, int total) {
    assert(total > 0, 'total must be > 0');

    final session = MathSession(
      correct:   correct,
      total:     total,
      timestamp: DateTime.now(),
    );

    // Persist
    final history = _loadHistory()..add(session);
    _saveHistory(history);

    // Update reactive state
    lastCorrect.value = correct;
    lastTotal.value   = total;
    _s.lastResult     = correct;
    _s.totalQuestions = total;

    if (correct > topCorrect.value) {
      topCorrect.value = correct;
      topTotal.value   = total;
      _s.bestResult    = correct;
    }

    _recomputeAvg();
    _computeFocusScore();
    _markTodayComplete();
    _updateStreak();
    _nudgeComplexity(correct / total);
  }

  String get streakLabel {
    final n = currentStreak.value;
    return n == 0 ? 'No streak yet' : '$n-day streak';
  }

  // ── Button tap animation ──────────────────────────────────────────────────

  Future<void> animateTap() async {
    HapticFeedback.mediumImpact();
    await startAnim.forward();
    await startAnim.reverse();
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  static DateTime _mondayOfWeek() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day - (now.weekday - 1));
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
          '${d.day.toString().padLeft(2, '0')}';
}