// lib/views/result_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final result = game.gameResult.value;
    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determine win/lose for VS mode
    bool? playerWon;
    if (result.mode == GameMode.vsMachine) {
      playerWon = game.score.value >= game.machineScore.value;
    }

    final neonGreen = isDark ? AppColors.neonGreen : AppColors.accentGreen;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Get.offAllNamed('/'),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // ── Outcome headline ─────────────────────────────────────
              if (result.mode == GameMode.vsMachine) ...[
                Text(
                  playerWon! ? 'YOU WIN! 🏆' : 'MACHINE WINS 🤖',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: playerWon ? neonGreen : primary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  playerWon
                      ? 'You outpaced the machine!'
                      : 'The machine was faster. Try again?',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ] else ...[
                Text(
                  'GAME OVER',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _scoreComment(result.score),
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black45,
                    fontSize: 14,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // ── Score card ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '${result.score}',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: primary,
                        letterSpacing: -3,
                        height: 1,
                      ),
                    ),
                    Text(
                      'TOTAL SCORE',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Stats grid ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'QPM',
                      value: result.questionsPerMinute.toStringAsFixed(1),
                      subtitle: 'Questions / min',
                      color: isDark ? AppColors.neonBlue : AppColors.accentBlue,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Accuracy',
                      value: '${result.accuracy.toStringAsFixed(0)}%',
                      subtitle: '${result.correctAnswers} of ${result.totalQuestions}',
                      color: neonGreen,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              if (result.mode == GameMode.vsMachine) ...[
                const SizedBox(height: 12),
                _VsResultCard(
                  playerScore: result.score,
                  machineScore: game.machineScore.value,
                  isDark: isDark,
                  playerWon: playerWon!,
                ),
              ],

              const Spacer(),

              // ── Play Again ───────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  game.startGame();
                  Get.offNamed('/game');
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'PLAY AGAIN',
                      style: TextStyle(
                        color: isDark ? AppColors.darkBg : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Get.offAllNamed('/'),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Center(
                    child: Text(
                      'MAIN MENU',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _scoreComment(int score) {
    if (score >= 300) return 'Incredible! You\'re a math wizard! 🧙';
    if (score >= 200) return 'Excellent work! Keep it up! 🔥';
    if (score >= 100) return 'Good job! Can you beat your score?';
    return 'Nice try! Practice makes perfect.';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _VsResultCard extends StatelessWidget {
  final int playerScore;
  final int machineScore;
  final bool isDark;
  final bool playerWon;

  const _VsResultCard({
    required this.playerScore,
    required this.machineScore,
    required this.isDark,
    required this.playerWon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$playerScore',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.neonGreen : AppColors.accentGreen,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'YOU',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'VS',
            style: TextStyle(
              color: isDark ? Colors.white12 : Colors.black12,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$machineScore',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.neonBlue : AppColors.accentBlue,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  'MACHINE',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
