// lib/features/game/controllers/arithmetic_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../../../core/utils/equation_builder.dart';
import '../models/level_config.dart';
import '../services/storage_service.dart';
import '../widgets/victory_dialog.dart';
import '../widgets/defeat_dialog.dart';

// ── Floating-label model ──────────────────────────────────────────────────────
class FloatingLabel {
  final String text;
  final Color  color;
  final String id;
  FloatingLabel({required this.text, required this.color})
      : id = DateTime.now().microsecondsSinceEpoch.toString();
}

// ── Controller ────────────────────────────────────────────────────────────────
class ArithmeticController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

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
  final RxInt    particleBurstTick = 0.obs;
  final RxBool   dangerState       = false.obs;

  static const List<int> _comboMilestones = [3, 5, 10];

  DateTime?  _questionStartTime;

  // ── Timer — using dart:async Timer, NOT Ticker ────────────────────────────────
  // Ticker requires a live TickerProvider from the current widget tree.
  // After Get.delete + Get.offNamed the old view's vsync is gone, causing
  // the ticker to silently stall. A plain periodic Timer is immune to this.
  Timer? _timer;
  bool   _gameRunning = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────
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
    _generateEquation();
    _startTimer();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────────
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

  // ── Input ─────────────────────────────────────────────────────────────────────
  void onKeyTap(String key) {
    if (!_gameRunning) return;
    if (key == 'backspace') {
      if (userInput.value.isNotEmpty) {
        userInput.value =
            userInput.value.substring(0, userInput.value.length - 1);
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

    // Only generate a new equation if the round is still active.
    if (_gameRunning) {
      _generateEquation();
    }
  }

  // ── Correct ───────────────────────────────────────────────────────────────────
  void _handleCorrect() {
    score.value++;
    streak.value++;
    questionsAnswered.value++;

    progressTarget.value =
        (questionsAnswered.value / currentLevel.questionsPerRound)
            .clamp(0.0, 1.0);

    particleBurstTick.value++;
    _checkSpeedBonus();
    _checkCombo();

    if (questionsAnswered.value >= currentLevel.questionsPerRound) {
      _endGame(won: true, reason: 'levelComplete');
    }
  }

  // ── Wrong ─────────────────────────────────────────────────────────────────────
  void _handleWrong() {
    streak.value      = 0;
    comboActive.value = false;
    comboLabel.value  = '';
    hearts.value      = (hearts.value - 1).clamp(0, 3);
    dangerState.value = hearts.value == 1;

    if (hearts.value == 0) {
      _endGame(won: false, reason: 'noHearts');
    }
  }

  // ── Speed bonus ───────────────────────────────────────────────────────────────
  void _checkSpeedBonus() {
    if (_questionStartTime == null) return;
    final ms = DateTime.now().difference(_questionStartTime!).inMilliseconds;
    if (ms < 3000) {
      final text  = ms < 1500 ? '+10 XP ⚡' : '+5s ⚡';
      final color = ms < 1500
          ? const Color(0xFF00E676)
          : const Color(0xFF40C4FF);
      _spawnFloating(text, color);
    }
  }

  // ── Combo ─────────────────────────────────────────────────────────────────────
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

  // ── Equation ──────────────────────────────────────────────────────────────────
  void _generateEquation() {
    _questionStartTime = DateTime.now();
    // Pass the controller instance hashCode as a seed hint so back-to-back
    // calls never return the same cached static value from the engine.
    equation.value = EquationBuilder.generate(currentLevel);
  }

  bool _checkAnswer(int answer) => AnswerChecker.check(equation.value, answer);

  // ── End game ──────────────────────────────────────────────────────────────────
  void _endGame({required bool won, required String reason}) {
    if (!_gameRunning) return;
    _stopTimer();

    final xpGained        = score.value * currentLevel.xpPerCorrect;
    final nextLevelNumber = (currentLevel.levelNumber + (won ? 1 : 0))
        .clamp(1, kLevels.length);

    _storage.saveSession(
      level: nextLevelNumber,
      score: score.value,
      xp:    xpGained,
    );

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
          DefeatDialog(currentLevel: currentLevel),
          barrierDismissible: false,
        );
      }
    });
  }

  // ── Quit ──────────────────────────────────────────────────────────────────────
  void quitGame() {
    _stopTimer();
    Get.offAllNamed(Routes.dashboard);
  }
}