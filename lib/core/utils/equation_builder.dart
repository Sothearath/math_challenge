// lib/core/utils/equation_builder.dart

import 'dart:math';
import '../../models/level_config.dart';

// ── Public API ────────────────────────────────────────────────────────────────

abstract class EquationBuilder {
  /// Returns a display string like "12 + 7 = ?" and encodes the answer
  /// directly inside the string so AnswerChecker never needs shared state.
  static String generate(LevelConfig level) =>
      _EquationEngine.generate(level);
}

abstract class AnswerChecker {
  /// Derives the answer by parsing the equation string — no static state.
  static bool check(String equation, int answer) =>
      _EquationEngine.deriveAnswer(equation) == answer;
}

// ── Engine ────────────────────────────────────────────────────────────────────
abstract class _EquationEngine {
  static final _rng = Random();

  // ── Generate ─────────────────────────────────────────────────────────────────
  static String generate(LevelConfig level) {
    final op = level.allowedOps[_rng.nextInt(level.allowedOps.length)];

    int a, b;

    switch (op) {
      case MathOp.add:
        a = _rand(1, level.maxOperand);
        b = _rand(1, level.maxOperand);

      case MathOp.subtract:
        a = _rand(1, level.maxOperand);
        b = _rand(1, level.maxOperand);
        // Keep answer non-negative on easier levels
        if (!level.allowNegative && b > a) { final t = a; a = b; b = t; }

      case MathOp.multiply:
        final cap = max(2, sqrt(level.maxOperand.toDouble()).ceil() + 3);
        a = _rand(2, cap);
        b = _rand(2, cap);

      case MathOp.divide:
      // Build a ÷ b = quotient so answer is always whole
        b = _rand(2, min(12, level.maxOperand));
        final quotient = _rand(2, max(2, level.maxOperand ~/ b));
        a = b * quotient;
    }

    return '${a} ${_symbol(op)} ${b} = ?';
  }

  // ── Answer derivation — pure parse, zero shared state ─────────────────────
  static int deriveAnswer(String equation) {
    // Format: "a OP b = ?"
    final clean = equation.replaceAll(' = ?', '').trim();
    final parts = clean.split(' ');
    if (parts.length != 3) return -999999;

    final a  = int.tryParse(parts[0]) ?? 0;
    final op = parts[1];
    final b  = int.tryParse(parts[2]) ?? 0;

    switch (op) {
      case '+':  return a + b;
      case '−':  return a - b;
      case '×':  return a * b;
      case '÷':  return b != 0 ? a ~/ b : 0;
      default:   return -999999;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  static int _rand(int min, int max) {
    if (max <= min) return min;
    return min + _rng.nextInt(max - min + 1);
  }

  static String _symbol(MathOp op) => switch (op) {
    MathOp.add      => '+',
    MathOp.subtract => '−',
    MathOp.multiply => '×',
    MathOp.divide   => '÷',
  };
}