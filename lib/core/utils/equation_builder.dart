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

        // Always ensure positive result if requested by UI constraint
        if (!level.allowNegative && b > a) {
          final temp = a;
          a = b;
          b = temp;
        }
        break;

      case MathOp.multiply:
      // IMPROVEMENT: Protect multi-digit scaling. If maxOperand is forced lower
      // by the controller, we scale down the multipliers gracefully.
        if (level.maxOperand <= 12) {
          // Downgraded or early levels: Single digit kids facts (e.g. 2x3 to 5x5)
          a = _rand(2, 5);
          b = _rand(2, 9);
        } else if (level.maxOperand <= 30) {
          // Standard middle tier
          a = _rand(2, 9);
          b = _rand(2, 12);
        } else {
          // Hard / Expert Multi-digit challenge
          a = _rand(3, max(12, level.maxOperand ~/ 6));
          b = _rand(3, max(12, level.maxOperand ~/ 8));
        }
        break;

      case MathOp.divide:
      // IMPROVEMENT: Safe layout for division bounds mapping
        int maxDivisor = min(10, level.maxOperand ~/ 2).clamp(2, 12);
        b = _rand(2, maxDivisor);

        final maxQuotient = max(2, level.maxOperand ~/ b);
        final quotient = _rand(2, maxQuotient);

        a = b * quotient;
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