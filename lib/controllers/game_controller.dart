// lib/controllers/game_controller.dart

import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../models/question_model.dart';
import 'streak_controller.dart';

class GameController extends GetxController {
  static const int gameDuration    = 60;
  static const int machineInterval = 3;
  static const int maxHearts       = 3;
  static const int streakToastAt   = 5;

  // ── Observables ─────────────────────────────────────────────────────────
  final RxInt    timeLeft           = gameDuration.obs;
  final RxInt    score              = 0.obs;
  final RxInt    machineScore       = 0.obs;
  final RxString currentInput       = ''.obs;
  final RxBool   isGameActive       = false.obs;
  final RxBool   isCorrect          = false.obs;
  final RxBool   isWrong            = false.obs;
  final RxInt    hearts             = maxHearts.obs;
  final RxInt    correctAnswers     = 0.obs;
  final RxInt    totalAttempts      = 0.obs;
  final RxInt    consecutiveCorrect = 0.obs;
  final RxDouble progressPct        = 0.0.obs;
  final RxDouble multiplier         = 1.0.obs;
  final RxString mascotMessage      = ''.obs;
  final RxBool   showSuccessOverlay = false.obs;
  final RxBool   progressBounce     = false.obs; // triggers bounce anim

  final Rx<Question?>   currentQuestion = Rx<Question?>(null);
  final Rx<GameMode>    gameMode        = GameMode.singlePlayer.obs;
  final Rx<GameResult?> gameResult      = Rx<GameResult?>(null);
  final Rx<LevelStage?> currentStage    = Rx<LevelStage?>(null);

  // ── Internals ────────────────────────────────────────────────────────────
  Timer? _countdownTimer;
  Timer? _machineTimer;
  Timer? _mascotTimer;
  final Random _random = Random();
  int _elapsedSeconds  = 0;
  int _questionsInStage = 0;

  // ── Public API ────────────────────────────────────────────────────────────

  void setMode(GameMode mode) => gameMode.value = mode;

  void startStage(LevelStage stage) {
    currentStage.value = stage;
    _resetState();
    isGameActive.value = true;
    _generateQuestion();
    _startCountdown();
    if (gameMode.value == GameMode.vsMachine) _startMachineTimer();
  }

  void startGame() {
    currentStage.value = null;
    _resetState();
    isGameActive.value = true;
    _generateQuestion();
    _startCountdown();
    if (gameMode.value == GameMode.vsMachine) _startMachineTimer();
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
      if (currentInput.value.length < 6) currentInput.value += key;
    }
  }

  void _submitAnswer() {
    if (currentInput.value.isEmpty || currentQuestion.value == null) return;
    final input = int.tryParse(currentInput.value);
    totalAttempts.value++;

    if (input == currentQuestion.value!.answer) {
      correctAnswers.value++;
      _questionsInStage++;
      consecutiveCorrect.value++;
      _updateMultiplier();
      score.value += (10 * multiplier.value).round();

      // Progress bar update + bounce trigger
      final required = currentStage.value?.questionsRequired ?? 10;
      progressPct.value = (_questionsInStage / required).clamp(0.0, 1.0);
      _triggerProgressBounce();

      // Mascot streak toast
      if (consecutiveCorrect.value == streakToastAt) {
        _showMascot('🔥 On fire! ${consecutiveCorrect.value} in a row!');
      } else if (consecutiveCorrect.value > streakToastAt &&
          consecutiveCorrect.value % streakToastAt == 0) {
        _showMascot('⚡ Unstoppable! Keep going!');
      }

      _flashCorrect();

      // Stage complete?
      if (currentStage.value != null && _questionsInStage >= required) {
        _completeStage();
        return;
      }
    } else {
      consecutiveCorrect.value = 0;
      multiplier.value = max(1.0, multiplier.value - 0.5);
      hearts.value--;
      _showMascot('💙 Don\'t give up! You\'ve got this!');
      _flashWrong();

      if (hearts.value <= 0) {
        _endGame(levelCleared: false);
        return;
      }
    }

    currentInput.value = '';
    _generateQuestion();
  }

  void _completeStage() {
    _countdownTimer?.cancel();
    _machineTimer?.cancel();
    isGameActive.value = false;
    showSuccessOverlay.value = true;

    final streak = Get.find<StreakController>();
    streak.recordSession(
      questionsCorrect: correctAnswers.value,
      stageCleared: true,
      levelIdx: currentStage.value!.levelIndex,
      stageIdx: currentStage.value!.stageIndex,
    );

    gameResult.value = GameResult(
      totalQuestions: totalAttempts.value,
      correctAnswers: correctAnswers.value,
      score: score.value,
      durationSeconds: _elapsedSeconds,
      mode: gameMode.value,
      levelCleared: true,
    );
  }

  void dismissSuccessOverlay() {
    showSuccessOverlay.value = false;
    Get.offAllNamed('/');
  }

  void _endGame({bool levelCleared = false}) {
    _countdownTimer?.cancel();
    _machineTimer?.cancel();
    isGameActive.value = false;

    final streak = Get.find<StreakController>();
    streak.recordSession(
      questionsCorrect: correctAnswers.value,
      stageCleared: levelCleared,
      levelIdx: currentStage.value?.levelIndex ?? 0,
      stageIdx: currentStage.value?.stageIndex ?? 0,
    );

    gameResult.value = GameResult(
      totalQuestions: totalAttempts.value,
      correctAnswers: correctAnswers.value,
      score: score.value,
      durationSeconds: _elapsedSeconds,
      mode: gameMode.value,
      levelCleared: levelCleared,
    );
    Get.toNamed('/result');
  }

  void stopGame() => _endGame(levelCleared: false);

  // ── Private helpers ───────────────────────────────────────────────────────

  void _resetState() {
    timeLeft.value            = gameDuration;
    score.value               = 0;
    machineScore.value        = 0;
    currentInput.value        = '';
    correctAnswers.value      = 0;
    totalAttempts.value       = 0;
    multiplier.value          = 1.0;
    hearts.value              = maxHearts;
    consecutiveCorrect.value  = 0;
    progressPct.value         = 0.0;
    isCorrect.value           = false;
    isWrong.value             = false;
    mascotMessage.value       = '';
    showSuccessOverlay.value  = false;
    progressBounce.value      = false;
    gameResult.value          = null;
    _elapsedSeconds           = 0;
    _questionsInStage         = 0;
  }

  void _generateQuestion() {
    final stage  = currentStage.value;
    final ops    = stage?.allowedOps ?? Operation.values;
    final maxVal = stage?.maxNumber ?? (10 + (score.value ~/ 30) * 5).clamp(10, 99);
    final op     = ops[_random.nextInt(ops.length)];

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
        final mMax = min(12, (maxVal ~/ 3) + 2);
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
    currentQuestion.value =
        Question(operandA: a, operandB: b, operation: op, answer: answer);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _elapsedSeconds++;
      if (timeLeft.value > 0) {
        timeLeft.value--;
      } else {
        t.cancel();
        _endGame(levelCleared: false);
      }
    });
  }

  void _startMachineTimer() {
    _machineTimer?.cancel();
    _machineTimer = Timer.periodic(const Duration(seconds: machineInterval), (_) {
      if (isGameActive.value) machineScore.value += 10;
    });
  }

  void _updateMultiplier() {
    if (score.value >= 200)      multiplier.value = 3.0;
    else if (score.value >= 100) multiplier.value = 2.0;
    else if (score.value >= 50)  multiplier.value = 1.5;
    else                         multiplier.value = 1.0;
  }

  Future<void> _triggerProgressBounce() async {
    progressBounce.value = true;
    await Future.delayed(const Duration(milliseconds: 300));
    progressBounce.value = false;
  }

  Future<void> _flashCorrect() async {
    isCorrect.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    isCorrect.value = false;
  }

  Future<void> _flashWrong() async {
    isWrong.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    isWrong.value = false;
  }

  void _showMascot(String msg) {
    _mascotTimer?.cancel();
    mascotMessage.value = msg;
    _mascotTimer = Timer(const Duration(seconds: 3), () {
      mascotMessage.value = '';
    });
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    _machineTimer?.cancel();
    _mascotTimer?.cancel();
    super.onClose();
  }
}
