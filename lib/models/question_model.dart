// lib/models/question_model.dart

enum Operation { add, subtract, multiply, divide }

class Question {
  final int operandA;
  final int operandB;
  final Operation operation;
  final int answer;

  Question({
    required this.operandA,
    required this.operandB,
    required this.operation,
    required this.answer,
  });

  String get operationSymbol {
    switch (operation) {
      case Operation.add:      return '+';
      case Operation.subtract: return '−';
      case Operation.multiply: return '×';
      case Operation.divide:   return '÷';
    }
  }

  String get displayString => '$operandA  $operationSymbol  $operandB';
}

enum GameMode { singlePlayer, vsMachine }

// ── Level / Stage model ────────────────────────────────────────────────────

class LevelStage {
  final int levelIndex;
  final int stageIndex;
  final String title;
  final List<Operation> allowedOps;
  final int maxNumber;
  final int questionsRequired;

  const LevelStage({
    required this.levelIndex,
    required this.stageIndex,
    required this.title,
    required this.allowedOps,
    required this.maxNumber,
    this.questionsRequired = 5,
  });
}

class GameLevel {
  final int index;
  final String title;
  final String emoji;
  final String description;
  final List<LevelStage> stages;

  const GameLevel({
    required this.index,
    required this.title,
    required this.emoji,
    required this.description,
    required this.stages,
  });
}

// ── Predefined level catalogue ─────────────────────────────────────────────

final List<GameLevel> kLevels = [
  GameLevel(
    index: 0, title: 'Intro to Addition', emoji: '➕',
    description: 'Master the basics of adding numbers',
    stages: List.generate(5, (i) => LevelStage(
      levelIndex: 0, stageIndex: i,
      title: 'Add ${i + 1}',
      allowedOps: [Operation.add],
      maxNumber: 10 + i * 5,
      questionsRequired: 5,
    )),
  ),
  GameLevel(
    index: 1, title: 'Subtraction Sprint', emoji: '➖',
    description: 'Race through subtractions',
    stages: List.generate(5, (i) => LevelStage(
      levelIndex: 1, stageIndex: i,
      title: 'Sub ${i + 1}',
      allowedOps: [Operation.subtract],
      maxNumber: 15 + i * 5,
      questionsRequired: 5,
    )),
  ),
  GameLevel(
    index: 2, title: 'Mixed Madness', emoji: '🔀',
    description: 'Add & subtract in a frenzy',
    stages: List.generate(5, (i) => LevelStage(
      levelIndex: 2, stageIndex: i,
      title: 'Mix ${i + 1}',
      allowedOps: [Operation.add, Operation.subtract],
      maxNumber: 20 + i * 5,
      questionsRequired: 6,
    )),
  ),
  GameLevel(
    index: 3, title: 'Multiply Magic', emoji: '✖️',
    description: 'Times tables at lightning speed',
    stages: List.generate(5, (i) => LevelStage(
      levelIndex: 3, stageIndex: i,
      title: 'Mul ${i + 1}',
      allowedOps: [Operation.multiply],
      maxNumber: 5 + i * 2,
      questionsRequired: 6,
    )),
  ),
  GameLevel(
    index: 4, title: 'Division Deep Dive', emoji: '➗',
    description: 'Divide and conquer',
    stages: List.generate(5, (i) => LevelStage(
      levelIndex: 4, stageIndex: i,
      title: 'Div ${i + 1}',
      allowedOps: [Operation.divide],
      maxNumber: 8 + i * 2,
      questionsRequired: 6,
    )),
  ),
  GameLevel(
    index: 5, title: 'Grand Master', emoji: '🏆',
    description: 'All operations — no mercy',
    stages: List.generate(5, (i) => LevelStage(
      levelIndex: 5, stageIndex: i,
      title: 'GM ${i + 1}',
      allowedOps: Operation.values,
      maxNumber: 50 + i * 10,
      questionsRequired: 8,
    )),
  ),
];

class GameResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final int durationSeconds;
  final GameMode mode;
  final bool levelCleared;

  GameResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.durationSeconds,
    required this.mode,
    this.levelCleared = false,
  });

  double get accuracy =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;

  double get questionsPerMinute =>
      durationSeconds == 0 ? 0 : (correctAnswers / durationSeconds) * 60;
}
