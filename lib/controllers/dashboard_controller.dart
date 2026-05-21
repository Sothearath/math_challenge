// lib/features/dashboard/controllers/dashboard_controller.dart
//
// Upgraded DashboardController — handles mascot idle animation state,
// dynamic greeting logic, and button-pulse trigger signal.
// Works alongside the view-level AnimationControllers declared in
// BrainyDashboardView (which owns the vsync lifecycle).

import 'package:get/get.dart';

import '../services/storage_service.dart';

class DashboardController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  // ── Observable state ────────────────────────────────────────────────────────

  /// Current weekly streak count (days completed this week).
  final RxInt weekStreak = 0.obs;

  /// Whether the user has an active streak (≥ 1 completed day).
  bool get hasStreak => weekStreak.value > 0;

  /// Greeting text shown in the speech bubble above Brainy.
  String get greetingText {
    if (weekStreak.value >= 7) {
      return "Perfect week! You're unstoppable, keep it up! 🏆";
    } else if (weekStreak.value >= 3) {
      return "You're on fire! 🔥 Ready to protect your streak?";
    } else if (weekStreak.value == 1) {
      return "Day 1 done! Let's build that streak higher!";
    }
    return "Hi, I'm Brainy. Let's sharpen those math skills today!";
  }

  // ── Accent colour for greeting (teal → amber when on streak) ────────────────
  /// Returns the hex string for the highlighted name colour in the greeting.
  /// On a streak, shifts from the default teal to a warm amber to signal urgency.
  String get greetingAccentHex =>
      hasStreak ? '#FFB300' : '#00C896'; // amber vs spring-green

  // ── Stats ────────────────────────────────────────────────────────────────────
  final RxInt avgAccuracy  = 0.obs;   // 0-28 equations
  final RxInt topScore     = 0.obs;
  final RxInt latestSession = 0.obs;

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadPersisted();
  }

  void _loadPersisted() {
    weekStreak.value    = _storage.getWeekStreak();
    topScore.value      = _storage.getTopScore();
    latestSession.value = _storage.getLatestSession();
    avgAccuracy.value   = _storage.getAvgAccuracy();
  }

  /// Call this after a session completes to refresh the dashboard stats.
  void refreshStats() => _loadPersisted();
}