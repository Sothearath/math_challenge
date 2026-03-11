// lib/views/home_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/game_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();
    final themeCtrl = Get.find<ThemeController>();

    // Entire screen re-renders whenever themeMode changes
    return Obx(() {
      final isDark = themeCtrl.isDarkMode;
      final primary = isDark ? AppColors.neonGreen : AppColors.accentBlue;

      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar ────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MATH',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: primary,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                        Text(
                          'CHALLENGE',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    // Dark mode toggle
                    GestureDetector(
                      onTap: themeCtrl.toggleTheme,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 56,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              left: isDark ? 2 : 28,
                              top: 3,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primary,
                                ),
                                child: Icon(
                                  isDark
                                      ? Icons.nightlight_round
                                      : Icons.wb_sunny_rounded,
                                  size: 14,
                                  color: isDark
                                      ? AppColors.darkBg
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Correct & Fastest Wins',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 48),

                Text(
                  'SELECT MODE',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),

                _ModeCard(
                  title: 'Single Player',
                  subtitle: '60 second countdown · Speed multiplier',
                  icon: Icons.person_rounded,
                  accentColor: isDark
                      ? AppColors.neonGreen
                      : AppColors.accentGreen,
                  isSelected: game.gameMode.value == GameMode.singlePlayer,
                  onTap: () => game.setMode(GameMode.singlePlayer),
                  isDark: isDark,
                ),

                const SizedBox(height: 12),

                _ModeCard(
                  title: 'VS Machine',
                  subtitle: 'Race against AI · Solve faster or lose',
                  icon: Icons.smart_toy_rounded,
                  accentColor: isDark
                      ? AppColors.neonBlue
                      : AppColors.accentBlue,
                  isSelected: game.gameMode.value == GameMode.vsMachine,
                  onTap: () => game.setMode(GameMode.vsMachine),
                  isDark: isDark,
                ),

                const Spacer(),

                _StatsStrip(isDark: isDark, primary: primary),
                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () {
                    game.startGame();
                    Get.toNamed('/game');
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
                        'START GAME',
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
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _ModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withOpacity(0.12)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final bool isDark;
  final Color primary;

  const _StatsStrip({super.key, required this.isDark, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            label: 'Operations',
            value: '4',
            isDark: isDark,
            color: primary,
          ),
          Container(
            width: 1,
            height: 30,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          _Stat(
            label: 'Duration',
            value: '60s',
            isDark: isDark,
            color: primary,
          ),
          Container(
            width: 1,
            height: 30,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          _Stat(label: 'Scaling', value: 'ON', isDark: isDark, color: primary),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color color;

  const _Stat({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
