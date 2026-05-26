// lib/views/result_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/constants.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';
import '../widgets/chunky_button.dart';

class ResultView extends StatelessWidget {
  const ResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final game      = Get.find<GameController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark  = themeCtrl.isDarkMode;
      final result  = game.gameResult.value;
      if (result == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

      final isVs       = result.mode == GameMode.vsMachine;
      final playerWon  = isVs ? game.score.value >= game.machineScore.value : null;
      final green      = isDark ? AppColors.mint : AppColors.cobalt;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.gradientTop,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.offAllNamed('/'),
                  child: Icon(Icons.arrow_back_rounded,
                      color: isDark ? Colors.white54 : AppColors.cobalt.withOpacity(0.5)),
                ),
                const SizedBox(height: 24),

                // ── Headline ───────────────────────────────────────
                Text(
                  isVs
                      ? (playerWon! ? 'You Win! 🏆' : 'Machine Wins 🤖')
                      : _headline(result.score),
                  style: TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1,
                    color: isDark ? Colors.white : AppColors.cobalt,
                  ),
                ),
                Text(
                  isVs
                      ? (playerWon! ? 'You outpaced the AI!' : 'The machine was faster.')
                      : _subtitle(result.score),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 28),

                // ── Score card ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: green.withOpacity(0.3), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text('${result.score}', style: TextStyle(
                        fontSize: 64, fontWeight: FontWeight.w900, letterSpacing: -2,
                        color: green, height: 1,
                      )),
                      Text('TOTAL SCORE', style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        letterSpacing: 2, color: isDark ? Colors.white38 : Colors.black38,
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Stats grid ─────────────────────────────────────
                Row(
                  children: [
                    Expanded(child: _StatCard(
                        label: 'QPM', value: result.questionsPerMinute.toStringAsFixed(1),
                        sub: 'questions/min', color: AppColors.gradientBottom, isDark: isDark)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard(
                        label: 'Accuracy', value: '${result.accuracy.toStringAsFixed(0)}%',
                        sub: '${result.correctAnswers} of ${result.totalQuestions}',
                        color: green, isDark: isDark)),
                  ],
                ),

                if (isVs) ...[
                  const SizedBox(height: 12),
                  _VsCard(
                    playerScore: result.score,
                    machineScore: game.machineScore.value,
                    isDark: isDark,
                  ),
                ],

                const Spacer(),

                // ── Buttons ────────────────────────────────────────
                ChunkyButton(
                  label: 'Play Again',
                  color: green,
                  shadowColor: AppColors.cobaltDark,
                  textColor: Colors.white,
                  onTap: () {
                    game.startGame();
                    Get.offNamed('/game');
                  },
                ),
                const SizedBox(height: 10),
                ChunkyButton(
                  label: 'Level Map',
                  color: isDark ? AppColors.darkCard : AppColors.keyWhite,
                  shadowColor: isDark ? AppColors.darkBg : AppColors.cobaltShadow16,
                  textColor: isDark ? Colors.white : Colors.black87,
                  onTap: () => Get.offAllNamed('/'),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _headline(int score) {
    if (score >= 300) return 'Math Wizard! 🧙';
    if (score >= 200) return 'On Fire! 🔥';
    if (score >= 100) return 'Nice Work! 👏';
    return 'Good Try! 💪';
  }

  String _subtitle(int score) {
    if (score >= 300) return 'Absolutely incredible performance!';
    if (score >= 200) return 'You\'re on a roll — keep it up!';
    if (score >= 100) return 'Can you beat your score?';
    return 'Practice makes perfect.';
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, sub;
  final Color color;
  final bool isDark;
  const _StatCard({required this.label, required this.value, required this.sub,
    required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            letterSpacing: 1.5, color: color)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.cobalt, letterSpacing: -1)),
        Text(sub, style: TextStyle(fontSize: 11,
            color: isDark ? Colors.white38 : Colors.black38)),
      ]),
    );
  }
}

class _VsCard extends StatelessWidget {
  final int playerScore, machineScore;
  final bool isDark;
  const _VsCard({required this.playerScore, required this.machineScore, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.keyWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        Expanded(child: Column(children: [
          Text('$playerScore', style: const TextStyle(fontSize: 32,
              fontWeight: FontWeight.w900, color: AppColors.cobalt, letterSpacing: -1)),
          const Text('YOU', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              letterSpacing: 2, color: Colors.grey)),
        ])),
        const Text('VS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
            color: Colors.grey)),
        Expanded(child: Column(children: [
          Text('$machineScore', style: const TextStyle(fontSize: 32,
              fontWeight: FontWeight.w900, color: AppColors.gradientBottom, letterSpacing: -1)),
          const Text('MACHINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              letterSpacing: 2, color: Colors.grey)),
        ])),
      ]),
    );
  }
}