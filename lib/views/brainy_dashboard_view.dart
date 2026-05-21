// lib/features/dashboard/views/brainy_dashboard_view.dart
//
// Upgraded Dashboard View
// New additions:
//   • Idle bob animation on the Brainy mascot (sine-wave via AnimationController)
//   • Dynamic greeting colour (teal vs amber based on streak)
//   • "Begin Challenge" button soft pulse/glow loop
// Everything else retains your existing layout exactly.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/dashboard_controller.dart';
import '../../../core/constants.dart';
import '../widgets/brainy_painter.dart';

class BrainyDashboardView extends StatefulWidget {
  const BrainyDashboardView({super.key});

  @override
  State<BrainyDashboardView> createState() => _BrainyDashboardViewState();
}

class _BrainyDashboardViewState extends State<BrainyDashboardView>
    with TickerProviderStateMixin {

  late final DashboardController _ctrl;

  // ── Mascot idle bob ──────────────────────────────────────────────────────────
  /// Full sine-wave loop: 0 → π → 2π → repeat
  late final AnimationController _bobCtrl;
  late final Animation<double>   _bobAnim; // -6px to +6px vertical offset

  // ── Button pulse ─────────────────────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double>   _pulseAnim; // 1.0 → 1.04 → 1.0 scale
  late final Animation<double>   _glowAnim;  // 0.3 → 0.6 → 0.3 glow opacity

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<DashboardController>();

    // ── Bob: 2-second sine loop ──────────────────────────────────────────────
    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Maps 0→1 controller value through a sine curve to a -6…+6 pixel offset.
    _bobAnim = _bobCtrl.drive(
      _SineDoubleTween(amplitude: 6.0),
    );

    // ── Button pulse: 1.8-second loop ───────────────────────────────────────
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1E14),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              _buildStatsBar(),
              const SizedBox(height: 16),
              _buildGreetingBubble(),
              const SizedBox(height: 12),
              _buildMascot(),
              const SizedBox(height: 20),
              _buildProgressCard(),
              const SizedBox(height: 20),
              _buildBeginButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────────────────────
  Widget _buildStatsBar() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF122A1F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _statCell('${_ctrl.weekStreak.value * 2} min', 'Training time'),
          _statDivider(),
          _statCell('25 %', 'Complexity'),
          _statDivider(),
          _statCell('${_ctrl.avgAccuracy.value} %', 'Focus score'),
          const Spacer(),
          _settingsButton(),
        ],
      ),
    ));
  }

  Widget _statCell(String value, String label) => Expanded(
        child: Column(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value.split(' ').first,
                    style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
                  ),
                  if (value.contains(' '))
                    TextSpan(
                      text: ' ${value.split(' ').last}',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.white54),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.white38)),
          ],
        ),
      );

  Widget _statDivider() => Container(
        width: 1, height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: Colors.white12,
      );

  Widget _settingsButton() => Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF00C896),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.settings, color: Colors.white, size: 18),
      );

  // ── Greeting bubble ───────────────────────────────────────────────────────────
  Widget _buildGreetingBubble() {
    return Obx(() {
      final hasStreak = _ctrl.hasStreak;
      // Accent color changes based on streak state
      final accentColor = hasStreak
          ? const Color(0xFFFFB300) // amber on streak
          : const Color(0xFF00C896); // teal default

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF122A1F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasStreak
                ? const Color(0xFFFFB300).withOpacity(0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: _buildGreetingText(_ctrl.greetingText, accentColor),
      );
    });
  }

  Widget _buildGreetingText(String text, Color accentColor) {
    // Highlight "Brainy" (or "fire" on streak) with the accent color
    const highlight = 'Brainy';
    final idx = text.indexOf(highlight);
    if (idx == -1) {
      return Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
              fontSize: 15, color: Colors.white70, height: 1.4));
    }
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.nunito(fontSize: 15, color: Colors.white70, height: 1.4),
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

  // ── Mascot with bob animation ─────────────────────────────────────────────────
  Widget _buildMascot() {
    return AnimatedBuilder(
      animation: _bobAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _bobAnim.value),
        child: child,
      ),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 170,
            // Use your existing BrainyPainter here
            child: CustomPaint(painter: BrainyPainter()),
          ),
          const SizedBox(height: 6),
          Text(
            'BRAINY',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: const Color(0xFF00C896),
            ),
          ),
        ],
      ),
    );
  }

  // ── Progress card ─────────────────────────────────────────────────────────────
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Math progress',
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87)),
              Obx(() => _streakBadge(_ctrl.weekStreak.value)),
            ],
          ),
          const SizedBox(height: 16),
          // Week dots
          Obx(() => _buildWeekRow(_ctrl.weekStreak.value)),
          const Divider(height: 28, color: Color(0xFFEEEEEE)),
          // Stats row
          Obx(() => Row(
            children: [
              _miniStat('Avg accuracy',
                  '${_ctrl.avgAccuracy.value}/28', 'equations'),
              _starStat(_ctrl.topScore.value),
              _miniStat('Latest session',
                  '${_ctrl.latestSession.value}/28', 'correct'),
            ],
          )),
        ],
      ),
    );
  }

  Widget _streakBadge(int streak) {
    if (streak == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00C896)),
        ),
        child: Text('No streak yet',
            style: GoogleFonts.nunito(
                fontSize: 12,
                color: const Color(0xFF00C896),
                fontWeight: FontWeight.w700)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFB300)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text('$streak day streak',
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: const Color(0xFFFFB300),
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildWeekRow(int streak) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    const labels = ['Mon', 'Tue', 'Today', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIdx = 2; // Wednesday

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
                color: isToday
                    ? const Color(0xFF00C896)
                    : isCompleted
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFF5F5F5),
                border: isCompleted && !isToday
                    ? Border.all(color: const Color(0xFF00C896), width: 1.5)
                    : null,
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
                            ? const Color(0xFF00C896)
                            : Colors.black38,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(labels[i],
                style: GoogleFonts.nunito(
                    fontSize: 9,
                    color: isToday ? const Color(0xFF00C896) : Colors.black38)),
          ],
        );
      }),
    );
  }

  Widget _miniStat(String title, String value, String sub) => Expanded(
        child: Column(
          children: [
            Text(title,
                style: GoogleFonts.nunito(
                    fontSize: 10, color: Colors.black45)),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87)),
            Text(sub,
                style: GoogleFonts.nunito(
                    fontSize: 10, color: Colors.black45)),
          ],
        ),
      );

  Widget _starStat(int topScore) => Expanded(
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFB300), size: 18),
                    Text(
                      '$topScore/28',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFB300)),
                    ),
                    Text('top score',
                        style: GoogleFonts.nunito(
                            fontSize: 8, color: const Color(0xFFFFB300))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  // ── Begin Challenge button with pulse glow ────────────────────────────────────
  Widget _buildBeginButton() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, child) => Transform.scale(
        scale: _pulseAnim.value,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C896).withOpacity(_glowAnim.value),
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
        height: 60,
        child: ElevatedButton.icon(
          onPressed: () => Get.toNamed(Routes.game),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C896),
            foregroundColor: const Color(0xFF0A1E14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          icon: const Text('🧠', style: TextStyle(fontSize: 20)),
          label: Text(
            'Begin challenge',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom sine tween ─────────────────────────────────────────────────────────
/// Maps the AnimationController's 0→1 value through a full sine cycle.
/// Result oscillates between -amplitude and +amplitude.
class _SineDoubleTween extends Animatable<double> {
  final double amplitude;
  const _SineDoubleTween({required this.amplitude});

  @override
  double transform(double t) => math.sin(t * 2 * math.pi) * amplitude;
}
