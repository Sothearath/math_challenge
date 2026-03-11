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
      case Operation.add:
        return '+';
      case Operation.subtract:
        return '−';
      case Operation.multiply:
        return '×';
      case Operation.divide:
        return '÷';
    }
  }

  String get displayString => '$operandA  $operationSymbol  $operandB  =  ?';
}

class GameResult {
  final int totalQuestions;
  final int correctAnswers;
  final int score;
  final int durationSeconds;
  final GameMode mode;

  GameResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.score,
    required this.durationSeconds,
    required this.mode,
  });

  double get accuracy =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;

  double get questionsPerMinute =>
      durationSeconds == 0 ? 0 : (correctAnswers / durationSeconds) * 60;
}

enum GameMode { singlePlayer, vsMachine }
