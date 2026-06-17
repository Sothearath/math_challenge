// lib/features/dashboard/views/brainy_dashboard_view.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/constants.dart';
import '../models/level_config.dart';
import '../theme/app_theme.dart';
import '../widgets/brainy_painter.dart';
import 'daily_challenge/daily_challenge_controller.dart';
import 'daily_challenge/daily_challenge_history_view.dart';

class BrainyDashboardView extends StatefulWidget {
  const BrainyDashboardView({super.key});

  @override
  State<BrainyDashboardView> createState() => _BrainyDashboardViewState();
}

class _BrainyDashboardViewState extends State<BrainyDashboardView>
    with TickerProviderStateMixin {

  late final DashboardController _ctrl;
  late final DailyChallengeController _dailyCtrl;
  late final AnimationController _bobCtrl;
  late final Animation<double>   _bobAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;
  late final Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DashboardController>();
    _dailyCtrl = Get.find<DailyChallengeController>();

    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _bobAnim = _bobCtrl.drive(_SineDoubleTween(amplitude: 6.0));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 1.0, end: 1.04));
    _glowAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut)
        .drive(Tween(begin: 0.25, end: 0.55));
  }

  @override
  void dispose() {
    _bobCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  // Mirrors ArithmeticChallengeView: gradient Container wraps the full body,
  // SafeArea sits inside it so the gradient bleeds under the status bar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extend gradient behind the system UI bars
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        // Fill the full screen — width+height+constraints together ensure
        // the gradient covers the viewport even when scroll content is short.
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: double.infinity),
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          // SafeArea sits inside the gradient so padding areas stay coloured
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // Let the scroll view expand to fill remaining space
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      _buildStatsBar(),
                      const SizedBox(height: 14),
                      _buildGreetingBubble(),
                      const SizedBox(height: 16),
                      _buildMascot(),
                      const SizedBox(height: 24),
                      // _buildProgressCard(),
                      const SizedBox(height: 20),
                      //
                      // _buildDailyChallengeCard(context),
                      // const SizedBox(height: 20),
                      // _buildBeginButton(),
                      // const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'FlexiArithmetic',
                          // maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.cobalt,
                            height: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),



              // 📌 2. Bottom Fixed Section: Always firmly anchored to the bottom of the screen
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 88, top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Takes up only the space it needs
                  children: [
                    _buildDailyChallengeCard(context),
                    const SizedBox(height: 16), // Clean padding between the two cards
                    _buildBeginButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────────────────────
  // Same frosted-glass pill style as ArithmeticChallengeView._pill().
  // lib/features/dashboard/views/brainy_dashboard_view.dart
// ── Stats bar ─────────────────────────────────────────────────────────────────
  // Same frosted-glass pill style as ArithmeticChallengeView._pill().
  Widget _buildStatsBar() {
    return Obx(() => Row(
      children: [
        Expanded(child: _statPill(
          icon: Icons.timer_outlined,
          value: '${_ctrl.weekStreak.value * 2}',
          unit: 'min',
          label: 'Training time',
        )),
        const SizedBox(width: 8),
        Expanded(child: _statPill(
          icon: Icons.bar_chart_rounded,
          value: '${_ctrl.complexityPercent.value}',
          unit: '%',
          label: 'Complexity',
        )),
        const SizedBox(width: 8),
        Expanded(child: _statPill(
          icon: Icons.track_changes_rounded,
          value: '${_ctrl.avgAccuracy.value}',
          unit: '%',
          label: 'Focus score',
        )),
        const SizedBox(width: 8),
        _settingsButton(),
      ],
    ));
  }

  void _showMonthlyChallengeHistory(BuildContext context) {
    // 1. Grab values from your daily challenge tracking logic
    final currentStreak = _ctrl.weekStreak.value;

    // For a simple tracking approach without heavy database models,
    // you can estimate completed days using the historical streak count
    // or link it to your completed state lists later.
    final totalCompletedThisMonth = currentStreak;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull indicator tab
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    'Challenge History',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cobalt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Summary metric count description
              Text(
                "You have successfully completed $totalCompletedThisMonth Daily Challenges so far this month. Incredible dedication!",
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: AppColors.mintDim,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Dynamic Mini Calendar Tracker Row
              Text(
                "This Week's Record",
                style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mintFaint),
              ),
              const SizedBox(height: 10),

              // Renders a visual log row mapping their daily achievements
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final List<String> weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  // Dummy mapping logic: check if day falls into active completed streak tier
                  final bool didPlay = index < currentStreak;

                  return Column(
                    children: [
                      Text(
                        weekdays[index],
                        style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.dotDayLabel),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: didPlay ? AppColors.streakBg : AppColors.lightBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: didPlay ? AppColors.streakGreen : AppColors.dotMissBorder,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            didPlay ? '✅' : '🔒',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Dismiss primary CTA button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cobalt,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    'Awesome!',
                    style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }


  // Frosted-glass pill — white @ 28% fill + white @ 55% border,
  // exactly matching the challenge view's _pill() container style.
  Widget _statPill({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.28),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(color: Colors.white.withOpacity(0.55)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.cobalt, size: 14),
            const SizedBox(height: 4),
            // Wrap in Row so the unit shrinks before value clips
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cobalt,
                      height: 1,
                    ),
                  ),
                ),
                Text(
                  ' $unit',
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: AppColors.cobalt.withOpacity(0.60),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                  fontSize: 9,
                  color: AppColors.mutedOnGrad),
            ),
          ],
        ),
      );

  // Settings — frosted-glass icon button matching _iconButton() in challenge view.
  Widget _settingsButton() => GestureDetector(
    onTap: () {Get.toNamed(Routes.profile);},
    child: Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.30),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: Colors.white.withOpacity(0.50)),
      ),
      child: Icon(Icons.settings_rounded,
          color: AppColors.cobalt, size: 20),
    ),
  );

  // ── Greeting bubble ───────────────────────────────────────────────────────────
  // White card surface matching the equation card in challenge view.
  Widget _buildGreetingBubble() {
    return Obx(() {
      final hasStreak   = _ctrl.hasStreak;
      final accentColor = hasStreak ? AppColors.sunflower : AppColors.cobalt;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.keyWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: AppTheme.cardShadows,
          border: Border.all(
            color: hasStreak
                ? AppColors.sunflower.withOpacity(0.40)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: _buildGreetingText(_ctrl.greetingText, accentColor),
      );
    });
  }

  Widget _buildGreetingText(String text, Color accentColor) {
    const highlight = 'Brainy';
    final idx = text.indexOf(highlight);
    if (idx == -1) {
      return Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
              fontSize: 15,
              color: AppColors.cobalt.withOpacity(0.70),
              height: 1.4));
    }
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.nunito(
            fontSize: 15,
            color: AppColors.cobalt.withOpacity(0.70),
            height: 1.4),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: highlight,
            style: GoogleFonts.nunito(
                fontSize: 15,
                color: accentColor,
                fontWeight: FontWeight.w800),
          ),
          TextSpan(text: text.substring(idx + highlight.length)),
        ],
      ),
    );
  }

  // ── Mascot — bob + subtle white glow halo on gradient ─────────────────────────
  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _bobAnim,
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _bobAnim.value), child: child),
      child: Column(
        children: [
          Container(
            width: 180,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.18),
                  blurRadius: 48,
                  spreadRadius: 16,
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 160,
                height: 170,
                child: CustomPaint(painter: BrainyPainter()),
              ),
            ),
          ),
          // Ground shadow — soft oval beneath feet anchors Brainy to the card
          Container(
            width: 72,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: const BorderRadius.all(Radius.elliptical(72, 10)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'BRAINY',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
              color: AppColors.mutedOnGrad,
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress card — white surface matching equation card style ─────────────────
  // ── 1. The Interactive Progress Card Frame ───────────────────────────────
  Widget _buildProgressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cobaltLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppColors.cobaltDark, width: 1.5), // ✅ Using cobaltDark
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            onTap: () => _showLevelDetailsBottomSheet(context), // 🚀 Triggers the detail layout popup sheet
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildLevelBadge(), // ⭐ Extracted component method
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProgressBarTrack(), // ⭐ Extracted component method
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 2. Extracted Level Badge Component ──────────────────────────────────
  Widget _buildLevelBadge() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.cobaltDark,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💎', style: TextStyle(fontSize: 12)),
            Obx(() => Text(
              'Lvl ${_ctrl.currentLevel}',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── 3. Extracted Progress Bar Track Component ───────────────────────────
  Widget _buildProgressBarTrack() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Brain Progression',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Obx(() => Text(
              '${_ctrl.complexityPercent.value}%',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.sunflower,
              ),
            )),
          ],
        ),
        const SizedBox(height: 8),

        // ⭐ Fixed Obx reactive scope block
        Obx(() {
          // By moving the math inside the Obx function body, GetX successfully
          // registers and listens to the '_ctrl.currentLevel.value' stream!
          final double progressFraction = kLevels.isEmpty
              ? 0.0
              : (_ctrl.currentLevel.value / kLevels.length).clamp(0.0, 1.0);

          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 10,
              width: double.infinity,
              child: LinearProgressIndicator(
                value: progressFraction,
                backgroundColor: AppColors.cobaltDark,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showLevelDetailsBottomSheet(BuildContext context) {
    final currentLvl = _ctrl.currentLevel.value;
    final maxLevels  = kLevels.length;
    final complexity = _ctrl.complexityPercent.value;
    final personalBest = _ctrl.topScore.value;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar Indicator
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Headline Title Block
              Row(
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    'Level $currentLvl Progress',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cobalt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Explanatory breakdown text string using existing level configurations
              Text(
                'You are currently training on Stage $currentLvl out of $maxLevels total math milestones. Keep completing challenges to unlock advanced equations!',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppColors.mintDim,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Stats Block Details (Using your real controller stats!)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cobaltLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusKey),
                  border: Border.all(color: AppColors.cobaltDark.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPopupMiniStat('🧩 Complexity', '$complexity%'),
                    Container(width: 1, height: 40, color: AppColors.darkDivider),
                    _buildPopupMiniStat('🏆 High Score', '$personalBest pts'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cobalt,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                  onPressed: () => Get.back(),
                  child: Text(
                    'Keep Training!',
                    style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Widget _buildPopupMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 13, color: AppColors.mintDim, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(fontSize: 18, color: AppColors.cobalt, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  // Streak badge — mirrors the pill style from the top bar.
  Widget _streakBadge(int streak) {
    if (streak == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.cobalt.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
          border: Border.all(color: AppColors.cobalt.withOpacity(0.30)),
        ),
        child: Text('No streak yet',
            style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppColors.cobalt,
                fontWeight: FontWeight.w700)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.sunflower.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
        border: Border.all(color: AppColors.sunflower.withOpacity(0.50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text('$streak day streak',
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppColors.sunflower,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildWeekRow(int streak) {
    const days     = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const labels   = ['Mon', 'Tue', 'Today', 'Thu', 'Fri', 'Sat', 'Sun'];
    const todayIdx = 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isToday     = i == todayIdx;
        final isCompleted = i < todayIdx && i < streak;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Today → cobalt fill; completed → cobalt tint; future → light grey
                color: isToday
                    ? AppColors.cobalt
                    : isCompleted
                    ? AppColors.cobalt.withOpacity(0.12)
                    : AppColors.cobalt.withOpacity(0.05),
                border: Border.all(
                  color: isToday
                      ? AppColors.cobaltDark
                      : isCompleted
                      ? AppColors.cobalt.withOpacity(0.40)
                      : AppColors.cobalt.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  days[i],
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? Colors.white
                        : isCompleted
                        ? AppColors.cobalt
                        : AppColors.cobalt.withOpacity(0.35),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(labels[i],
                style: GoogleFonts.nunito(
                    fontSize: 9,
                    color: isToday
                        ? AppColors.cobalt
                        : AppColors.cobalt.withOpacity(0.35))),
          ],
        );
      }),
    );
  }

  Widget _miniStat(String title, String value, String sub) => Expanded(
    child: Column(
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
              fontSize: 10,
              color: AppColors.cobalt.withOpacity(0.45)),
        ),
        const SizedBox(height: 6),
        // Bumped 18 → 22px, stays w900 (Nunito max weight)
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.cobalt,
              letterSpacing: -0.5),
        ),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.nunito(
              fontSize: 10,
              color: AppColors.cobalt.withOpacity(0.40)),
        ),
      ],
    ),
  );

  Widget _starStat(int topScore) => Expanded(
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          // Matches sunflower press-pulse from numpad keys
          color: AppColors.sunflower.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.sunflower.withOpacity(0.40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded,
                color: AppColors.sunflower, size: 20),
            const SizedBox(height: 2),
            Text(
              '$topScore',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.sunflower,
                  letterSpacing: -0.5),
            ),
            Text('top score',
                style: GoogleFonts.nunito(
                    fontSize: 9,
                    color: AppColors.sunflower.withOpacity(0.70))),
          ],
        ),
      ),
    ),
  );

  // ── Daily Challenge card ─────────────────────────────────────────────────────
  // Premium gold/orange CTA above the Begin Challenge button.
  // Active  → orange/gold gradient, tappable, navigates with daily config.
  // Locked  → dimmed grey, checkmark icon, onTap: null.
  Widget _buildDailyChallengeCard(BuildContext context) {
    return Obx(() {
      if (_dailyCtrl.isLoading.value) {
        return const SizedBox(height: 0);
      }

      final played = _dailyCtrl.hasPlayedToday.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: played
              ? null
              : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
          ),
          color: played ? Colors.white.withOpacity(0.35) : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: played ? Border.all(color: Colors.white.withOpacity(0.50)) : null,
          boxShadow: played
              ? null
              : [
            BoxShadow(
              color: const Color(0xFFFF9800).withOpacity(0.40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Leading state indicator
            if (played)
              const Icon(Icons.check_circle_rounded, color: AppColors.cobalt, size: 32)
            else
              const Text('📆', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 14),

            // Main Text Block and Play Trigger Action
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!played) {
                    Get.toNamed(
                      Routes.game,
                      arguments: _dailyCtrl.challengeConfig,
                    )?.then((_) => _ctrl.refreshStats());
                  } else {
                    _handleLockedCardTap(context);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenge',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: played ? AppColors.cobalt : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      played ? 'Come back tomorrow! 🎉' : 'Earn +100 Bonus XP Points!',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: played ? AppColors.cobalt.withOpacity(0.55) : Colors.white.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ⭐ Clean, Explicit History Action Button
            IconButton(
              icon: Icon(
                Icons.calendar_month_rounded,
                color: played ? AppColors.cobalt : Colors.white,
                size: 24,
              ),
              tooltip: 'View History',
              onPressed: () {
                Get.to(
                      () => DailyChallengeHistoryView(
                    currentStreak: _ctrl.weekStreak.value,
                    hasPlayedToday: _dailyCtrl.hasPlayedToday.value, // ⭐ Pass the dynamic value here!
                    onPlayPressed: () {
                      Get.back();
                      if (!_dailyCtrl.hasPlayedToday.value) {
                        Get.toNamed(Routes.game, arguments: _dailyCtrl.challengeConfig)
                            ?.then((_) => _ctrl.refreshStats());
                      }
                    },
                  ),
                  transition: Transition.rightToLeft,
                );
              },
            ),
          ],
        ),
      );
    });
  }

  // ── Begin Challenge — cobalt gradient button matching _SubmitKey style ─────────
  Widget _buildBeginButton() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, child) => Transform.scale(
        scale: _pulseAnim.value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            boxShadow: [
              BoxShadow(
                color: AppColors.cobalt.withOpacity(_glowAnim.value),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            // Same gradient as _SubmitKey in ArithmeticChallengeView
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.cobalt, AppColors.cobaltLight],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            boxShadow: [
              BoxShadow(
                color: AppColors.cobalt.withOpacity(0.45),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              onTap: () {
                // Navigate to the game screen, then refresh metrics when they return!
                Get.toNamed(Routes.game)?.then((_) {
                  _ctrl.refreshStats();        // Updates stats like weekly streak & scores
                  _ctrl.refreshLevelMetrics();   // Updates Level and Complexity percent visually
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(
                    'Begin challenge',
                    style: GoogleFonts.nunito(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLockedCardTap(BuildContext context) {
    // Assuming your storage or controller tracks whether today was a clean win
    // For now, if they are locked out, let's see if they want a revive:
    final bool outOfHearts = !_dailyCtrl.wasChallengePerfectWin.value;

    if (outOfHearts) {
      _showSecondChanceDialog(context);
    } else {
      // Clean Win feedback
      Get.snackbar(
        'Completed! 🎉',
        'You nailed today\'s challenge! Come back at midnight for a brand new board.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.cobalt.withOpacity(0.9),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _showSecondChanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
        title: Text(
          '💔 Out of Hearts!',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: AppColors.cobalt),
        ),
        content: Text(
          'Don\'t break your training streak! Watch a quick video to get 1 extra heart and try today\'s challenge again.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(color: AppColors.cobalt.withOpacity(0.7)),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
             onPressed: () { Get.back() ;},
            child: Text('Maybe later', style: GoogleFonts.nunito(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sunflower,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
            ),

            icon: const Icon(Icons.play_circle_filled_rounded, color: AppColors.cobalt),
            label: Text(
              'Watch Ad',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w900, color: AppColors.cobalt),
            ), onPressed: () {
            Get.back();
            // ⭐ Trigger Ad Engine / Reward validation here
            _dailyCtrl.grantSecondChanceChance();

            // Reroute back into the game loop using the exact same configuration seed
            Get.toNamed(
              Routes.game,
              arguments: _dailyCtrl.challengeConfig,
            )?.then((_) => _ctrl.refreshStats());
          },
          ),
        ],
      ),
    );
  }
}

// ── Custom sine tween ─────────────────────────────────────────────────────────
class _SineDoubleTween extends Animatable<double> {
  final double amplitude;
  const _SineDoubleTween({required this.amplitude});

  @override
  double transform(double t) => math.sin(t * 2 * math.pi) * amplitude;
}