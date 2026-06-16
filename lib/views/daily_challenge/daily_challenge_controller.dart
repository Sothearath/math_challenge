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

class DailyChallengeController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

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

  // ── Step 1: Check if user already completed today's challenge ────────────
  Future<void> _checkLockoutStatus() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        hasPlayedToday.value = false;
        isLoading.value = false;
        return;
      }

      // 1. Fetch the user profile document from Firestore
      final userSnap = await _firestore.collection('users').doc(uid).get();

      // 2. Read the daily date signature
      final lastCompleted = userSnap.data()?['lastDailyCompleted'] as String?;
      hasPlayedToday.value = (lastCompleted == todayDateString);

      // 3. ⭐ GET THE VARIABLE HERE!
      // Pull the boolean flag safely, defaulting to false if it doesn't exist yet
      wasChallengePerfectWin.value = userSnap.data()?['wasChallengePerfectWin'] as bool? ?? false;

      if (!hasPlayedToday.value) {
        await _fetchTodaysConfig();
      }
    } catch (e) {
      debugPrint('[DailyChallenge] lockout check failed: $e');
      hasPlayedToday.value = false;
      _challengeConfig = _fallbackConfig();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Step 2: Fetch today's global equation config ──────────────────────────
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
    } on FirebaseException catch (e) {
      debugPrint('[DailyChallenge] config fetch failed: ${e.message}');
      _challengeConfig = _fallbackConfig();
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

  // ── Step 3: Completion protocol ───────────────────────────────────────────
  // Called by ArithmeticController when questionsAnswered reaches
  // challengeConfig.questionsPerRound AND hearts > 0 (i.e. a win).
  //
  // Atomically:
  //   • sets lastDailyCompleted = todayDateString  (locks out further plays)
  //   • increments totalXP by 100
  Future<bool> completeChallenge() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      await _firestore.collection('users').doc(uid).update({
        'lastDailyCompleted':    todayDateString,
        'wasChallengePerfectWin': true, // Set to true in Firestore
        'totalXP':               FieldValue.increment(100),
      });

      // ⭐ UPDATE IT LOCALLY HERE!
      wasChallengePerfectWin.value = true;
      hasPlayedToday.value = true;
      return true;
    } on FirebaseException catch (e) {
      debugPrint('[DailyChallenge] completion write failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[DailyChallenge] completion error: $e');
      return false;
    }
  }

  // ── Step 4: Failure Protocol ──────────────────────────────────────────────
  // Called by ArithmeticController when lives/hearts reach 0 (i.e. a loss).
  // Burns their daily attempt slot without giving them the +100 XP reward.
  Future<bool> failChallenge() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      await _firestore.collection('users').doc(uid).update({
        'lastDailyCompleted':    todayDateString,
        'wasChallengePerfectWin': false, // Set to false in Firestore
      });

      // ⭐ UPDATE IT LOCALLY HERE!
      wasChallengePerfectWin.value = false;
      hasPlayedToday.value = true; // Lockout the card
      return true;
    } catch (e) {
      debugPrint('[DailyChallenge] failure write failed: $e');
      return false;
    }
  }

  // Call this inside your dialog's "Watch Ad" success hook to release the lock temporarily
  void grantSecondChanceChance() {
    hasPlayedToday.value = false;
  }

  // ── Manual refresh (e.g. pull-to-refresh on dashboard) ────────────────────
  Future<void> refresh() => _checkLockoutStatus();
}