// lib/views/daily_challenge_view.dart
//
// Covers:
//  • Dashboard with "Daily Challenge" card + "Greenhouse Event" card + countdown timers
//  • NumberSums 5×5 grid with Pen/Pencil toggle & validation
//  • Persistent bottom navigation bar (Main / Daily Challenges)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/daily_challenge_controller.dart';
import '../views/awards_view.dart';

// ═════════════════════════════════════════════════════════════════════════════
// ROOT: Persistent scaffold with Bottom Nav
// ═════════════════════════════════════════════════════════════════════════════

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt tabIndex = 0.obs;

    final pages = [
      const HomeTabView(),
      const DailyChallengeTabView(),
    ];

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: tabIndex.value,
            children: pages,
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: tabIndex.value,
            onTap:        (i) => tabIndex.value = i,
          ),
        ));
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int          currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bg       = isDark ? const Color(0xFF1E2030) : Colors.white;
    final accent   = const Color(0xFF4A90E2);
    final unselect = isDark ? Colors.white38 : Colors.black38;

    return Container(
      height:     72,
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset:     const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          _NavItem(
            icon:     Icons.home_rounded,
            label:    'Main',
            selected: currentIndex == 0,
            accent:   accent,
            unselect: unselect,
            onTap:    () => onTap(0),
          ),
          _NavItem(
            icon:     Icons.calendar_today_rounded,
            label:    'Daily',
            selected: currentIndex == 1,
            accent:   accent,
            unselect: unselect,
            onTap:    () => onTap(1),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     selected;
  final Color    accent;
  final Color    unselect;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.unselect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected ? accent.withOpacity(0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: selected ? accent : unselect, size: 24),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize:   11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color:      selected ? accent : unselect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 1: Home stub – plug your existing HomeView here
// ═════════════════════════════════════════════════════════════════════════════

class HomeTabView extends StatelessWidget {
  const HomeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace with your existing home/level-map view
    return const Scaffold(
      body: Center(child: Text('Your existing Home / Level Map View')),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// TAB 2: Daily Challenge Dashboard + Number Grid
// ═════════════════════════════════════════════════════════════════════════════

class DailyChallengeTabView extends StatelessWidget {
  const DailyChallengeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl   = Get.find<DailyChallengeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor   = isDark ? const Color(0xFF12131A) : const Color(0xFFF5F7FF);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D2E);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today\'s Challenges',
                            style: TextStyle(
                              color:      textColor,
                              fontSize:   24,
                              fontWeight: FontWeight.w900,
                            )),
                        const SizedBox(height: 2),
                        Text(
                          _formattedDate(),
                          style: TextStyle(
                            color:   isDark ? Colors.white38 : Colors.black38,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    // Awards shortcut
                    GestureDetector(
                      onTap: () => Get.to(() => const AwardsView()),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:      Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text('🏆',
                            style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 20)),

            // ── Daily Challenge Card ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => _ChallengeCard(
                      title:     'Daily Challenge',
                      subtitle:  'Resets in',
                      countdown: ctrl.dailyCountdown.value,
                      icon:      '⚡',
                      gradient: [
                        const Color(0xFF4A90E2),
                        const Color(0xFF7B61FF),
                      ],
                      onTap: () => _scrollToGrid(context),
                    )),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 14)),

            // ── Greenhouse Event Card ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => ctrl.eventActive.value
                    ? _ChallengeCard(
                        title:     'Greenhouse Event 🌿',
                        subtitle:  'Event ends in',
                        countdown: ctrl.eventCountdown.value,
                        icon:      '🌱',
                        gradient: [
                          const Color(0xFF2ECC71),
                          const Color(0xFF1ABC9C),
                        ],
                        onTap: () {},
                      )
                    : const SizedBox.shrink()),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 28)),

            // ── NumberSums grid section header ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Number Challenge',
                      style: TextStyle(
                        color:      textColor,
                        fontSize:   18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    // Regenerate
                    TextButton.icon(
                      icon:  const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('New'),
                      onPressed: ctrl.regenerateGrid,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 8)),

            // ── NumberSums Grid ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _NumberSumsWidget(ctrl: ctrl, isDark: isDark),
              ),
            ),

            SliverToBoxAdapter(child: const SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    const days = [
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _scrollToGrid(BuildContext context) {
    // In a full app you'd scroll; here we just trigger a snackbar
    Get.snackbar('Daily Challenge', 'Solve the grid below! 👇',
        duration: const Duration(seconds: 2));
  }
}

// ─── Challenge Card ───────────────────────────────────────────────────────────

class _ChallengeCard extends StatelessWidget {
  final String       title;
  final String       subtitle;
  final String       countdown;
  final String       icon;
  final List<Color>  gradient;
  final VoidCallback onTap;

  const _ChallengeCard({
    required this.title,
    required this.subtitle,
    required this.countdown,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:      gradient.first.withOpacity(0.35),
              blurRadius: 16,
              offset:     const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // icon bubble
            Container(
              width:  56, height: 56,
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   16,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(
                    countdown,
                    style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white54, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── NumberSums Widget ────────────────────────────────────────────────────────

class _NumberSumsWidget extends StatelessWidget {
  final DailyChallengeController ctrl;
  final bool                      isDark;

  const _NumberSumsWidget({required this.ctrl, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cardBg    = isDark ? const Color(0xFF1E2030) : Colors.white;
    final accentBlue = const Color(0xFF4A90E2);

    return Container(
      decoration: BoxDecoration(
        color:        cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // ── Header: target & pen/pencil toggle ──────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target Sum',
                          style: TextStyle(
                            color:    isDark ? Colors.white38 : Colors.black38,
                            fontSize: 12,
                          )),
                      Text(
                        '${ctrl.targetSum.value}',
                        style: TextStyle(
                          color:      isDark ? Colors.white : Colors.black87,
                          fontSize:   36,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  )),
              Obx(() => _PenPencilToggle(
                    isPencil: ctrl.isPencilMode.value,
                    onToggle: ctrl.togglePencilMode,
                    isDark:   isDark,
                  )),
            ],
          ),

          const SizedBox(height: 16),

          // ── Running Sum ──────────────────────────────────────────────────
          Obx(() {
            final sel    = ctrl.selectedSum.value;
            final target = ctrl.targetSum.value;
            final color  = sel == target
                ? const Color(0xFF2ECC71)
                : sel > target
                    ? const Color(0xFFEF4444)
                    : accentBlue;

            return Container(
              width:   double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color:        color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                'Selected Sum: $sel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:      color,
                  fontWeight: FontWeight.w700,
                  fontSize:   15,
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // ── 5×5 Grid ────────────────────────────────────────────────────
          Obx(() {
            if (ctrl.gridSolved.value) {
              return _SolvedOverlay(isDark: isDark);
            }
            return GridView.builder(
              shrinkWrap: true,
              physics:    const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:  5,
                mainAxisSpacing:  8,
                crossAxisSpacing: 8,
              ),
              itemCount:   ctrl.gridCells.length,
              itemBuilder: (_, i) => _GridCell(
                cell:    ctrl.gridCells[i],
                onTap:   () => ctrl.onCellTap(i),
                isDark:  isDark,
              ),
            );
          }),

          const SizedBox(height: 16),

          // ── Validate button ──────────────────────────────────────────────
          Obx(() => ctrl.gridSolved.value
              ? const SizedBox.shrink()
              : SizedBox(
                  width:  double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: ctrl.validateSelection,
                    child: const Text(
                      'Check Answer',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}

// ─── Grid Cell ────────────────────────────────────────────────────────────────

class _GridCell extends StatelessWidget {
  final GridCell cell;
  final VoidCallback onTap;
  final bool         isDark;

  const _GridCell({
    required this.cell,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Border? border;

    if (cell.isCorrect) {
      bg        = const Color(0xFF2ECC71);
      textColor = Colors.white;
    } else if (cell.isWrong) {
      bg        = const Color(0xFFEF4444);
      textColor = Colors.white;
    } else if (cell.isSelected) {
      bg        = const Color(0xFF4A90E2);
      textColor = Colors.white;
    } else if (cell.isPencilMarked) {
      bg        = isDark
          ? Colors.white.withOpacity(0.08)
          : const Color(0xFFF0F4FF);
      textColor = const Color(0xFF4A90E2);
      border    = Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.4), width: 1.5);
    } else {
      bg        = isDark
          ? Colors.white.withOpacity(0.06)
          : const Color(0xFFF8F9FC);
      textColor = isDark ? Colors.white70 : Colors.black87;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve:    Curves.easeOut,
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(10),
          border:       border,
          boxShadow: cell.isSelected
              ? [
                  BoxShadow(
                    color:      const Color(0xFF4A90E2).withOpacity(0.3),
                    blurRadius: 8,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            '${cell.value}',
            style: TextStyle(
              color:      textColor,
              fontSize:   18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pen/Pencil Toggle ────────────────────────────────────────────────────────

class _PenPencilToggle extends StatelessWidget {
  final bool         isPencil;
  final VoidCallback onToggle;
  final bool         isDark;

  const _PenPencilToggle({
    required this.isPencil,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final active   = const Color(0xFF4A90E2);
    final inactive = isDark ? Colors.white24 : Colors.black26;
    final bg       = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.05);

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding:    const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleChip(
              icon:     Icons.edit_rounded,
              label:    'Pen',
              selected: !isPencil,
              color:    !isPencil ? active : inactive,
              isDark:   isDark,
            ),
            const SizedBox(width: 4),
            _ToggleChip(
              icon:     Icons.create_rounded,
              label:    'Notes',
              selected: isPencil,
              color:    isPencil ? active : inactive,
              isDark:   isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     selected;
  final Color    color;
  final bool     isDark;

  const _ToggleChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? (isDark
                ? const Color(0xFF4A90E2).withOpacity(0.2)
                : const Color(0xFF4A90E2).withOpacity(0.12))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                color:      color,
                fontSize:   12,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

// ─── Solved Overlay ───────────────────────────────────────────────────────────

class _SolvedOverlay extends StatelessWidget {
  final bool isDark;
  const _SolvedOverlay({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color:        const Color(0xFF2ECC71).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF2ECC71).withOpacity(0.3)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉', style: TextStyle(fontSize: 56)),
          SizedBox(height: 12),
          Text(
            'Challenge Solved!',
            style: TextStyle(
              color:      Color(0xFF2ECC71),
              fontSize:   20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Come back tomorrow for a new challenge.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
