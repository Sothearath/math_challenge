// lib/core/utils/equation_builder.dart

import 'dart:math';
import '../../models/level_config.dart';

// ── Public API ────────────────────────────────────────────────────────────────

abstract class EquationBuilder {
  /// Returns a display string like "12 + 7 = ?"
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

  // ── Generate ────────────────────────────────────────────────────────────────
  static String generate(LevelConfig level) {
    final op = level.allowedOps[_rng.nextInt(level.allowedOps.length)];

    int a = 0;
    int b = 0;

    switch (op) {
      case MathOp.add:
        a = _rand(1, level.maxOperand);
        b = _rand(1, level.maxOperand);
        break;

      case MathOp.subtract:
        a = _rand(1, level.maxOperand);
        b = _rand(max(1, a ~/ 2), a);

        // Always ensure positive result for UI keypad
        if (!level.allowNegative && b > a) {
          final temp = a;
          a = b;
          b = temp;
        }
        break;

      case MathOp.multiply:
        final cap = max(2, sqrt(level.maxOperand.toDouble()).ceil());
        a = _rand(2, cap);
        b = _rand(2, cap);
        break;

      case MathOp.divide:
      // Ensure clean division + avoid zero issues
        b = _rand(2, min(10, level.maxOperand));

        final maxQuotient = max(2, level.maxOperand ~/ b);
        final quotient = _rand(2, maxQuotient);

        a = b * quotient;

        // safety: ensure both positive (UI constraint)
        a = a.abs();
        b = b.abs();
        break;
    }

    return '$a ${_symbol(op)} $b = ?';
  }

  // ── Answer derivation — pure parse, zero shared state ─────────────────────
  static int deriveAnswer(String equation) {
    // Format: "a OP b = ?"
    final clean = equation.replaceAll(' = ?', '').trim();
    final parts = clean.split(' ');

    if (parts.length != 3) return -999999;

    final a = int.tryParse(parts[0]) ?? 0;
    final op = parts[1];
    final b = int.tryParse(parts[2]) ?? 0;

    switch (op) {
      case '+':
        return a + b;

      case '−':
        return a - b;

      case '×':
        return a * b;

      case '÷':
        return b != 0 ? a ~/ b : 0;

      default:
        return -999999;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static int _rand(int min, int max) {
    if (max <= min) return min;
    return min + _rng.nextInt(max - min + 1);
  }

  static String _symbol(MathOp op) => switch (op) {
    MathOp.add => '+',
    MathOp.subtract => '−',
    MathOp.multiply => '×',
    MathOp.divide => '÷',
  };
}