// lib/controllers/arithmetic_controller.dart
//
// FlexiArithmetic: Brainy Challenge
// Drives the entire Active Challenge screen:
//   • Random equation generation with adaptive difficulty
//   • 60-second countdown timer (Ticker-based, never drifts)
//   • Custom numpad input handling
//   • Correct / wrong validation with haptics
//   • Heart-loss → game-over flow
//   • Score + streak tracking
//   • Notifies DashboardController on session end

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/constants.dart';
import 'dashboard_controller.dart';
import 'heart_controller.dart';

// ─── Equation model ───────────────────────────────────────────────────────────

enum MathOp { add, subtract, multiply }

class Equation {
  final int    a;
  final int    b;
  final MathOp op;

  const Equation({required this.a, required this.b, required this.op});

  int get answer {
    switch (op) {
      case MathOp.add:      return a + b;
      case MathOp.subtract: return a - b;
      case MathOp.multiply: return a * b;
    }
  }

  String get symbol {
    switch (op) {
      case MathOp.add:      return '+';
      case MathOp.subtract: return '−';
      case MathOp.multiply: return '×';
    }
  }

  @override
  String toString() => '$a $symbol $b = ?';
}

// ─── Game state enum ──────────────────────────────────────────────────────────

enum GameState { playing, timeUp, gameOver, idle }

// ─── Controller ───────────────────────────────────────────────────────────────

class ArithmeticController extends GetxController
    with GetTickerProviderStateMixin {

  // ── Public reactive state ─────────────────────────────────────────────────

  final Rx<Equation?>   currentEquation  = Rx<Equation?>(null);
  final RxString        inputValue       = ''.obs;
  final RxInt           score            = 0.obs;
  final RxInt           lives            = 3.obs;
  final RxInt           streak           = 0.obs;
  final RxInt           bestStreak       = 0.obs;
  final RxInt           timeLeft         = 60.obs;
  final Rx<GameState>   gameState        = GameState.idle.obs;

  /// 0.0 → 1.0 — drives the progress bar.
  final RxDouble        progress         = 1.0.obs;

  /// Flash state for the equation box: null | 'correct' | 'wrong'
  final RxnString       equationFlash    = RxnString(null);

  // ── Config ────────────────────────────────────────────────────────────────

  static const int  _totalSeconds   = 60;
  static const int  _bonusSeconds   = 3;    // added per correct answer
  static const int  _maxInputLength = 5;
  static const int  maxLives        = 3;
  static const int  _maxLives       = maxLives;

  // ── Internals ─────────────────────────────────────────────────────────────

  final _rng = math.Random();
  late  Ticker _ticker;
  Duration     _elapsed     = Duration.zero;
  Duration     _lastTick    = Duration.zero;
  int          _totalAsked  = 0;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _ticker = createTicker(_onTick);
    startGame();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    // startGame();
  }

  @override
  void onClose() {
    _ticker.dispose();
    super.onClose();
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Call from the view's initState / onReady.
  void startGame() {
    score.value      = 0;
    lives.value      = _maxLives;
    streak.value     = 0;
    bestStreak.value = 0;
    timeLeft.value   = _totalSeconds;
    progress.value   = 1.0;
    inputValue.value = '';
    _totalAsked      = 0;
    _elapsed         = Duration.zero;
    _lastTick        = Duration.zero;
    gameState.value  = GameState.playing;

    _nextEquation();
    _ticker.start();
  }

  void stopGame() {
    _ticker.stop();
  }

  // ── Numpad input ──────────────────────────────────────────────────────────

  void onDigitTap(String digit) {
    if (gameState.value != GameState.playing) return;
    if (inputValue.value.length >= _maxInputLength)  return;
    if (inputValue.value.isEmpty && digit == '0')    return; // no leading zero
    HapticFeedback.selectionClick();
    inputValue.value += digit;
  }

  void onDeleteTap() {
    if (gameState.value != GameState.playing) return;
    if (inputValue.value.isEmpty) return;
    HapticFeedback.selectionClick();
    inputValue.value =
        inputValue.value.substring(0, inputValue.value.length - 1);
  }

  void onCheckTap() {
    if (gameState.value != GameState.playing) return;
    if (inputValue.value.isEmpty) return;

    final guess = int.tryParse(inputValue.value);
    if (guess == null) { inputValue.value = ''; return; }

    _totalAsked++;

    if (guess == currentEquation.value?.answer) {
      _handleCorrect();
    } else {
      _handleWrong();
    }
  }

  // ── Private game logic ────────────────────────────────────────────────────

  void _onTick(Duration elapsed) {
    final delta = elapsed - _lastTick;
    _lastTick   = elapsed;
    _elapsed   += delta;

    // Decrement one second at a time
    final newTimeLeft =
    (_totalSeconds - _elapsed.inSeconds).clamp(0, _totalSeconds);

    if (newTimeLeft != timeLeft.value) {
      timeLeft.value = newTimeLeft;
      progress.value = newTimeLeft / _totalSeconds;
    }

    if (newTimeLeft <= 0) {
      _ticker.stop();
      _endGame(GameState.timeUp);
    }
  }

  void _handleCorrect() {
    HapticFeedback.lightImpact();

    score.value++;
    streak.value++;
    if (streak.value > bestStreak.value) bestStreak.value = streak.value;

    equationFlash.value = 'correct';
    Future.delayed(const Duration(milliseconds: 350), () {
      equationFlash.value = null;
      _nextEquation();
    });

    // Bonus time — rewind elapsed by bonus seconds
    final bonus = Duration(seconds: _bonusSeconds);
    if (_elapsed > bonus) {
      _elapsed -= bonus;
    } else {
      _elapsed = Duration.zero;
    }
    inputValue.value = '';
  }

  void _handleWrong() {
    HapticFeedback.mediumImpact();

    streak.value = 0;
    equationFlash.value = 'wrong';

    Future.delayed(const Duration(milliseconds: 400), () {
      equationFlash.value = null;
      inputValue.value    = '';
    });

    lives.value--;
    // Mirror to HeartController so the HUD hearts animate
    if (Get.isRegistered<HeartController>()) {
      Get.find<HeartController>().loseLife();
    }

    if (lives.value <= 0) {
      _ticker.stop();
      Future.delayed(const Duration(milliseconds: 450), () {
        _endGame(GameState.gameOver);
      });
    }
  }

  void _endGame(GameState state) {
    gameState.value = state;
    _ticker.stop();

    // Record the session in DashboardController
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>()
          .recordSession(score.value, _totalAsked);
    }
  }

  void _nextEquation() {
    currentEquation.value = _generateEquation();
  }

  Equation _generateEquation() {
    // Adaptive: unlock more operations and larger numbers as score grows.
    final opPool = _availableOps();
    final op     = opPool[_rng.nextInt(opPool.length)];

    int a, b;
    switch (op) {
      case MathOp.add:
        final max = _rangeFor(op);
        a = _rng.nextInt(max) + 1;
        b = _rng.nextInt(max) + 1;
        break;
      case MathOp.subtract:
        final max = _rangeFor(op);
        a = _rng.nextInt(max) + 1;
        b = _rng.nextInt(a) + 1;  // ensure a >= b → answer >= 0
        break;
      case MathOp.multiply:
        final max = _rangeFor(op);
        a = _rng.nextInt(max) + 2;
        b = _rng.nextInt(10)  + 2;
        break;
    }

    return Equation(a: a, b: b, op: op);
  }

  List<MathOp> _availableOps() {
    if (score.value < 5)  return [MathOp.add];
    if (score.value < 10) return [MathOp.add, MathOp.subtract];
    return MathOp.values;
  }

  int _rangeFor(MathOp op) {
    // Range grows with score, capped per operation.
    final tier = (score.value / 10).floor();
    switch (op) {
      case MathOp.add:      return math.min(10 + tier * 15, 99);
      case MathOp.subtract: return math.min(10 + tier * 15, 99);
      case MathOp.multiply: return math.min(5  + tier * 2,  15);
    }
  }

  // ── Convenience getters ───────────────────────────────────────────────────

  bool get isTimeWarning  => timeLeft.value <= 10;
  bool get hasInput       => inputValue.value.isNotEmpty;
  String get streakLabel  =>
      streak.value == 0 ? '0 correct in a row'
          : '${streak.value} correct in a row';
}