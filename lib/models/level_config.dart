// lib/core/models/level_config.dart
//
// LevelConfig — immutable value object that describes one difficulty level.
// kLevels — the full 15-level progression used throughout the app.
//
// Fields used by ArithmeticController:
//   levelNumber       int    1–15
//   label             String 'Beginner' / 'Intermediate' / 'Advanced' / 'Expert'
//   timeLimitSeconds  int    seconds on the countdown clock
//   questionsPerRound int    how many correct answers finish the level
//   xpPerCorrect      int    XP awarded per correct answer
//   complexityPercent int    shown in the dashboard stats bar (5–100 %)
//
// Fields used by equation generation:
//   allowedOps        List<MathOp>  which operations can appear
//   maxOperand        int           upper bound for operands (inclusive)
//   allowNegative     bool          whether answers can be negative
//   allowDecimal      bool          whether operands include one decimal place

/// The operations Brainy can throw at the player.
enum MathOp { add, subtract, multiply, divide }

class LevelConfig {
  const LevelConfig({
    required this.levelNumber,
    required this.label,
    required this.timeLimitSeconds,
    required this.questionsPerRound,
    required this.xpPerCorrect,
    required this.complexityPercent,
    required this.allowedOps,
    required this.maxOperand,
    this.allowNegative = false,
    this.allowDecimal  = false,
  });

  final int            levelNumber;
  final String         label;
  final int            timeLimitSeconds;
  final int            questionsPerRound;
  final int            xpPerCorrect;
  final int            complexityPercent;
  final List<MathOp>   allowedOps;
  final int            maxOperand;
  final bool           allowNegative;
  final bool           allowDecimal;

  /// Convenience: the tier name shown on the level badge chip.
  String get tierLabel {
    if (levelNumber <= 3)  return 'Beginner';
    if (levelNumber <= 6)  return 'Intermediate';
    if (levelNumber <= 10) return 'Advanced';
    return 'Expert';
  }

  @override
  String toString() => 'LevelConfig(level: $levelNumber, label: $label)';
}

// ── 15-level progression ──────────────────────────────────────────────────────
//
// Design principles:
//   • Levels 1–3  (Beginner)     : addition only, single-digit operands.
//   • Levels 4–6  (Intermediate) : add + subtract, two-digit operands, more Qs.
//   • Levels 7–10 (Advanced)     : add + sub + multiply, larger operands,
//                                  tighter timer, negative answers unlocked.
//   • Levels 11–15 (Expert)      : all four ops, large operands, decimals,
//                                  very tight timer.
//
// timeLimitSeconds counts DOWN for the whole round (not per question).
// questionsPerRound is how many correct answers complete the level.

const List<LevelConfig> kLevels = [

  // ── Beginner ────────────────────────────────────────────────────────────────

  LevelConfig(
    levelNumber:       1,
    label:             'Beginner',
    timeLimitSeconds:  60,
    questionsPerRound: 5,
    xpPerCorrect:      10,
    complexityPercent: 5,
    allowedOps:        [MathOp.add],
    maxOperand:        9,
  ),

  LevelConfig(
    levelNumber:       2,
    label:             'Beginner',
    timeLimitSeconds:  55,
    questionsPerRound: 6,
    xpPerCorrect:      10,
    complexityPercent: 10,
    allowedOps:        [MathOp.add],
    maxOperand:        12,
  ),

  LevelConfig(
    levelNumber:       3,
    label:             'Beginner',
    timeLimitSeconds:  50,
    questionsPerRound: 7,
    xpPerCorrect:      12,
    complexityPercent: 15,
    allowedOps:        [MathOp.add, MathOp.subtract],
    maxOperand:        15,
  ),

  // ── Intermediate ────────────────────────────────────────────────────────────

  LevelConfig(
    levelNumber:       4,
    label:             'Intermediate',
    timeLimitSeconds:  50,
    questionsPerRound: 7,
    xpPerCorrect:      14,
    complexityPercent: 25,
    allowedOps:        [MathOp.add, MathOp.subtract],
    maxOperand:        20,
  ),

  LevelConfig(
    levelNumber:       5,
    label:             'Intermediate',
    timeLimitSeconds:  45,
    questionsPerRound: 8,
    xpPerCorrect:      14,
    complexityPercent: 30,
    allowedOps:        [MathOp.add, MathOp.subtract],
    maxOperand:        30,
  ),

  LevelConfig(
    levelNumber:       6,
    label:             'Intermediate',
    timeLimitSeconds:  45,
    questionsPerRound: 8,
    xpPerCorrect:      16,
    complexityPercent: 35,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply],
    maxOperand:        20,
  ),

  // ── Advanced ────────────────────────────────────────────────────────────────

  LevelConfig(
    levelNumber:       7,
    label:             'Advanced',
    timeLimitSeconds:  40,
    questionsPerRound: 9,
    xpPerCorrect:      18,
    complexityPercent: 45,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply],
    maxOperand:        25,
    allowNegative:     true,
  ),

  LevelConfig(
    levelNumber:       8,
    label:             'Advanced',
    timeLimitSeconds:  40,
    questionsPerRound: 10,
    xpPerCorrect:      18,
    complexityPercent: 55,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply],
    maxOperand:        30,
    allowNegative:     true,
  ),

  LevelConfig(
    levelNumber:       9,
    label:             'Advanced',
    timeLimitSeconds:  35,
    questionsPerRound: 10,
    xpPerCorrect:      20,
    complexityPercent: 60,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply, MathOp.divide],
    maxOperand:        30,
    allowNegative:     true,
  ),

  LevelConfig(
    levelNumber:       10,
    label:             'Advanced',
    timeLimitSeconds:  35,
    questionsPerRound: 12,
    xpPerCorrect:      22,
    complexityPercent: 65,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply, MathOp.divide],
    maxOperand:        40,
    allowNegative:     true,
  ),

  // ── Expert ──────────────────────────────────────────────────────────────────

  LevelConfig(
    levelNumber:       11,
    label:             'Expert',
    timeLimitSeconds:  30,
    questionsPerRound: 12,
    xpPerCorrect:      25,
    complexityPercent: 70,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply, MathOp.divide],
    maxOperand:        50,
    allowNegative:     true,
    allowDecimal:      true,
  ),

  LevelConfig(
    levelNumber:       12,
    label:             'Expert',
    timeLimitSeconds:  28,
    questionsPerRound: 14,
    xpPerCorrect:      28,
    complexityPercent: 75,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply, MathOp.divide],
    maxOperand:        60,
    allowNegative:     true,
    allowDecimal:      true,
  ),

  LevelConfig(
    levelNumber:       13,
    label:             'Expert',
    timeLimitSeconds:  25,
    questionsPerRound: 14,
    xpPerCorrect:      30,
    complexityPercent: 82,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply, MathOp.divide],
    maxOperand:        75,
    allowNegative:     true,
    allowDecimal:      true,
  ),

  LevelConfig(
    levelNumber:       14,
    label:             'Expert',
    timeLimitSeconds:  22,
    questionsPerRound: 16,
    xpPerCorrect:      35,
    complexityPercent: 90,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply, MathOp.divide],
    maxOperand:        99,
    allowNegative:     true,
    allowDecimal:      true,
  ),

  LevelConfig(
    levelNumber:       15,
    label:             'Expert',
    timeLimitSeconds:  20,
    questionsPerRound: 20,
    xpPerCorrect:      40,
    complexityPercent: 100,
    allowedOps:        [MathOp.add, MathOp.subtract, MathOp.multiply, MathOp.divide],
    maxOperand:        99,
    allowNegative:     true,
    allowDecimal:      true,
  ),
];