// lib/controllers/game_controller.dart

import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../models/question_model.dart';

class GameController extends GetxController {
  static const int gameDuration = 60;
  static const int machineIntervalSeconds = 3;

  // ── Observables ──────────────────────────────────────────────────────────
  final RxInt timeLeft = gameDuration.obs;
  final RxInt score = 0.obs;
  final RxInt machineScore = 0.obs;
  final RxString currentInput = ''.obs;
  final RxBool isGameActive = false.obs;
  final RxBool isCorrect = false.obs;
  final RxBool isWrong = false.obs;
  final RxInt correctAnswers = 0.obs;
  final RxInt totalAttempts = 0.obs;
  final Rx<Question?> currentQuestion = Rx<Question?>(null);
  final Rx<GameMode> gameMode = GameMode.singlePlayer.obs;
  final Rx<GameResult?> gameResult = Rx<GameResult?>(null);

  // Speed multiplier (increases as score grows)
  final RxDouble multiplier = 1.0.obs;

  // ── Internals ─────────────────────────────────────────────────────────────
  Timer? _countdownTimer;
  Timer? _machineTimer;
  final Random _random = Random();
  int _elapsedSeconds = 0;

  // ── Public API ────────────────────────────────────────────────────────────

  void setMode(GameMode mode) => gameMode.value = mode;

  void startGame() {
    _resetState();
    isGameActive.value = true;
    _generateQuestion();
    _startCountdown();
    if (gameMode.value == GameMode.vsMachine) {
      _startMachineTimer();
    }
  }

  void onKeyTap(String key) {
    if (!isGameActive.value) return;

    if (key == '⌫') {
      if (currentInput.value.isNotEmpty) {
        currentInput.value =
            currentInput.value.substring(0, currentInput.value.length - 1);
      }
    } else if (key == '✓') {
      _submitAnswer();
    } else {
      // Limit input length
      if (currentInput.value.length < 6) {
        currentInput.value += key;
      }
    }
  }

  void _submitAnswer() {
    if (currentInput.value.isEmpty || currentQuestion.value == null) return;

    final input = int.tryParse(currentInput.value);
    totalAttempts.value++;

    if (input == currentQuestion.value!.answer) {
      correctAnswers.value++;
      _updateMultiplier();
      final points = (10 * multiplier.value).round();
      score.value += points;
      _flashCorrect();
    } else {
      multiplier.value = max(1.0, multiplier.value - 0.5);
      _flashWrong();
    }

    currentInput.value = '';
    _generateQuestion();
  }

  void stopGame() {
    _countdownTimer?.cancel();
    _machineTimer?.cancel();
    isGameActive.value = false;
    gameResult.value = GameResult(
      totalQuestions: totalAttempts.value,
      correctAnswers: correctAnswers.value,
      score: score.value,
      durationSeconds: _elapsedSeconds,
      mode: gameMode.value,
    );
    Get.toNamed('/result');
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _resetState() {
    timeLeft.value = gameDuration;
    score.value = 0;
    machineScore.value = 0;
    currentInput.value = '';
    correctAnswers.value = 0;
    totalAttempts.value = 0;
    multiplier.value = 1.0;
    isCorrect.value = false;
    isWrong.value = false;
    _elapsedSeconds = 0;
    gameResult.value = null;
  }

  void _generateQuestion() {
    // Difficulty scales with score
    int maxVal = 10 + (score.value ~/ 30) * 5;
    maxVal = min(maxVal, 99);

    final ops = Operation.values;
    Operation op = ops[_random.nextInt(ops.length)];

    int a, b, answer;

    switch (op) {
      case Operation.add:
        a = _random.nextInt(maxVal) + 1;
        b = _random.nextInt(maxVal) + 1;
        answer = a + b;
        break;
      case Operation.subtract:
        a = _random.nextInt(maxVal) + 1;
        b = _random.nextInt(a) + 1;
        answer = a - b;
        break;
      case Operation.multiply:
        int mMax = min(12, maxVal ~/ 3 + 2);
        a = _random.nextInt(mMax) + 1;
        b = _random.nextInt(mMax) + 1;
        answer = a * b;
        break;
      case Operation.divide:
        b = _random.nextInt(9) + 1;
        answer = _random.nextInt(maxVal ~/ 2 + 1) + 1;
        a = b * answer;
        break;
    }

    currentQuestion.value = Question(
      operandA: a,
      operandB: b,
      operation: op,
      answer: answer,
    );
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        timer.cancel();
        stopGame();
      }
    });
  }

  void _startMachineTimer() {
    _machineTimer?.cancel();
    _machineTimer =
        Timer.periodic(const Duration(seconds: machineIntervalSeconds), (_) {
      if (isGameActive.value) {
        machineScore.value += 10;
      }
    });
  }

  void _updateMultiplier() {
    if (score.value >= 200) {
      multiplier.value = 3.0;
    } else if (score.value >= 100) {
      multiplier.value = 2.0;
    } else if (score.value >= 50) {
      multiplier.value = 1.5;
    } else {
      multiplier.value = 1.0;
    }
  }

  Future<void> _flashCorrect() async {
    isCorrect.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    isCorrect.value = false;
  }

  Future<void> _flashWrong() async {
    isWrong.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    isWrong.value = false;
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _machineTimer?.cancel();
    super.onClose();
  }
}
