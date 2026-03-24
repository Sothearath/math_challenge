// lib/views/level_map_view.dart
// Scrollable vertical path map — Duolingo style

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/streak_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';
import '../widgets/chunky_button.dart';

class LevelMapView extends StatelessWidget {
  const LevelMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    final streak    = Get.find<StreakController>();

    return Obx(() {
      final isDark  = themeCtrl.isDarkMode;
      final bg      = isDark ? AppColors.darkBg     : AppColors.lightBg;
      final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

      return Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            _TopBar(isDark: isDark, streak: streak, surface: surface),
            // ── Scrollable map ───────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: kLevels.length,
                itemBuilder: (ctx, i) => _LevelSection(
                  level: kLevels[i],
                  isDark: isDark,
                  streak: streak,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Top bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool isDark;
  final StreakController streak;
  final Color surface;

  const _TopBar({required this.isDark, required this.streak, required this.surface});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Container(
      color: surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20, right: 20, bottom: 12,
      ),
      child: Row(
        children: [
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MATH', style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900,
                color: isDark ? AppColors.neonGreen : AppColors.duoGreen,
                letterSpacing: -0.5, height: 1,
              )),
              Text('CHALLENGE', style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : Colors.black,
                letterSpacing: -0.5, height: 1,
              )),
            ],
          ),
          const Spacer(),
          // Streak badge
          Obx(() => _StreakBadge(days: streak.streakDays.value, isDark: isDark)),
          const SizedBox(width: 12),
          // Daily goal ring
          Obx(() => _DailyRing(progress: streak.dailyProgress, isDark: isDark)),
          const SizedBox(width: 12),
          // Theme toggle
          GestureDetector(
            onTap: themeCtrl.toggleTheme,
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: 18,
                color: isDark ? AppColors.neonYellow : AppColors.skyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int days;
  final bool isDark;
  const _StreakBadge({required this.days, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonOrange.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text('$days', style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w800,
            color: AppColors.neonOrange,
          )),
        ],
      ),
    );
  }
}

class _DailyRing extends StatelessWidget {
  final double progress;
  final bool isDark;
  const _DailyRing({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppColors.neonGreen : AppColors.duoGreen;
    return Tooltip(
      message: 'Daily goal: ${(progress * 100).toInt()}%',
      child: SizedBox(
        width: 36, height: 36,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
            Text('${(progress * 100).toInt()}',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87)),
          ],
        ),
      ),
    );
  }
}

// ── Level section ────────────────────────────────────────────────────────────

class _LevelSection extends StatelessWidget {
  final GameLevel level;
  final bool isDark;
  final StreakController streak;

  const _LevelSection({
    required this.level,
    required this.isDark,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final idx   = level.index;
    final color = AppColors.levelColors[idx % AppColors.levelColors.length];
    final dark  = AppColors.levelColorsDark[idx % AppColors.levelColorsDark.length];

    // Check if any stage in this level is unlocked
    final levelUnlocked = streak.isStageUnlocked(idx, 0);

    return Column(
      children: [
        // ── Level header ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: levelUnlocked ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: levelUnlocked ? color : Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(level.emoji,
                    style: TextStyle(fontSize: 22,
                      color: levelUnlocked ? null : Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level.title,
                      style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: levelUnlocked
                          ? (isDark ? Colors.white : Colors.black)
                          : Colors.grey,
                      )),
                    Text(level.description,
                      style: TextStyle(fontSize: 12,
                        color: levelUnlocked
                          ? (isDark ? Colors.white54 : Colors.black45)
                          : Colors.grey.withOpacity(0.5),
                      )),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Stage path ───────────────────────────────────────────────
        // Obx(() =>
            _StagePath(
          level: level,
          color: color,
          shadowColor: dark,
          isDark: isDark,
          streak: streak,
        ),
          // ),

        const SizedBox(height: 8),
        Divider(color: isDark ? Colors.white10 : Colors.black12, indent: 20, endIndent: 20),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _StagePath extends StatelessWidget {
  final GameLevel level;
  final Color color;
  final Color shadowColor;
  final bool isDark;
  final StreakController streak;

  const _StagePath({
    required this.level,
    required this.color,
    required this.shadowColor,
    required this.isDark,
    required this.streak,
  });

  // Zigzag offsets to simulate Duolingo path
  static const List<double> _offsets = [0.0, 0.35, 0.0, -0.35, 0.0];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final centerX = screenW / 2;
    const nodeSize = 64.0;

    return SizedBox(
      height: level.stages.length * 90.0,
      child: Stack(
        children: [
          // ── Connecting path lines ──────────────────────────────────
          CustomPaint(
            size: Size(screenW, level.stages.length * 90.0),
            painter: _PathPainter(
              offsets: _offsets,
              nodeCount: level.stages.length,
              color: isDark ? Colors.white12 : Colors.black12,
              nodeSize: nodeSize,
              centerX: centerX,
            ),
          ),
          // ── Stage nodes ────────────────────────────────────────────
          ...List.generate(level.stages.length, (i) {
            final stage     = level.stages[i];
            final completed = streak.isStageCompleted(level.index, i);
            final unlocked  = streak.isStageUnlocked(level.index, i);
            final xFraction = _offsets[i % _offsets.length];
            final x = centerX + xFraction * (centerX * 0.55) - nodeSize / 2;
            final y = i * 90.0 + 10.0;

            return Positioned(
              left: x, top: y,
              child: _StageNode(
                stage: stage,
                color: color,
                shadowColor: shadowColor,
                isDark: isDark,
                completed: completed,
                unlocked: unlocked,
                index: i,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  final List<double> offsets;
  final int nodeCount;
  final Color color;
  final double nodeSize;
  final double centerX;

  const _PathPainter({
    required this.offsets,
    required this.nodeCount,
    required this.color,
    required this.nodeSize,
    required this.centerX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < nodeCount - 1; i++) {
      final x1 = centerX + offsets[i % offsets.length] * (centerX * 0.55);
      final y1 = i * 90.0 + 10.0 + nodeSize / 2;
      final x2 = centerX + offsets[(i + 1) % offsets.length] * (centerX * 0.55);
      final y2 = (i + 1) * 90.0 + 10.0 + nodeSize / 2;
      if (i == 0) path.moveTo(x1, y1);
      path.cubicTo(x1, y1 + 20, x2, y2 - 20, x2, y2);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PathPainter old) => false;
}

class _StageNode extends StatelessWidget {
  final LevelStage stage;
  final Color color;
  final Color shadowColor;
  final bool isDark;
  final bool completed;
  final bool unlocked;
  final int index;

  const _StageNode({
    required this.stage, required this.color, required this.shadowColor,
    required this.isDark, required this.completed, required this.unlocked,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    const size = 64.0;
    const shadow = 5.0;

    Color bg, iconColor, borderColor;
    if (completed) {
      bg = color; iconColor = Colors.white; borderColor = shadowColor;
    } else if (unlocked) {
      bg = isDark ? AppColors.darkCard : Colors.white;
      iconColor = color;
      borderColor = color;
    } else {
      bg = isDark ? AppColors.darkCard.withOpacity(0.5) : Colors.grey.shade200;
      iconColor = Colors.grey;
      borderColor = Colors.grey.withOpacity(0.3);
    }

    Widget node = GestureDetector(
      onTap: unlocked
        ? () => _launchStage(context)
        : () => Get.snackbar(
            '🔒 Locked', 'Complete the previous stage first!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            colorText: isDark ? Colors.white : Colors.black,
            duration: const Duration(seconds: 2),
          ),
      child: Column(
        children: [
          Container(
            width: size,
            height: size + shadow,
            child: Stack(
              children: [
                // Shadow layer
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    height: size,
                    decoration: BoxDecoration(
                      color: borderColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Face layer
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 2.5),
                    ),
                    child: Center(
                      child: completed
                        ? Icon(Icons.star_rounded, color: Colors.white, size: 28)
                        : unlocked
                          ? Text('${index + 1}',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: iconColor))
                          : Icon(Icons.lock_rounded, color: iconColor, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(stage.title,
            style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: unlocked
                ? (isDark ? Colors.white70 : Colors.black54)
                : Colors.grey.withOpacity(0.5),
            )),
        ],
      ),
    );

    return node;
  }

  void _launchStage(BuildContext context) {
    final game = Get.find<GameController>();
    // Show mode picker bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModePicker(stage: stage, game: game,
          isDark: Get.find<ThemeController>().isDarkMode),
    );
  }
}

class _ModePicker extends StatelessWidget {
  final LevelStage stage;
  final GameController game;
  final bool isDark;

  const _ModePicker({required this.stage, required this.game, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg     = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder   : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4,
            decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(stage.title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 4),
          Text('${stage.questionsRequired} questions to complete',
            style: TextStyle(fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45)),
          const SizedBox(height: 24),
          ChunkyButton(
            label: 'Solo Practice',
            color: AppColors.duoGreen, shadowColor: AppColors.duoGreenDark,
            textColor: Colors.white,
            icon: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            onTap: () {
              Get.back();
              game.setMode(GameMode.singlePlayer);
              game.startStage(stage);
              Get.toNamed('/game');
            },
          ),
          const SizedBox(height: 12),
          ChunkyButton(
            label: 'VS Machine',
            color: AppColors.skyBlue, shadowColor: AppColors.skyBlueDark,
            textColor: Colors.white,
            icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            onTap: () {
              Get.back();
              game.setMode(GameMode.vsMachine);
              game.startStage(stage);
              Get.toNamed('/game');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
