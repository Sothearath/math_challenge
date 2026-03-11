// lib/views/game_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';
import '../widgets/numeric_keypad.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final error = Theme.of(context).colorScheme.error;

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          // Full-screen flash overlay
          Color? flashColor;
          if (game.isCorrect.value) {
            flashColor = (isDark ? AppColors.neonGreen : AppColors.accentGreen)
                .withOpacity(0.12);
          } else if (game.isWrong.value) {
            flashColor = error.withOpacity(0.12);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            color: flashColor ?? Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // ── Header ───────────────────────────────────────────
                  _Header(game: game, isDark: isDark, primary: primary),

                  const SizedBox(height: 8),

                  // ── VS Machine progress bar ───────────────────────────
                  if (game.gameMode.value == GameMode.vsMachine)
                    _VsBar(game: game, isDark: isDark),

                  const SizedBox(height: 16),

                  // ── Score & multiplier ────────────────────────────────
                  _ScoreRow(game: game, isDark: isDark, primary: primary),

                  const Spacer(),

                  // ── Equation display ──────────────────────────────────
                  _EquationDisplay(
                    game: game,
                    isDark: isDark,
                    primary: primary,
                    error: error,
                  ),

                  const Spacer(),

                  // ── Input display ─────────────────────────────────────
                  _InputDisplay(
                    game: game,
                    isDark: isDark,
                    primary: primary,
                    error: error,
                  ),

                  const SizedBox(height: 20),

                  // ── Keypad ────────────────────────────────────────────
                  NumericKeypad(onKey: game.onKeyTap),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final GameController game;
  final bool isDark;
  final Color primary;

  const _Header({
    required this.game,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            game.stopGame();
            Get.back();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.close_rounded,
              color: isDark ? Colors.white54 : Colors.black54,
              size: 20,
            ),
          ),
        ),
        // Timer
        Obx(() {
          final pct = game.timeLeft.value / GameController.gameDuration;
          final timerColor = pct > 0.4
              ? primary
              : pct > 0.2
              ? (isDark ? AppColors.neonYellow : Colors.orange)
              : (isDark ? AppColors.neonPink : AppColors.accentRed);

          return Row(
            children: [
              Icon(Icons.timer_rounded, color: timerColor, size: 18),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: timerColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
                child: Text('${game.timeLeft.value}'),
              ),
              Text(
                's',
                style: TextStyle(
                  color: timerColor.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
        // Mode badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Obx(
            () => Text(
              game.gameMode.value == GameMode.singlePlayer ? 'SOLO' : 'VS AI',
              style: TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VsBar extends StatelessWidget {
  final GameController game;
  final bool isDark;

  const _VsBar({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = game.score.value + game.machineScore.value;
      final playerPct = total == 0 ? 0.5 : game.score.value / total;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOU  ${game.score.value}',
                style: TextStyle(
                  color: isDark ? AppColors.neonGreen : AppColors.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${game.machineScore.value}  AI',
                style: TextStyle(
                  color: isDark ? AppColors.neonBlue : AppColors.accentBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final playerWidth = (playerPct.clamp(0.0, 1.0) * totalWidth);
                return SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      // Machine bar (full width background)
                      Container(
                        width: totalWidth,
                        color: isDark
                            ? AppColors.neonBlue
                            : AppColors.accentBlue,
                      ),
                      // Player bar (animated overlay)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        width: playerWidth,
                        color: isDark
                            ? AppColors.neonGreen
                            : AppColors.accentGreen,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _ScoreRow extends StatelessWidget {
  final GameController game;
  final bool isDark;
  final Color primary;

  const _ScoreRow({
    required this.game,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${game.score.value}',
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -2,
              height: 1,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: primary.withOpacity(0.3)),
                ),
                child: Text(
                  '×${game.multiplier.value.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'pts',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EquationDisplay extends StatelessWidget {
  final GameController game;
  final bool isDark;
  final Color primary;
  final Color error;

  const _EquationDisplay({
    required this.game,
    required this.isDark,
    required this.primary,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Color borderColor = primary.withOpacity(0.2);
      if (game.isCorrect.value) {
        borderColor = isDark ? AppColors.neonGreen : AppColors.accentGreen;
      } else if (game.isWrong.value) {
        borderColor = error;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            if (game.currentQuestion.value != null)
              Text(
                game.currentQuestion.value!.displayString,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statChip(
                  icon: Icons.check_rounded,
                  value: '${game.correctAnswers.value}',
                  color: isDark ? AppColors.neonGreen : AppColors.accentGreen,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _statChip(
                  icon: Icons.question_mark_rounded,
                  value: '${game.totalAttempts.value}',
                  color: isDark ? Colors.white38 : Colors.black38,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _statChip({
    required IconData icon,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputDisplay extends StatelessWidget {
  final GameController game;
  final bool isDark;
  final Color primary;
  final Color error;

  const _InputDisplay({
    required this.game,
    required this.isDark,
    required this.primary,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Color accentColor = primary;
      if (game.isCorrect.value) {
        accentColor = isDark ? AppColors.neonGreen : AppColors.accentGreen;
      } else if (game.isWrong.value) {
        accentColor = error;
      }

      final displayText = game.currentInput.value.isEmpty
          ? '—'
          : game.currentInput.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: game.currentInput.value.isEmpty
                  ? (isDark ? Colors.white24 : Colors.black26)
                  : (isDark ? Colors.white : Colors.black),
              letterSpacing: -1,
            ),
          ),
        ),
      );
    });
  }
}
