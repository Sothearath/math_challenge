// lib/views/brainy_dashboard_view.dart
//
// FlexiArithmetic: Brainy Challenge
// Spring Green Harmony palette — all fitness language replaced with math terms.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../core/constants.dart';

// ─── Spring Green Harmony palette ─────────────────────────────────────────────

const _kGreenBg      = Color(0xFF0D1F18);   // deepest dark-green background
const _kGreenCard    = Color(0xFF142B20);   // stat bar / bubble surface
const _kGreenDivider = Color(0xFF1F3D2C);   // subtle divider
const _kMint         = Color(0xFF2ED1A2);   // primary action / accent
const _kMintDark     = Color(0xFF1BAC84);   // pressed / shadow
const _kMintText     = Color(0xFF0A3D28);   // text ON mint
const _kMintDim      = Color(0xFF9EC4B0);   // muted text on dark
const _kMintFaint    = Color(0xFF4D7A62);   // very muted label
const _kMintGlow     = Color(0xFF6BEDD0);   // highlight lobe on brain

// ─── View ─────────────────────────────────────────────────────────────────────

class BrainyDashboardView extends GetView<DashboardController> {
  const BrainyDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kGreenBg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: const [
                SizedBox(height: 12),
                _StatsBar(),
                SizedBox(height: 20),
                _MascotSection(),
                SizedBox(height: 20),
                _ActivityCard(),
                SizedBox(height: 16),
                _StartButton(),
                SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATS BAR  —  Training time / Complexity / Focus score
// ═══════════════════════════════════════════════════════════════════════════════

class _StatsBar extends GetView<DashboardController> {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color:        _kGreenCard,
          borderRadius: BorderRadius.circular(AppLayout.statBarRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Obx(() => Row(
          children: [
            _StatCell(
              value: '${controller.trainingMinutes.value}',
              unit:  'min',
              label: 'Training time',
            ),
            _Vdiv(),
            _StatCell(
              value: '${controller.complexityPct.value}',
              unit:  '%',
              label: 'Complexity',
            ),
            _Vdiv(),
            _StatCell(
              value: '${controller.focusScore.value}',
              unit:  '%',
              label: 'Focus score',
            ),
            const SizedBox(width: 10),
            // Settings
            GestureDetector(
              onTap: () => Get.toNamed(Routes.settings),
              child: Container(
                width:  34, height: 34,
                decoration: const BoxDecoration(
                    color: _kMint, shape: BoxShape.circle),
                child: const Icon(
                    Icons.settings_rounded,
                    size: 17, color: _kMintText),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, unit, label;
  const _StatCell({required this.value, required this.unit,
    required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text:  value,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700,
                    color: Color(0xFFE8F9F0)),
              ),
              TextSpan(
                text:  ' $unit',
                style: const TextStyle(fontSize: 11, color: Color(0xFF5A8A70)),
              ),
            ]),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(fontSize: 10, color: _kMintFaint,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Vdiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 30, color: _kGreenDivider,
          margin: const EdgeInsets.symmetric(horizontal: 4));
}

// ═══════════════════════════════════════════════════════════════════════════════
// MASCOT  —  Brainy with math-equation barbell + floating animation
// ═══════════════════════════════════════════════════════════════════════════════

class _MascotSection extends StatefulWidget {
  const _MascotSection();

  @override
  State<_MascotSection> createState() => _MascotSectionState();
}

class _MascotSectionState extends State<_MascotSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;
  late final Animation<double>   _dy;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _dy = Tween<double>(begin: -4, end: 4).animate(
        CurvedAnimation(parent: _float, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _float.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Speech bubble
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 52),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color:        _kGreenCard,
            borderRadius: BorderRadius.circular(12),
            border:       Border.all(color: _kGreenDivider, width: 0.5),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(fontSize: 12.5, color: _kMintDim, height: 1.45),
              children: [
                TextSpan(text: "Hi, I'm "),
                TextSpan(text: 'Brainy',
                    style: TextStyle(color: _kMint,
                        fontWeight: FontWeight.w600)),
                TextSpan(text: ". Let's sharpen those math skills today!"),
              ],
            ),
          ),
        ),
        // Bubble tail
        CustomPaint(
          size: const Size(14, 7),
          painter: _TailPainter(color: _kGreenCard),
        ),
        // Floating mascot
        AnimatedBuilder(
          animation: _dy,
          builder: (_, child) =>
              Transform.translate(offset: Offset(0, _dy.value), child: child),
          child: const _BrainyMascot(),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  final Color color;
  const _TailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.color != color;
}

// ─── Brainy mascot ─────────────────────────────────────────────────────────────
//
// Spring green brain, lifting a barbell whose plates display "5" and "3".
// Swap the body of build() for Lottie.asset() when you have an animation file.

class _BrainyMascot extends StatelessWidget {
  const _BrainyMascot();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:  160,
      height: 136,
      child:  CustomPaint(painter: _BrainyPainter()),
    );
  }
}

class _BrainyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;   // 80
    final cy = size.height * 0.35; // ~47

    // ── Brain body ──────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 60, height: 52),
      Paint()..color = _kMint,
    );
    // Highlight lobe
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 8), width: 32, height: 22),
      Paint()..color = _kMintGlow,
    );

    // ── Brain ridges ────────────────────────────────────────────────────────
    final ridgePaint = Paint()
      ..color       = _kMintDark
      ..strokeWidth = 1.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    for (final path in [
      Path()
        ..moveTo(cx - 10, cy - 12)
        ..cubicTo(cx - 2, cy - 18, cx + 2, cy - 18, cx + 10, cy - 12),
      Path()
        ..moveTo(cx - 22, cy + 2)
        ..cubicTo(cx - 26, cy - 4, cx - 26, cy + 8, cx - 22, cy + 14),
      Path()
        ..moveTo(cx + 22, cy + 2)
        ..cubicTo(cx + 26, cy - 4, cx + 26, cy + 8, cx + 22, cy + 14),
    ]) {
      canvas.drawPath(path, ridgePaint);
    }

    // ── Eyes ────────────────────────────────────────────────────────────────
    final eyePaint   = Paint()..color = _kMintText;
    final shinePaint = Paint()..color = Colors.white;
    for (final ex in [cx - 9.0, cx + 9.0]) {
      canvas.drawCircle(Offset(ex, cy + 6), 4.5, eyePaint);
      canvas.drawCircle(Offset(ex - 1.5, cy + 4.5), 1.2, shinePaint);
    }

    // ── Smile ───────────────────────────────────────────────────────────────
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + 12), width: 16, height: 10),
      0.15, 2.8, false,
      Paint()
        ..color       = _kMintText
        ..strokeWidth = 1.6
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round,
    );

    // ── Arms ────────────────────────────────────────────────────────────────
    final armPaint = Paint()
      ..color       = _kMint
      ..strokeWidth = 6
      ..strokeCap   = StrokeCap.round;
    canvas.drawLine(
        Offset(cx - 26, cy + 24), Offset(cx - 18, cy + 33), armPaint);
    canvas.drawLine(
        Offset(cx + 26, cy + 24), Offset(cx + 18, cy + 33), armPaint);

    // ── Barbell bar ─────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(cx - 38, cy + 33), Offset(cx + 38, cy + 33),
      Paint()
        ..color       = const Color(0xFF3A3A3A)
        ..strokeWidth = 5
        ..strokeCap   = StrokeCap.round,
    );

    // ── Weight plates with math numerals ────────────────────────────────────
    _drawWeightPlate(canvas, cx - 44, cy + 25, '5');
    _drawWeightPlate(canvas, cx + 36, cy + 25, '3');

    // ── Body / torso ────────────────────────────────────────────────────────
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 48), width: 26, height: 14),
      Paint()..color = _kMintDark.withOpacity(0.35),
    );

    // ── Legs ────────────────────────────────────────────────────────────────
    final legPaint = Paint()
      ..color       = _kMint.withOpacity(0.9)
      ..strokeWidth = 5.5
      ..strokeCap   = StrokeCap.round;
    canvas.drawLine(
        Offset(cx - 7, cy + 55), Offset(cx - 11, cy + 74), legPaint);
    canvas.drawLine(
        Offset(cx + 7, cy + 55), Offset(cx + 11, cy + 74), legPaint);

    // Feet
    final footPaint = Paint()..color = _kMintDark;
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx - 13, cy + 77), width: 15, height: 7), footPaint);
    canvas.drawOval(Rect.fromCenter(
        center: Offset(cx + 13, cy + 77), width: 15, height: 7), footPaint);

    // ── BRAINY label ────────────────────────────────────────────────────────
    _drawLabel(canvas, 'BRAINY', cx, cy + 91);
  }

  void _drawWeightPlate(Canvas canvas, double x, double y, String numeral) {
    // Outer plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 16, 17), const Radius.circular(4)),
      Paint()..color = const Color(0xFF2A2A2A),
    );
    // Inner collar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 5, y + 1, 8, 15), const Radius.circular(3)),
      Paint()..color = const Color(0xFF1E1E1E),
    );
    // Numeral in mint
    final tp = TextPainter(
      text: TextSpan(
        text:  numeral,
        style: const TextStyle(
          fontSize:   11,
          fontWeight: FontWeight.w800,
          color:      _kMint,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x + 8 - tp.width / 2, y + 8.5 - tp.height / 2));
  }

  void _drawLabel(Canvas canvas, String text, double cx, double y) {
    final tp = TextPainter(
      text: TextSpan(
        text:  text,
        style: const TextStyle(
          fontSize:      9,
          fontWeight:    FontWeight.w700,
          color:         _kMint,
          letterSpacing: 1.6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTIVITY CARD  —  weekly streak + math score badges
// ═══════════════════════════════════════════════════════════════════════════════

class _ActivityCard extends GetView<DashboardController> {
  const _ActivityCard();

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0 = Mon

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Math progress',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: Color(0xFF111111))),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 4),
                  decoration: BoxDecoration(
                    color:        const Color(0xFFD4F2E7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.streakLabel,
                    style: const TextStyle(fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F5E42)),
                  ),
                )),
              ],
            ),

            const SizedBox(height: 16),

            // 7-day tracker
            Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) => _DayDot(
                initial: _days[i][0],
                name:    _days[i],
                done:    controller.completedDays[i],
                isToday: i == today,
              )),
            )),

            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 14),

            // Score badges
            Obx(() => Row(
              children: [
                // Avg accuracy
                Expanded(child: _RoundedBadge(
                  label:   'Avg accuracy',
                  value:   '${controller.avgCorrect.value}/${controller.avgTotal.value}',
                  sub:     'equations',
                )),
                const SizedBox(width: 8),
                // Top score
                Expanded(child: _StarBadge(
                  value: '${controller.topCorrect.value}/${controller.topTotal.value}',
                )),
                const SizedBox(width: 8),
                // Latest session
                Expanded(child: _RoundedBadge(
                  label:   'Latest session',
                  value:   '${controller.lastCorrect.value}/${controller.lastTotal.value}',
                  sub:     'correct',
                )),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

// ─── Day dot ───────────────────────────────────────────────────────────────────

class _DayDot extends StatelessWidget {
  final String initial, name;
  final bool   done, isToday;
  const _DayDot({required this.initial, required this.name,
    required this.done, required this.isToday});

  @override
  Widget build(BuildContext context) {
    Color bg; Color fg; Border? border;

    if (isToday) {
      bg = _kMint; fg = _kMintText;
    } else if (done) {
      bg = const Color(0xFF111E17); fg = Colors.white;
    } else {
      bg = Colors.transparent; fg = const Color(0xFFBBCCBB);
      border = Border.all(color: const Color(0xFFDDEEDD), width: 1.5);
    }

    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: bg, shape: BoxShape.circle, border: border),
          child: Center(
            child: Text(initial,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                    color: fg)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isToday ? 'Today' : name.substring(0, 3),
          style: const TextStyle(fontSize: 9, color: Color(0xFFAAAAAA),
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ─── Rounded badge ────────────────────────────────────────────────────────────

class _RoundedBadge extends StatelessWidget {
  final String label, value, sub;
  const _RoundedBadge({required this.label, required this.value,
    required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color:        const Color(0xFFF5F6F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF999999))),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 15,
                  fontWeight: FontWeight.w700, color: Color(0xFF111111))),
          const SizedBox(height: 2),
          Text(sub,
              style: const TextStyle(fontSize: 9, color: Color(0xFFBBBBBB))),
        ],
      ),
    );
  }
}

// ─── Star badge (CustomClipper) ───────────────────────────────────────────────

class _StarBadge extends StatelessWidget {
  final String value;
  const _StarBadge({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _StarClipper(points: 5, innerRatio: 0.50),
      child: Container(
        height: 72,
        color:  const Color(0xFFFFF8E6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded,
                size: 13, color: Color(0xFFEF9F27)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w800, color: Color(0xFF7A4F08))),
            const SizedBox(height: 2),
            const Text('top score',
                style: TextStyle(fontSize: 9, color: Color(0xFFB47A15))),
          ],
        ),
      ),
    );
  }
}

class _StarClipper extends CustomClipper<Path> {
  final int    points;
  final double innerRatio;
  const _StarClipper({required this.points, required this.innerRatio});

  @override
  Path getClip(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final R  = cx * 0.88;
    final r  = R * innerRatio;
    final p  = Path();
    final s  = math.pi / points;
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? R : r;
      final angle  = i * s - math.pi / 2;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      i == 0 ? p.moveTo(x, y) : p.lineTo(x, y);
    }
    return p..close();
  }

  @override
  bool shouldReclip(_StarClipper old) =>
      old.points != points || old.innerRatio != innerRatio;
}

// ═══════════════════════════════════════════════════════════════════════════════
// START BUTTON  —  "Begin challenge"
// ═══════════════════════════════════════════════════════════════════════════════

class _StartButton extends GetView<DashboardController> {
  const _StartButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTapDown:  (_) => controller.startAnim.forward(),
        onTapUp:    (_) async {
          await controller.animateTap();
          Get.toNamed(Routes.game);
        },
        onTapCancel: () => controller.startAnim.reverse(),
        child: AnimatedBuilder(
          animation: controller.startScale,
          builder: (_, child) =>
              Transform.scale(scale: controller.startScale.value, child: child),
          child: Container(
            width:  double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color:        _kMint,
              borderRadius: BorderRadius.circular(AppLayout.pillRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.psychology_rounded, size: 20, color: _kMintText),
                SizedBox(width: 10),
                Text(
                  'Begin challenge',
                  style: TextStyle(
                    fontSize:      17,
                    fontWeight:    FontWeight.w700,
                    color:         _kMintText,
                    letterSpacing: 0.2,
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