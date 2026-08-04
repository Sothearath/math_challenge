// lib/features/game/widgets/victory_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../bindings/app_bindings.dart';
import '../controllers/arithmetic_controller.dart';
import '../models/level_config.dart';
import '../theme/app_theme.dart';
import '../views/arithmetic_challenge_view.dart';

class VictoryDialog extends StatefulWidget {
  final int         xpGained;
  final int         newComplexity;
  final LevelConfig nextLevel;

  const VictoryDialog({
    super.key,
    required this.xpGained,
    required this.newComplexity,
    required this.nextLevel,
  });

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _xpCtrl;
  late final AnimationController _trophyCtrl;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<int>    _xpAnim;
  late final Animation<double> _trophyBounce;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scaleAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.6, end: 1.0));
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _xpAnim = _xpCtrl.drive(
      IntTween(begin: 0, end: widget.xpGained)
          .chain(CurveTween(curve: Curves.easeOut)),
    );

    _trophyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _trophyBounce = Tween(begin: -6.0, end: 6.0)
        .animate(CurvedAnimation(parent: _trophyCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _xpCtrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _xpCtrl.dispose();
    _trophyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDailyChallenge = widget.nextLevel.levelNumber == -1; // Matches our redirect configuration sentinel

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              // Dark card — matches equation card in ArithmeticChallengeView
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusDialog),
              border: Border.all(color: AppColors.mint.withOpacity(0.30)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withOpacity(0.20),
                  blurRadius: 40,
                  spreadRadius: 4,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            // Clip so the gradient header respects the dialog border radius
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Gradient header band — matches app gradient ─────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.gradientTop, AppColors.gradientBottom],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Trophy mascot bouncing
                      AnimatedBuilder(
                        animation: _trophyBounce,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _trophyBounce.value),
                          child: _BrainyTrophyMascot(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Update Headline text dynamically ──
                      Text(
                        isDailyChallenge ? 'Challenge Conquered! 🏆' : 'Level Unlocked! 🎉',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cobalt,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ── Update Complexity description dynamically ──
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                          border: Border.all(color: Colors.white.withOpacity(0.55)),
                        ),
                        child: Text(
                          isDailyChallenge
                              ? 'Perfect clear recorded for today!'
                              : 'Complexity increased to ${widget.newComplexity}%',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.cobalt,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body — dark card surface ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [

                      // XP counter — sunflower accent
                      AnimatedBuilder(
                        animation: _xpAnim,
                        builder: (_, __) => Column(
                          children: [
                            Text(
                              '+${_xpAnim.value} XP',
                              style: GoogleFonts.nunito(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: AppColors.sunflower,
                                height: 1,
                              ),
                            ),
                            Text(
                              'earned this round',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: AppColors.mintDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ... scroll down to Row of buttons ...
                      Row(
                        children: [
                          // Dashboard Button — Handles both paths cleanly
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                Get.back(); // Dismiss dialog overlay frame

                                if (!isDailyChallenge) {
                                  // Only push standard level indices to Firestore profile schema
                                  final controller = Get.find<ArithmeticController>();
                                  await controller.updateLevelOnFirestore(widget.nextLevel.levelNumber);
                                }

                                Get.offAllNamed(Routes.dashboard);
                              },
                              child: Text('Back', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.mintDim)),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Action Button — Changes text/destination for Daily Challenges
                          Expanded(
                            flex: 2,
                            child: DecoratedBox(
                              // ⭐ DO NOT REMOVE THIS DECORATION PROPERTY:
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.mint, AppColors.mintGlow],
                                ),
                                borderRadius: BorderRadius.circular(AppTheme.radiusKey),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.mint.withOpacity(0.40),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(AppTheme.radiusKey),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusKey),
                                  onTap: () async {
                                    Get.back(); // Dismiss dialog frame

                                    if (isDailyChallenge) {
                                      Get.offAllNamed(Routes.dashboard);
                                    } else {
                                      if (Get.isRegistered<ArithmeticController>()) {
                                        final controller = Get.find<ArithmeticController>();
                                        controller.loadNextLevel(widget.nextLevel);
                                        await controller.updateLevelOnFirestore(widget.nextLevel.levelNumber);
                                      } else {
                                        Get.off(() => const ArithmeticChallengeView(), binding: GameBinding(), arguments: widget.nextLevel);
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    child: Center(
                                      child: Text(
                                        isDailyChallenge ? '🏠 Done' : '🚀 Next Level',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                          color: AppColors.mintText,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ── Brainy holding a trophy ───────────────────────────────────────────────────
class _BrainyTrophyMascot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 200,
      child: CustomPaint(painter: _TrophyMascotPainter()),
    );
  }
}

class _TrophyMascotPainter extends CustomPainter {
  // ── Trig helpers ──────────────────────────────────────────────────────────
  static double _cos(double r) {
    double v = 1, t = 1;
    for (int n = 1; n <= 8; n++) { t *= -r * r / ((2*n-1)*(2*n)); v += t; }
    return v;
  }
  static double _sin(double r) {
    double v = r, t = r;
    for (int n = 1; n <= 8; n++) { t *= -r * r / ((2*n)*(2*n+1)); v += t; }
    return v;
  }
  static double _rad(double deg) => deg * 3.14159265358979 / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final w  = size.width;
    final h  = size.height;
    final cx = w / 2;

    // Layout fractions
    const double trophyFY = 0.15;  // trophy centre Y
    const double headFY   = 0.50;  // head centre Y
    const double bodyFY   = 0.72;  // body centre Y

    final headR = w * 0.22;
    final bodyW = w * 0.30;
    final bodyH = h * 0.17;

    // ── 1. CONFETTI (behind everything) ─────────────────────────────────────
    _drawConfetti(canvas, w, h);

    // ── 2. LEGS ──────────────────────────────────────────────────────────────
    final legPaint = Paint()
      ..color = AppColors.brainyBody
      ..strokeWidth = w * 0.075
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx - w * 0.07, h * (bodyFY + 0.10)),
      Offset(cx - w * 0.10, h * 0.97),
      legPaint,
    );
    canvas.drawLine(
      Offset(cx + w * 0.07, h * (bodyFY + 0.10)),
      Offset(cx + w * 0.10, h * 0.97),
      legPaint,
    );
    canvas.drawCircle(Offset(cx - w * 0.10, h * 0.97), w * 0.045,
        Paint()..color = AppColors.brainyBody);
    canvas.drawCircle(Offset(cx + w * 0.10, h * 0.97), w * 0.045,
        Paint()..color = AppColors.brainyBody);

    // ── 3. BODY ───────────────────────────────────────────────────────────────
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * bodyFY), width: bodyW, height: bodyH),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bodyRect, Paint()..color = AppColors.brainyBody);
    // Body top shine
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - bodyW / 2 + 4, h * bodyFY - bodyH / 2 + 3, bodyW - 8, 5),
        Radius.circular(w * 0.03),
      ),
      Paint()..color = Colors.white.withOpacity(0.22),
    );

    // ── 4. ARMS (cubic bezier — victory pose toward trophy) ──────────────────
    final armPaint = Paint()
      ..color       = AppColors.brainyBody
      ..strokeWidth = w * 0.075
      ..strokeCap   = StrokeCap.round
      ..style       = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(cx - bodyW * 0.45, h * (bodyFY - 0.04))
        ..cubicTo(
          cx - w * 0.36, h * (bodyFY - 0.10),
          cx - w * 0.34, h * (trophyFY + 0.18),
          cx - w * 0.22, h * (trophyFY + 0.12),
        ),
      armPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + bodyW * 0.45, h * (bodyFY - 0.04))
        ..cubicTo(
          cx + w * 0.36, h * (bodyFY - 0.10),
          cx + w * 0.34, h * (trophyFY + 0.18),
          cx + w * 0.22, h * (trophyFY + 0.12),
        ),
      armPaint,
    );

    // ── 5. HEAD ───────────────────────────────────────────────────────────────
    final hc = Offset(cx, h * headFY);

    // Outer glow
    canvas.drawCircle(
      hc, headR * 1.18,
      Paint()
        ..color      = Colors.white.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Radial gradient sphere
    canvas.drawCircle(
      hc, headR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.40),
          radius: 0.85,
          colors: const [Color(0xFF4DDBB0), Color(0xFF00C896), Color(0xFF007A5E)],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(Rect.fromCircle(center: hc, radius: headR)),
    );

    // Visor band clipped to head
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: hc, radius: headR)));
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(cx, h * headFY + headR * 0.04),
          width: headR * 2,
          height: headR * 0.28),
      Paint()..color = AppColors.darkBg.withOpacity(0.50),
    );
    canvas.restore();

    // Shine crescent
    canvas.drawCircle(
      Offset(cx - headR * 0.30, h * headFY - headR * 0.32), headR * 0.28,
      Paint()
        ..color      = Colors.white.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawCircle(
      Offset(cx - headR * 0.35, h * headFY - headR * 0.36), headR * 0.09,
      Paint()..color = Colors.white.withOpacity(0.60),
    );

    // Eyes
    _drawEye(canvas, Offset(cx - headR * 0.30, h * headFY - headR * 0.04), headR * 0.20);
    _drawEye(canvas, Offset(cx + headR * 0.30, h * headFY - headR * 0.04), headR * 0.20);

    // Wide celebration smile
    final smileY = h * headFY + headR * 0.26;
    canvas.drawPath(
      Path()
        ..moveTo(cx - headR * 0.38, smileY)
        ..quadraticBezierTo(cx, smileY + headR * 0.28, cx + headR * 0.38, smileY),
      Paint()
        ..color       = AppColors.darkBg
        ..style       = PaintingStyle.stroke
        ..strokeWidth = headR * 0.16
        ..strokeCap   = StrokeCap.round,
    );

    // Cheek blush
    final blush = Paint()
      ..color      = const Color(0xFFFF8A65).withOpacity(0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx - headR * 0.52, h * headFY + headR * 0.24),
            width: headR * 0.42, height: headR * 0.22),
        blush);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + headR * 0.52, h * headFY + headR * 0.24),
            width: headR * 0.42, height: headR * 0.22),
        blush);

    // Antenna
    canvas.drawLine(
      Offset(cx, h * headFY - headR),
      Offset(cx, h * headFY - headR * 1.20),
      Paint()
        ..color       = const Color(0xFF007A5E)
        ..strokeWidth = headR * 0.10
        ..strokeCap   = StrokeCap.round,
    );
    canvas.drawCircle(Offset(cx, h * headFY - headR * 1.24), headR * 0.10,
        Paint()..color = const Color(0xFF007A5E));
    canvas.drawCircle(Offset(cx - headR * 0.03, h * headFY - headR * 1.28), headR * 0.04,
        Paint()..color = const Color(0xFF4DDBB0).withOpacity(0.80));

    // ── 6. TROPHY ─────────────────────────────────────────────────────────────
    _drawTrophy(canvas, cx, h * trophyFY, w * 0.28);
  }

  // ── Trophy ──────────────────────────────────────────────────────────────────
  void _drawTrophy(Canvas canvas, double cx, double cy, double size) {
    final r          = size / 2;
    const gold      = AppColors.sunflower;
    const goldDark  = Color(0xFFCC8E00);
    const goldLight = Color(0xFFFFE082);

    // Outer glow
    canvas.drawCircle(Offset(cx, cy), r * 1.2,
        Paint()
          ..color      = gold.withOpacity(0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));

    // Cup body — gradient fill for 3-D depth
    final cupPath = Path()
      ..moveTo(cx - r * 0.85, cy - r * 0.72)
      ..lineTo(cx + r * 0.85, cy - r * 0.72)
      ..lineTo(cx + r * 0.60, cy + r * 0.40)
      ..quadraticBezierTo(cx, cy + r * 0.72, cx - r * 0.60, cy + r * 0.40)
      ..close();

    canvas.drawPath(
      cupPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [goldLight, gold, goldDark],
        ).createShader(Rect.fromCenter(
            center: Offset(cx, cy), width: r * 2, height: r * 1.5)),
    );

    // Rim highlight
    canvas.drawLine(
      Offset(cx - r * 0.82, cy - r * 0.72),
      Offset(cx + r * 0.82, cy - r * 0.72),
      Paint()
        ..color       = Colors.white.withOpacity(0.55)
        ..strokeWidth = r * 0.10
        ..strokeCap   = StrokeCap.round,
    );

    // Inner shine arc
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx - r * 0.15, cy - r * 0.15),
          width: r * 0.8, height: r * 0.7),
      _rad(-140), _rad(70), false,
      Paint()
        ..color       = Colors.white.withOpacity(0.30)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = r * 0.10
        ..strokeCap   = StrokeCap.round,
    );

    // Handles
    final hPaint = Paint()
      ..color       = goldDark
      ..style       = PaintingStyle.stroke
      ..strokeWidth = r * 0.18
      ..strokeCap   = StrokeCap.round;

    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(cx - r * 0.92, cy - r * 0.18),
            width: r * 0.65, height: r * 0.85),
        _rad(-120), _rad(-120), false, hPaint);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(cx + r * 0.92, cy - r * 0.18),
            width: r * 0.65, height: r * 0.85),
        _rad(-60), _rad(120), false, hPaint);

    // Star on cup (white face + golden shadow for depth)
    _drawStar(canvas, Offset(cx + r * 0.04, cy - r * 0.06), r * 0.30,
        Paint()..color = goldDark.withOpacity(0.40));
    _drawStar(canvas, Offset(cx, cy - r * 0.10), r * 0.30,
        Paint()..color = Colors.white.withOpacity(0.90));

    // Stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy + r * 0.68), width: r * 0.22, height: r * 0.50),
        Radius.circular(r * 0.06),
      ),
      Paint()..color = goldDark,
    );

    // Base trapezoid
    final basePath = Path()
      ..moveTo(cx - r * 0.70, cy + r * 0.94)
      ..lineTo(cx + r * 0.70, cy + r * 0.94)
      ..lineTo(cx + r * 0.55, cy + r * 0.76)
      ..lineTo(cx - r * 0.55, cy + r * 0.76)
      ..close();

    canvas.drawPath(
      basePath,
      Paint()
        ..shader = const LinearGradient(
          colors: [goldLight, gold],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCenter(
            center: Offset(cx, cy + r * 0.85), width: r * 1.4, height: r * 0.3)),
    );
    canvas.drawLine(
      Offset(cx - r * 0.68, cy + r * 0.95),
      Offset(cx + r * 0.68, cy + r * 0.95),
      Paint()
        ..color       = Colors.white.withOpacity(0.40)
        ..strokeWidth = r * 0.08
        ..strokeCap   = StrokeCap.round,
    );

    // Sparkle dots at trophy corners
    for (final pt in [
      Offset(cx - r * 1.10, cy - r * 0.85),
      Offset(cx + r * 1.10, cy - r * 0.80),
      Offset(cx - r * 0.70, cy - r * 1.10),
      Offset(cx + r * 0.80, cy - r * 1.05),
    ]) {
      _drawSparkle(canvas, pt, r * 0.10, gold);
    }
  }

  // ── Eye ─────────────────────────────────────────────────────────────────────
  void _drawEye(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(c.dx, c.dy - r * 0.08), r * 0.56,
        Paint()..color = AppColors.darkBg);
    canvas.drawCircle(Offset(c.dx + r * 0.22, c.dy - r * 0.28), r * 0.22,
        Paint()..color = Colors.white);
    canvas.drawCircle(c, r,
        Paint()
          ..color       = const Color(0xFF007A5E).withOpacity(0.22)
          ..style       = PaintingStyle.stroke
          ..strokeWidth = r * 0.12);
  }

  // ── 5-point star ─────────────────────────────────────────────────────────────
  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a1    = _rad(i * 72.0 - 90);
      final a2    = _rad(i * 72.0 + 36 - 90);
      final outer = Offset(center.dx + r * _cos(a1), center.dy + r * _sin(a1));
      final inner = Offset(center.dx + r / 2.3 * _cos(a2), center.dy + r / 2.3 * _sin(a2));
      i == 0 ? path.moveTo(outer.dx, outer.dy) : path.lineTo(outer.dx, outer.dy);
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ── 4-point sparkle ──────────────────────────────────────────────────────────
  void _drawSparkle(Canvas canvas, Offset c, double r, Color color) {
    final p1 = Paint()..color = color.withOpacity(0.85)..strokeWidth = r * 0.6..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), p1);
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), p1);
    final p2 = Paint()..color = color.withOpacity(0.50)..strokeWidth = r * 0.4..strokeCap = StrokeCap.round;
    final d = r * 0.65;
    canvas.drawLine(Offset(c.dx - d, c.dy - d), Offset(c.dx + d, c.dy + d), p2);
    canvas.drawLine(Offset(c.dx + d, c.dy - d), Offset(c.dx - d, c.dy + d), p2);
  }

  // ── Confetti pieces ───────────────────────────────────────────────────────────
  void _drawConfetti(Canvas canvas, double w, double h) {
    // [xFrac, yFrac, sizeFrac, colorIndex, rotDeg]
    // All literals are doubles so Dart infers List<List<double>> — avoids
    // the _TypeError when casting colorIndex to int via (s[3] as double).toInt()
    const List<List<double>> specs = [
      [0.10, 0.28, 0.030, 0.0, 15.0],
      [0.88, 0.32, 0.025, 1.0, -20.0],
      [0.15, 0.55, 0.022, 2.0,  45.0],
      [0.85, 0.50, 0.028, 3.0, -35.0],
      [0.20, 0.78, 0.020, 0.0,  30.0],
      [0.80, 0.75, 0.022, 1.0,  10.0],
      [0.06, 0.72, 0.018, 2.0, -15.0],
      [0.93, 0.68, 0.018, 3.0,  25.0],
      [0.30, 0.08, 0.024, 1.0,  50.0],
      [0.70, 0.10, 0.024, 2.0, -40.0],
    ];

    const colors = [
      Color(0xFFFF6B6B), // coral
      Color(0xFF00E676), // green
      Color(0xFF40C4FF), // sky blue
      Color(0xFFFFB61D), // sunflower
    ];

    for (final s in specs) {
      final half = s[2] * w;
      canvas.save();
      canvas.translate(s[0] * w, s[1] * h);
      canvas.rotate(_rad(s[4]));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: half * 2, height: half),
          Radius.circular(half * 0.3),
        ),
        Paint()..color = colors[s[3].toInt()].withOpacity(0.85),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_TrophyMascotPainter old) => false;
}