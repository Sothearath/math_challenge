// lib/features/game/controllers/arithmetic_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../../../core/utils/equation_builder.dart';
import '../models/level_config.dart';
import '../services/ad_service.dart';
import '../services/storage_service.dart';
import '../views/daily_challenge/daily_challenge_controller.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/defeat_dialog.dart';

class FloatingLabel {
  final String text;
  final Color  color;
  final String id;
  FloatingLabel({required this.text, required this.color})
      : id = DateTime.now().microsecondsSinceEpoch.toString();
}

class ArithmeticController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final AdService _adService = AdService();
  late LevelConfig currentLevel;

  // ── Observable state ─────────────────────────────────────────────────────────
  final RxString equation          = ''.obs;
  final RxString userInput         = ''.obs;
  final RxInt    hearts            = 3.obs;
  final RxInt    score             = 0.obs;
  final RxInt    streak            = 0.obs;
  final RxInt    timeLeft          = 60.obs;
  final RxInt    questionsAnswered = 0.obs;
  final RxDouble progressTarget    = 0.0.obs;
  final RxBool   comboActive       = false.obs;
  final RxString comboLabel        = ''.obs;
  final RxList<FloatingLabel> floatingLabels = <FloatingLabel>[].obs;
  final RxInt    particleBurstTick  = 0.obs;
  final RxInt    wrongAnswerTick   = 0.obs;  // increments on every wrong answer → triggers shake + flash in view
  final RxBool   isWrongFlashing   = false.obs; // true for 400 ms after wrong → resets automatically
  final RxBool   dangerState       = false.obs;

  // ── ADAPTIVE PERFORMANCE CONTROLS ──────────────────────────────────────────
  //  0 = Standard constraints from kLevels configuration array
  // -1 = Alleviated Downgrade (Drastically simplifies values to relieve frustration)
  //  1 = High Velocity Overdrive (Pushes numbers up if solving ultra-fast)
  final RxInt dynamicDifficultyTier = 0.obs;
  int _consecutiveWrongAnswers = 0;

  static const List<int> _comboMilestones = [3, 5, 10];
  DateTime?  _questionStartTime;
  Timer? _timer;
  bool   _gameRunning = false;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is LevelConfig) {
      currentLevel = Get.arguments as LevelConfig;
    } else {
      final saved = _storage.currentLevel.clamp(1, kLevels.length);
      currentLevel = kLevels[saved - 1];
    }
    timeLeft.value = currentLevel.timeLimitSeconds;
    dynamicDifficultyTier.value = 0; // Initialize standard difficulty tier

    _adService.loadRewardedAd(); // 🌟 1. Pre-fetch the ad early so it's ready!

    _generateEquation();
    _startTimer();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  void _startTimer() {
    _gameRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_gameRunning) {
        _stopTimer();
        return;
      }
      if (timeLeft.value <= 0) {
        _endGame(won: false, reason: 'timeout');
        return;
      }
      timeLeft.value--;
    });
  }

  void _stopTimer() {
    _gameRunning = false;
    _timer?.cancel();
    _timer = null;
  }

  void onKeyTap(String key) {
    if (!_gameRunning) return;
    if (key == 'backspace') {
      if (userInput.value.isNotEmpty) {
        userInput.value = userInput.value.substring(0, userInput.value.length - 1);
      }
    } else {
      if (userInput.value.length < 6) {
        userInput.value += key;
      }
    }
  }

  void onSubmit() {
    if (!_gameRunning) return;
    final answer = int.tryParse(userInput.value);
    if (answer == null) return;

    final correct = _checkAnswer(answer);
    userInput.value = '';

    if (correct) {
      _handleCorrect();
    } else {
      _handleWrong();
    }

    if (_gameRunning) {
      _generateEquation();
    }
  }

  // ── Correct Answer Handling with Dynamic Step-Up ───────────────────────────
  void _handleCorrect() {
    score.value++;
    streak.value++;
    questionsAnswered.value++;
    _consecutiveWrongAnswers = 0; // Reset consecutive wrongs on success

    progressTarget.value = (questionsAnswered.value / currentLevel.questionsPerRound).clamp(0.0, 1.0);
    particleBurstTick.value++;

    int responseTimeMs = 9999;
    if (_questionStartTime != null) {
      responseTimeMs = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    }

    _checkSpeedBonus(responseTimeMs);
    _checkCombo();

    // ADAPTIVE UPGRADE LOGIC:
    // If user solves 3 correct answers quickly in normal tier, increase difficulty bounds
    if (streak.value >= 3 && responseTimeMs < 3000 && dynamicDifficultyTier.value == 0) {
      dynamicDifficultyTier.value = 1;
      _spawnFloating("⚡ Overdrive Mode! ⚡", const Color(0xFFFFB61D)); // Icon Yellow Pop
    }
    // Recovery check: if they were downgraded but score 2 correct in a row, restore normal level rules
    else if (streak.value >= 2 && dynamicDifficultyTier.value == -1) {
      dynamicDifficultyTier.value = 0;
      _spawnFloating("👍 Recovered! Normal Mode", const Color(0xFF6AD7C5)); // Icon Mint Green
    }

    if (questionsAnswered.value >= currentLevel.questionsPerRound) {
      _endGame(won: true, reason: 'levelComplete');
    }
  }

  // ── Wrong Answer Handling with Dynamic Downgrade ─────────────────────────────
  void _handleWrong() {
    streak.value      = 0;
    comboActive.value = false;
    comboLabel.value  = '';
    hearts.value      = (hearts.value - 1).clamp(0, 3);
    dangerState.value = hearts.value == 1;
    _consecutiveWrongAnswers++;
    wrongAnswerTick.value++;  // triggers WrongAnswerFlash + equation card shake
    isWrongFlashing.value = true;
    Future.delayed(const Duration(milliseconds: 400), () {
      isWrongFlashing.value = false; // resets border/bg after flash completes
    });

    // ADAPTIVE DOWNGRADE LOGIC:
    // Missing an answer triggers an immediate fallback downgrade to clear road blocks
    if (dynamicDifficultyTier.value >= 0) {
      dynamicDifficultyTier.value = -1;
      _spawnFloating("🧠 Brainy Adjusted The Level!", const Color(0xFF68B2F4)); // Fresh Sky Blue
    }

    // 🌟 2. Intercept Out of Hearts condition
    // if (hearts.value == 0) {
    //   _handleOutOfHearts();
    // }
    if (hearts.value == 0) {
      if (currentLevel.levelNumber == 0) {
        // Daily Challenge is strictly one-shot in-game! Burn attempt and end game.
        _endGame(won: false, reason: 'noHearts');
      } else {
        // Standard levels can offer an ad video check block
        _handleOutOfHearts();
      }
    }
  }

  /// Handles checking for ad availability before executing standard Game Over protocols
  void _handleOutOfHearts() {
    _stopTimer(); // Pause the countdown while the user deals with ad flows

    // Show a dialog box asking if they want to watch an ad for a second chance
    Get.dialog(
      AlertDialog(
        title: const Text('💡 Out of Hearts!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Watch a quick video to restore 1 Heart and keep your streak alive?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close this choice alert
              _endGame(won: false, reason: 'noHearts'); // Reject ad -> Trigger Game Over
            },
            child: const Text('No, Quit', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close this choice alert

              // 🌟 3. Trigger the AdMob Video Player
              _adService.showRewardedAd(
                onRewardEarned: () {
                  // Reward path: Add a heart back and keep playing!
                  hearts.value = 1;
                  dangerState.value = true;
                  _spawnFloating("❤️ Extra Life Granted!", const Color(0xFFFF5252));
                },
                onAdClosedOrFailed: () {
                  // After ad finishes (or if it fails to load), resume engine state
                  _startTimer();
                  if (hearts.value == 0) {
                    // If they closed the ad early without watching completely, trigger loss
                    _endGame(won: false, reason: 'noHearts');
                  } else {
                    // If they watched successfully, generate a fresh math problem to keep going
                    _generateEquation();
                  }
                },
              );
            },
            child: const Text('Watch Video 🎬'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _checkSpeedBonus(int ms) {
    if (ms < 3000) {
      final text  = ms < 1500 ? '+10 XP ⚡' : '+5s ⚡';
      final color = ms < 1500 ? const Color(0xFF00E676) : const Color(0xFF40C4FF);
      _spawnFloating(text, color);
    }
  }

  void _checkCombo() {
    if (!_comboMilestones.contains(streak.value)) return;
    comboActive.value = true;
    comboLabel.value  = '🔥 Combo ×${streak.value}!';
    _spawnFloating(comboLabel.value, const Color(0xFFFFB300));
  }

  void _spawnFloating(String text, Color color) {
    final label = FloatingLabel(text: text, color: color);
    floatingLabels.add(label);
    Future.delayed(const Duration(milliseconds: 1500), () {
      floatingLabels.removeWhere((l) => l.id == label.id);
    });
  }

  // ── Equation Generation with Dynamic Payload Overrides ─────────────────────
  void _generateEquation() {
    _questionStartTime = DateTime.now();

    LevelConfig adaptivePayload = currentLevel;

    // Apply adaptive scaling parameters dynamically based on current player performance tier
    if (dynamicDifficultyTier.value == -1) {
      // Simplify operations to alleviate frustration instantly
      int scaledMax = (currentLevel.maxOperand * 0.45).clamp(9, currentLevel.maxOperand).toInt();

      adaptivePayload = LevelConfig(
        levelNumber:       currentLevel.levelNumber,
        label:             currentLevel.label,
        timeLimitSeconds:  currentLevel.timeLimitSeconds,
        questionsPerRound: currentLevel.questionsPerRound,
        xpPerCorrect:      currentLevel.xpPerCorrect,
        complexityPercent: currentLevel.complexityPercent,
        allowedOps:        currentLevel.allowedOps,
        maxOperand:        scaledMax, // Injecting downscaled operands safely
        allowNegative:     false,     // Turn off negative parameters during recovery mode
        allowDecimal:      false,     // Turn off confusing fractions
      );
    } else if (dynamicDifficultyTier.value == 1) {
      // Push max limits slightly higher for advanced players
      int scaledMax = (currentLevel.maxOperand * 1.35).toInt();

      adaptivePayload = LevelConfig(
        levelNumber:       currentLevel.levelNumber,
        label:             currentLevel.label,
        timeLimitSeconds:  currentLevel.timeLimitSeconds,
        questionsPerRound: currentLevel.questionsPerRound,
        xpPerCorrect:      currentLevel.xpPerCorrect + 4, // Give higher score payout rules
        complexityPercent: currentLevel.complexityPercent,
        allowedOps:        currentLevel.allowedOps,
        maxOperand:        scaledMax,
        allowNegative:     currentLevel.allowNegative,
        allowDecimal:      currentLevel.allowDecimal,
      );
    }

    // Pass the safe configuration copy to the EquationBuilder
    equation.value = EquationBuilder.generate(adaptivePayload);
  }

  bool _checkAnswer(int answer) => AnswerChecker.check(equation.value, answer);

  void _endGame({required bool won, required String reason}) {
    if (!_gameRunning) return;
    _stopTimer();

    // ── Check if this is the Daily Challenge ──
    final isDailyChallenge = currentLevel.levelNumber == 0; // Sentinel property

    if (isDailyChallenge) {
      _handleDailyChallengeEnd(won: won);
      return;
    }

    // ── STANDARD LEVELS 1-15 GAME LOOP ────────────────────────────────────────
    final xpGained        = score.value * currentLevel.xpPerCorrect;
    final nextLevelNumber = (currentLevel.levelNumber + (won ? 1 : 0))
        .clamp(1, kLevels.length);

    // Local persistence (always)
    _storage.saveSession(
      level: nextLevelNumber,
      score: score.value,
      xp:    xpGained,
    );

    // Firestore sync (best-effort, non-blocking)
    _syncSessionToFirestore(
      xpGained:        xpGained,
      sessionScore:    score.value,
      nextLevelNumber: nextLevelNumber,
      won:             won,
    );

    // Show dialog after short delay
    Future.delayed(const Duration(milliseconds: 400), () {
      if (won) {
        Get.dialog(
          VictoryDialog(
            xpGained:      xpGained,
            newComplexity: currentLevel.complexityPercent + 5,
            nextLevel:     kLevels[nextLevelNumber - 1],
          ),
          barrierDismissible: false,
        );
      } else {
        Get.dialog(
          DefeatDialog(currentLevel: currentLevel,remainingHearts: hearts.value,),
          barrierDismissible: false,
        );
      }
    });
  }

  // ── Daily Challenge End-Game Orchestrator (LOCAL ONLY) ───────────────────
  void _handleDailyChallengeEnd({required bool won}) {
    final dailyCtrl = Get.find<DailyChallengeController>();

    // Determine if it was a perfect win (player completed it with all 3 hearts intact)
    final bool isPerfectWin = won && (hearts.value == 3);

    if (won) {
      // 1. Fire local storage completion protocol
      dailyCtrl.completeChallenge(isPerfect: isPerfectWin);

      // 2. Create a mock configuration to safely bypass the nextLevel dialog compiler requirement
      final dashboardRedirectConfig = LevelConfig(
        levelNumber:       -1, // Custom sentinel to tell Victory Dialog to run dashboard navigation
        label:             'Return to Home',
        timeLimitSeconds:  0,
        questionsPerRound: 0,
        xpPerCorrect:      0,
        complexityPercent: currentLevel.complexityPercent,
        allowedOps:        currentLevel.allowedOps,
        maxOperand:        0,
        allowNegative:     false,
        allowDecimal:      false,
      );

      // 3. Show the victory dialog with our clean redirect config
      Future.delayed(const Duration(milliseconds: 400), () {
        Get.dialog(
          VictoryDialog(
            xpGained:      100,
            newComplexity: currentLevel.complexityPercent,
            nextLevel:     dashboardRedirectConfig,
          ),
          barrierDismissible: false,
        );
      });
    } else {
      // 1. Fire local storage failure protocol (Locks out the card attempt)
      dailyCtrl.failChallenge();

      // 2. Show generic defeat dialog
      Future.delayed(const Duration(milliseconds: 400), () {
        Get.dialog(
          DefeatDialog(currentLevel: currentLevel,remainingHearts: hearts.value,),
          barrierDismissible: false,
        );
      });
    }
  }

  // ── Firestore session sync ────────────────────────────────────────────────
  // Runs independently of the dialog flow — a failure here never blocks the
  // player from seeing their result screen.
  Future<void> _syncSessionToFirestore({
    required int xpGained,
    required int sessionScore,
    required int nextLevelNumber,
    required bool won,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return; // Not signed in — skip silently

      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      // Read current high score from Firestore to compare
      final snap = await userRef.get();
      final currentHighScore = snap.data()?['highScore'] as int? ?? 0;

      final Map<String, dynamic> updates = {
        // Always increment XP
        'totalXP':      FieldValue.increment(xpGained),
        // Always update lastActiveAt
        'lastActiveAt': FieldValue.serverTimestamp(),
      };

      // Only advance currentLevel on a win
      if (won) {
        updates['currentLevel'] = nextLevelNumber;
      }

      // Only overwrite highScore if this session beat the record
      if (sessionScore > currentHighScore) {
        updates['highScore'] = sessionScore;
      }

      await userRef.update(updates);
    } on FirebaseException catch (e) {
      // Log silently — never surface Firestore errors to the game UI
      debugPrint('[ArithmeticController] Firestore sync failed: ${e.message}');
    } catch (e) {
      debugPrint('[ArithmeticController] Unexpected sync error: $e');
    }
  }

  void loadNextLevel(LevelConfig nextLevel) {
    currentLevel = nextLevel;
    userInput.value = '';
    questionsAnswered.value = 0;
    streak.value = 0;
    progressTarget.value = 0;
    comboActive.value = false;
    dangerState.value = false;
    dynamicDifficultyTier.value = 0; // Safely clean status modifiers for next stage
    timeLeft.value = currentLevel.timeLimitSeconds;
    _generateEquation();
    _timer?.cancel();
    _startTimer();
  }

  void quitGame() {
    _stopTimer();
    Get.offAllNamed(Routes.dashboard);
  }

  // ── Public: called by VictoryDialog "Next Level" button ───────────────────
  // Writes the new level to Firestore immediately — before Get.off() destroys
  // this controller instance. Fire-and-forget so navigation is never delayed.
  Future<void> updateLevelOnFirestore(int newLevelNumber) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({
        'currentLevel': newLevelNumber,
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('[ArithmeticController] updateLevel failed: ${e.message}');
    } catch (e) {
      debugPrint('[ArithmeticController] updateLevel error: $e');
    }
  }
}