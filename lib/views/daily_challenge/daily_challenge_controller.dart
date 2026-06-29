// lib/features/game/controllers/daily_challenge_controller.dart
//
// Daily Challenge — one shot per calendar day, +100 XP bonus on completion.
// Every user globally receives the same equation parameters for the day,
// pulled from /daily_challenges/{yyyy-MM-dd}.
//
// Lockout is tracked via /users/{uid}.lastDailyCompleted == todayDateString.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/level_config.dart';
import '../../services/storage_service.dart';

class DailyChallengeController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;
  final StorageService _storage = Get.find<StorageService>(); // Inject local storage

  // ── Observable state ─────────────────────────────────────────────────────
  final RxBool   hasPlayedToday = false.obs;
  final RxBool   isLoading      = true.obs;
  final RxString errorMessage   = ''.obs;
  final RxBool wasChallengePerfectWin = false.obs;

  /// Today's date string in yyyy-MM-dd, computed once at controller creation.
  /// Using the device clock — acceptable for a daily-cadence feature where
  /// a few hours of timezone skew doesn't materially affect fairness.
  late final String todayDateString;

  /// The challenge config for today, fetched lazily only if hasPlayedToday == false.
  LevelConfig? _challengeConfig;
  LevelConfig get challengeConfig => _challengeConfig ?? _fallbackConfig();

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    todayDateString = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _checkLockoutStatus();
  }

  // ── Step 1: Check Lockout status from LOCAL STORAGE ────────────────────
  Future<void> _checkLockoutStatus() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Read directly from your local storage service keys
      final String lastCompleted = _storage.lastDailyCompleted; // Make sure these fields exist on StorageService
      hasPlayedToday.value = (lastCompleted == todayDateString);

      // Read perfect win flag locally
      wasChallengePerfectWin.value = _storage.wasChallengePerfectWin;

      // We still fetch the questions configs from global firestore if they haven't played
      if (!hasPlayedToday.value) {
        await _fetchTodaysConfig();
      }
    } catch (e) {
      debugPrint('[DailyChallenge] local lockout check failed: $e');
      hasPlayedToday.value = false;
      _challengeConfig = _fallbackConfig();
    } finally {
      isLoading.value = false;
    }
  }

// ── Step 2: Fetch today's global equation config (Kept for syncing questions) ──
  Future<void> _fetchTodaysConfig() async {
    try {
      final configSnap = await _firestore
          .collection('daily_challenges')
          .doc(todayDateString)
          .get();

      if (!configSnap.exists) {
        debugPrint('[DailyChallenge] no config for $todayDateString — using fallback');
        _challengeConfig = _fallbackConfig();
        return;
      }

      final data = configSnap.data()!;
      _challengeConfig = _configFromFirestore(data);
    } catch (e) {
      debugPrint('[DailyChallenge] config fetch failed — using fallback');
      _challengeConfig = _fallbackConfig();
    }
  }

  // ── Step 3: Local Completion protocol ─────────────────────────────────────
  void completeChallenge({required bool isPerfect}) {
    try {
      // 1. Persist to local storage keys
      _storage.saveDailyChallengeRecord(
        dateStr: todayDateString,
        isPerfect: isPerfect,
      );

      // 2. Increment local XP rewards
      _storage.saveSession(
        level: _storage.currentLevel,
        score: 0,
        xp: 100, // Pay out flat +100 XP locally
      );

      // 3. Update active UI memory state variables
      wasChallengePerfectWin.value = isPerfect;
      hasPlayedToday.value = true;
    } catch (e) {
      debugPrint('[DailyChallenge] local completion error: $e');
    }
  }

  // ── Maps raw Firestore JSON → LevelConfig ─────────────────────────────────
  LevelConfig _configFromFirestore(Map<String, dynamic> data) {
    final opsList = (data['allowedOps'] as List<dynamic>?) ?? ['add'];
    final ops = opsList
        .map((s) => _parseMathOp(s as String))
        .whereType<MathOp>()
        .toList();

    return LevelConfig(
      // Daily Challenge isn't part of the 1–15 progression — use 0 as a
      // sentinel so UI code can detect "this is the daily challenge".
      levelNumber:       0,
      label:             'Daily Challenge',
      timeLimitSeconds:  data['timeLimitSeconds']  as int? ?? 45,
      questionsPerRound: data['questionsPerRound'] as int? ?? 10,
      xpPerCorrect:      _perCorrectXp(data),
      complexityPercent: 50,
      allowedOps:        ops.isNotEmpty ? ops : [MathOp.add],
      maxOperand:        data['maxOperand'] as int? ?? 12,
      allowNegative:     false,
      allowDecimal:      false,
    );
  }

  /// Daily challenges reward a flat +100 XP on completion (handled in
  /// completeChallenge), not per-question. xpPerCorrect is set to 0 here so
  /// the normal ArithmeticController scoring path doesn't double-award XP.
  int _perCorrectXp(Map<String, dynamic> data) => 0;

  MathOp? _parseMathOp(String raw) {
    switch (raw) {
      case 'add':      return MathOp.add;
      case 'subtract': return MathOp.subtract;
      case 'multiply': return MathOp.multiply;
      case 'divide':   return MathOp.divide;
      default:         return null;
    }
  }

  // ── Hardcoded fallback — Level 5 difficulty rules ─────────────────────────
  // Used when offline or /daily_challenges/{today} doesn't exist.
  LevelConfig _fallbackConfig() {
    // Mirror kLevels[4] (Level 5) shape but force levelNumber = 0 sentinel
    // and label = 'Daily Challenge' so UI treats it consistently.
    final base = kLevels[4]; // Level 5: Intermediate, add+subtract, maxOperand 30
    return LevelConfig(
      levelNumber:       0,
      label:             'Daily Challenge',
      timeLimitSeconds:  45,
      questionsPerRound: 10,
      xpPerCorrect:      0,
      complexityPercent: base.complexityPercent,
      allowedOps:        [MathOp.add, MathOp.multiply],
      maxOperand:        12,
      allowNegative:     false,
      allowDecimal:      false,
    );
  }

// ── Step 4: Local Failure Protocol ────────────────────────────────────────
  void failChallenge() {
    try {
      // 1. Burn the slot by setting today as completed, but mark perfect as false
      _storage.saveDailyChallengeRecord(
        dateStr: todayDateString,
        isPerfect: false,
      );

      wasChallengePerfectWin.value = false;
      hasPlayedToday.value = true; // Lockout card from being played again
    } catch (e) {
      debugPrint('[DailyChallenge] local failure error: $e');
    }
  }

  // Call this inside your dialog's "Watch Ad" success hook to release the lock temporarily
  void grantSecondChanceChance() {
    hasPlayedToday.value = false;
  }

  // ── Manual refresh (e.g. pull-to-refresh on dashboard) ────────────────────
  Future<void> refresh() => _checkLockoutStatus();
}