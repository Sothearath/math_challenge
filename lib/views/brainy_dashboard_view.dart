// lib/features/dashboard/views/brainy_dashboard_view.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/constants.dart';
import '../theme/app_theme.dart';
import '../widgets/brainy_painter.dart';

class BrainyDashboardView extends StatefulWidget {
  const BrainyDashboardView({super.key});

  @override
  State<BrainyDashboardView> createState() => _BrainyDashboardViewState();
}

class _BrainyDashboardViewState extends State<BrainyDashboardView>
    with TickerProviderStateMixin {

  late final DashboardController _ctrl;
  late final AnimationController _bobCtrl;
  late final Animation<double>   _bobAnim;
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim;
  late final Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DashboardController>();

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
          child: SingleChildScrollView(
            // Let the scroll view expand to fill remaining space
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildStatsBar(),
                const SizedBox(height: 14),
                _buildGreetingBubble(),
                const SizedBox(height: 4),
                _buildMascot(),
                const SizedBox(height: 16),
                _buildProgressCard(),
                const SizedBox(height: 20),
                _buildBeginButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          value: '25',
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
            height: 180,
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
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.keyWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.cardShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Math progress',
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cobalt)),
              Obx(() => _streakBadge(_ctrl.weekStreak.value)),
            ],
          ),
          const SizedBox(height: 16),

          // ── Week dots ──
          Obx(() => _buildWeekRow(_ctrl.weekStreak.value)),

          // ── Divider matching challenge view's progress bar track style ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                color: AppColors.cobalt.withOpacity(0.10),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // ── Stats row ──
          Obx(() => Row(
            children: [
              _miniStat('Avg accuracy',
                  '${_ctrl.avgAccuracy.value}', 'equations'),
              _starStat(_ctrl.topScore.value),
              _miniStat('Latest session',
                  '${_ctrl.latestSession.value}', 'correct'),
            ],
          )),
        ],
      ),
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
              onTap: () => Get.toNamed(Routes.game),
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
}

// ── Custom sine tween ─────────────────────────────────────────────────────────
class _SineDoubleTween extends Animatable<double> {
  final double amplitude;
  const _SineDoubleTween({required this.amplitude});

  @override
  double transform(double t) => math.sin(t * 2 * math.pi) * amplitude;
}