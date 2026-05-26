// lib/views/game_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/theme_controller.dart';
import '../core/constants.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';
import '../widgets/numeric_keypad.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    final game      = Get.find<GameController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode;

      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.gradientTop,
        body: Stack(
          children: [
            // ── Main game content ──────────────────────────────────────
            SafeArea(
              child: _GameBody(game: game, isDark: isDark),
            ),
            // ── Flash overlay ──────────────────────────────────────────
            Obx(() {
              if (game.isCorrect.value) {
                return Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: game.isCorrect.value ? 1 : 0,
                      child: Container(
                        color: AppColors.correctGreen.withOpacity(0.08),
                      ),
                    ),
                  ),
                );
              }
              if (game.isWrong.value) {
                return Positioned.fill(
                  child: IgnorePointer(
                    child: Container(color: AppColors.heartDanger.withOpacity(0.08)),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            // ── Mascot toast ───────────────────────────────────────────
            Obx(() => _MascotToast(msg: game.mascotMessage.value, isDark: isDark)),
            // ── Success overlay ────────────────────────────────────────
            Obx(() {
              if (!game.showSuccessOverlay.value) return const SizedBox.shrink();
              return _SuccessOverlay(game: game, isDark: isDark);
            }),
          ],
        ),
      );
    });
  }
}

// ── Main game body ────────────────────────────────────────────────────────────

class _GameBody extends StatelessWidget {
  final GameController game;
  final bool isDark;

  const _GameBody({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // ── Header: close + timer + mode ──────────────────────────
            _Header(game: game, isDark: isDark),
            const SizedBox(height: 12),
            // ── Progress bar ──────────────────────────────────────────
            _ProgressBar(game: game, isDark: isDark),
            const SizedBox(height: 10),
            // ── Hearts ────────────────────────────────────────────────
            _HeartsRow(game: game),
            const SizedBox(height: 8),
            // ── VS bar (when applicable) ──────────────────────────────
            Obx(() {
              if (game.gameMode.value != GameMode.vsMachine) return const SizedBox.shrink();
              return _VsBar(game: game, isDark: isDark);
            }),
            const Spacer(),
            // ── Equation card ─────────────────────────────────────────
            _EquationCard(game: game, isDark: isDark),
            const Spacer(),
            // ── Answer input display ──────────────────────────────────
            _AnswerDisplay(game: game, isDark: isDark),
            const SizedBox(height: 16),
            // ── Keypad ────────────────────────────────────────────────
            NumericKeypad(onKey: game.onKeyTap),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final GameController game;
  final bool isDark;
  const _Header({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Close button
        GestureDetector(
          onTap: () => game.quitGame(),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white.withOpacity(0.30),
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              border: Border.all(color: isDark ? AppColors.darkDivider : Colors.white.withOpacity(0.5)),
            ),
            child: Icon(Icons.close_rounded,
                color: isDark ? Colors.white54 : Colors.black45, size: 20),
          ),
        ),
        const Spacer(),
        // Timer
        Obx(() {
          final pct = game.timeLeft.value / GameController.gameDuration;
          final col = pct > 0.4 ? (isDark ? AppColors.mint : AppColors.cobalt)
              : pct > 0.2 ? AppColors.sunflower
              :             AppColors.heartDanger;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: col.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: col.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_rounded, color: col, size: 16),
                const SizedBox(width: 6),
                Text('${game.timeLeft.value}s',
                    style: TextStyle(color: col, fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          );
        }),
        const Spacer(),
        // Score badge
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.keyWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.cobaltShadow16),
          ),
          child: Row(
            children: [
              Text('⭐', style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('${game.score.value}',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.cobalt,
                  )),
            ],
          ),
        )),
      ],
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final GameController game;
  final bool isDark;
  const _ProgressBar({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final green = isDark ? AppColors.mint : AppColors.cobalt;

    return Obx(() {
      final pct     = game.progressPct.value;
      final bounce  = game.progressBounce.value;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progress',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white38 : Colors.black38,
                      letterSpacing: 1)),
              Text('${(pct * 100).toInt()}%',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: green)),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(builder: (ctx, box) {
            final w = box.maxWidth;
            return Stack(
              children: [
                // Track
                Container(
                  height: 14,
                  width: w,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.keyWhite,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                        color: isDark ? AppColors.darkDivider : AppColors.cobaltShadow16),
                  ),
                ),
                // Fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutBack,
                  height: 14,
                  width: (w * pct).clamp(0, w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [isDark ? green : AppColors.sunflower, (isDark ? green : AppColors.sunflower).withOpacity(0.75)]),
                    borderRadius: BorderRadius.circular(7),
                    // Always keep one shadow entry so Flutter can lerp without
                    // producing a negative blur radius during the transition.
                    boxShadow: [
                      BoxShadow(
                        color: green.withOpacity(bounce ? 0.6 : 0.0),
                        blurRadius: bounce ? 8 : 0,
                        spreadRadius: bounce ? 1 : 0,
                      ),
                    ],
                  ),
                ),
                // Bounce gleam
                if (bounce)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    left: (w * pct).clamp(0, w) - 20,
                    top: 2,
                    child: Container(
                      width: 14, height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      );
    });
  }
}

// ── Hearts row ────────────────────────────────────────────────────────────────

class _HeartsRow extends StatelessWidget {
  final GameController game;
  const _HeartsRow({required this.game});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(GameController.maxHearts, (i) {
        final filled = i < game.hearts.value;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: filled ? AppColors.heartRed : Colors.grey.withOpacity(0.4),
            size: 28,
          ),
        );
      }),
    ));
  }
}

// ── VS bar ────────────────────────────────────────────────────────────────────

class _VsBar extends StatelessWidget {
  final GameController game;
  final bool isDark;
  const _VsBar({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total      = game.score.value + game.machineScore.value;
      final playerPct  = total == 0 ? 0.5 : (game.score.value / total).clamp(0.0, 1.0);

      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('YOU  ${game.score.value}',
                    style: const TextStyle(color: AppColors.cobalt,
                        fontSize: 11, fontWeight: FontWeight.w800)),
                Text('${game.machineScore.value}  AI',
                    style: const TextStyle(color: AppColors.gradientBottom,
                        fontSize: 11, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LayoutBuilder(builder: (ctx, box) {
                final w = box.maxWidth;
                return SizedBox(
                  height: 8,
                  child: Stack(children: [
                    Container(width: w, color: AppColors.gradientBottom),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      width: w * playerPct,
                      color: isDark ? AppColors.mint : AppColors.cobalt,
                    ),
                  ]),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

// ── Equation card ─────────────────────────────────────────────────────────────

class _EquationCard extends StatelessWidget {
  final GameController game;
  final bool isDark;
  const _EquationCard({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Color borderColor;
      if (game.isCorrect.value) {
        borderColor = AppColors.correctGreen;
      } else if (game.isWrong.value) {
        borderColor = AppColors.heartDanger;
      } else {
        borderColor = isDark ? AppColors.darkDivider : AppColors.cobalt.withOpacity(0.20);
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: [
            BoxShadow(
                color: borderColor.withOpacity(0.25),
                blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            if (game.currentQuestion.value != null)
              Text(
                game.currentQuestion.value!.displayString,
                style: TextStyle(
                  fontSize: 44, fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.cobalt,
                  letterSpacing: -1,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            // Streak + correct counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Chip(
                  icon: Icons.check_circle_rounded,
                  label: '${game.correctAnswers.value} correct',
                  color: AppColors.correctGreen,
                ),
                const SizedBox(width: 8),
                if (game.consecutiveCorrect.value >= 2)
                  _Chip(
                    icon: Icons.local_fire_department_rounded,
                    label: '${game.consecutiveCorrect.value} streak',
                    color: AppColors.heartDanger,
                  ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Answer display ────────────────────────────────────────────────────────────

class _AnswerDisplay extends StatelessWidget {
  final GameController game;
  final bool isDark;
  const _AnswerDisplay({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Color accent;
      if (game.isCorrect.value) accent = AppColors.correctGreen;
      else if (game.isWrong.value) accent = AppColors.heartDanger;
      else accent = isDark ? AppColors.cobalt : AppColors.cobalt;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.35), width: 2),
        ),
        child: Center(
          child: Text(
            game.currentInput.value.isEmpty ? '—' : game.currentInput.value,
            style: TextStyle(
              fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1,
              color: game.currentInput.value.isEmpty
                  ? (isDark ? Colors.white24 : Colors.black26)
                  : (isDark ? Colors.white : Colors.black),
            ),
          ),
        ),
      );
    });
  }
}

// ── Mascot toast ──────────────────────────────────────────────────────────────

class _MascotToast extends StatelessWidget {
  final String msg;
  final bool isDark;
  const _MascotToast({required this.msg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (msg.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 24, right: 24,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: msg.isNotEmpty ? 1.0 : 0.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.cobaltShadow16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15),
                  blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              // Placeholder mascot circle
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.mint : AppColors.cobalt).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Text('🦉', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(msg,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Success overlay ───────────────────────────────────────────────────────────

class _SuccessOverlay extends StatelessWidget {
  final GameController game;
  final bool isDark;
  const _SuccessOverlay({required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final result = game.gameResult.value;
    final green  = isDark ? AppColors.mint : AppColors.cobalt;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: green.withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(color: green.withOpacity(0.3),
                    blurRadius: 40, spreadRadius: 4),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated star placeholder (Lottie-style)
                _StarBurst(color: green),
                const SizedBox(height: 16),
                Text('Level Complete!', style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.cobalt,
                )),
                const SizedBox(height: 8),
                Text('Incredible work! 🎉', style: TextStyle(
                    fontSize: 15, color: isDark ? Colors.white54 : Colors.black45)),
                const SizedBox(height: 24),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _OverlayStat(
                        label: 'Score', value: '${result?.score ?? 0}',
                        color: AppColors.sunflower),
                    _OverlayStat(
                        label: 'Accuracy',
                        value: '${result?.accuracy.toStringAsFixed(0) ?? 0}%',
                        color: green),
                    _OverlayStat(
                        label: 'Correct',
                        value: '${result?.correctAnswers ?? 0}',
                        color: AppColors.gradientBottom),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: _ChunkyOverlayButton(
                    label: 'Continue',
                    color: green,
                    shadowColor: isDark ? AppColors.cobaltDark : AppColors.cobaltDark,
                    onTap: game.dismissSuccessOverlay,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StarBurst extends StatefulWidget {
  final Color color;
  const _StarBurst({required this.color});

  @override
  State<_StarBurst> createState() => _StarBurstState();
}

class _StarBurstState extends State<_StarBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _scale  = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _rotate = Tween<double>(begin: -0.05, end: 0.05).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.rotate(
        angle: _rotate.value,
        child: Transform.scale(
          scale: _scale.value,
          child: Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withOpacity(0.15),
              border: Border.all(color: widget.color.withOpacity(0.4), width: 3),
              boxShadow: [
                BoxShadow(color: widget.color.withOpacity(0.4), blurRadius: 24, spreadRadius: 4),
              ],
            ),
            child: const Center(child: Text('⭐', style: TextStyle(fontSize: 52))),
          ),
        ),
      ),
    );
  }
}

class _OverlayStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _OverlayStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _ChunkyOverlayButton extends StatefulWidget {
  final String label;
  final Color color, shadowColor;
  final VoidCallback onTap;
  const _ChunkyOverlayButton({required this.label, required this.color,
    required this.shadowColor, required this.onTap});

  @override
  State<_ChunkyOverlayButton> createState() => _ChunkyOverlayButtonState();
}

class _ChunkyOverlayButtonState extends State<_ChunkyOverlayButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const sh = 4.0;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 56 + (_pressed ? 0 : sh),
        margin: EdgeInsets.only(bottom: _pressed ? sh : 0),
        decoration: BoxDecoration(
          color: widget.shadowColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 56,
          margin: EdgeInsets.only(bottom: _pressed ? 0 : sh),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(widget.label, style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}