// lib/views/awards_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/awards_controller.dart';

class AwardsView extends StatelessWidget {
  const AwardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl   = Get.find<AwardsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor      = isDark ? const Color(0xFF12131A) : const Color(0xFFF5F7FF);
    final cardColor    = isDark ? const Color(0xFF1E2030) : Colors.white;
    final textPrimary  = isDark ? Colors.white : const Color(0xFF1A1D2E);
    final textSecondary = isDark ? Colors.white54 : Colors.black45;
    final accentBlue   = const Color(0xFF4A90E2);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: bgColor,
              elevation: 0,
              floating: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: textPrimary),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'Awards',
                style: TextStyle(
                  color:      textPrimary,
                  fontSize:   22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: false,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Monthly Progress Card ────────────────────────────────
                    Obx(() {
                      final count    = ctrl.dailyCompletedThisMonth.value;
                      final goal     = ctrl.dailyGoal;
                      final progress = ctrl.monthlyProgress;

                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accentBlue, const Color(0xFF7B61FF)],
                            begin:  Alignment.topLeft,
                            end:    Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color:      accentBlue.withOpacity(0.35),
                              blurRadius: 16,
                              offset:     const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'This Month',
                                  style: TextStyle(
                                    color:      Colors.white70,
                                    fontSize:   13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:        Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$count of $goal',
                                    style: const TextStyle(
                                      color:      Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize:   13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$count of $goal Daily Challenges',
                              style: const TextStyle(
                                color:      Colors.white,
                                fontSize:   20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value:            progress,
                                minHeight:        8,
                                backgroundColor:  Colors.white.withOpacity(0.25),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            ),
                            if (ctrl.monthlyGoalAchieved) ...[
                              const SizedBox(height: 10),
                              const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Trophy Earned! 🏆',
                                    style: TextStyle(
                                      color:      Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize:   13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 28),

                    // ── Section header ───────────────────────────────────────
                    Text(
                      'Monthly Trophies',
                      style: TextStyle(
                        color:      textPrimary,
                        fontSize:   18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete all daily challenges in a month to earn a trophy.',
                      style: TextStyle(
                        color:    textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── Trophy Grid ──────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: Obx(() {
                final trophies = ctrl.trophies;
                return SliverGrid.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:   3,
                    mainAxisSpacing:  14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: trophies.length,
                  itemBuilder: (context, index) {
                    final trophy = trophies[index];
                    return _TrophyCard(
                      trophy:    trophy,
                      cardColor: cardColor,
                      isDark:    isDark,
                      isCurrentMonth: _isCurrentMonth(
                          trophy.year, trophy.monthIndex),
                      progress: _isCurrentMonth(trophy.year, trophy.monthIndex)
                          ? ctrl.monthlyProgress
                          : (trophy.isEarned ? 1.0 : 0.0),
                    );
                  },
                );
              }),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  bool _isCurrentMonth(int year, int month) {
    final now = DateTime.now();
    return now.year == year && now.month == month;
  }
}

// ─── Trophy Card ──────────────────────────────────────────────────────────────

class _TrophyCard extends StatelessWidget {
  final MonthlyTrophy trophy;
  final Color         cardColor;
  final bool          isDark;
  final bool          isCurrentMonth;
  final double        progress; // 0.0 – 1.0

  const _TrophyCard({
    required this.trophy,
    required this.cardColor,
    required this.isDark,
    required this.isCurrentMonth,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isEarned    = trophy.isEarned;
    final goldColor   = const Color(0xFFFFD700);
    final silverColor = Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentMonth
            ? Border.all(
                color: const Color(0xFF4A90E2).withOpacity(0.6), width: 1.5)
            : Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.06),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color:      isEarned
                ? goldColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy icon with gold or grayscale filter
            ColorFiltered(
              colorFilter: isEarned
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
                  : const ColorFilter.matrix([
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0.2126, 0.7152, 0.0722, 0, 0,
                      0,      0,      0,      1, 0,
                    ]),
              child: Text(
                '🏆',
                style: TextStyle(
                  fontSize: 40,
                  shadows: isEarned
                      ? [
                          Shadow(
                            color:      goldColor.withOpacity(0.6),
                            blurRadius: 12,
                          )
                        ]
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trophy.month,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:   11,
                fontWeight: FontWeight.w700,
                color:      isEarned
                    ? goldColor
                    : isDark
                        ? Colors.white54
                        : Colors.black45,
              ),
            ),
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value:           progress,
                minHeight:       5,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isEarned ? goldColor : const Color(0xFF4A90E2),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (isEarned)
              Text(
                'Earned!',
                style: TextStyle(
                  fontSize:   10,
                  color:      goldColor,
                  fontWeight: FontWeight.w700,
                ),
              )
            else if (isCurrentMonth)
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize:   10,
                  color:      const Color(0xFF4A90E2),
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
