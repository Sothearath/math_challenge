// lib/features/game/widgets/victory_dialog.dart
//
// Gorgeous "Level Win" dialog shown when a round is completed.
// Features:
//   • Brainy mascot raising a trophy (CustomPainter)
//   • Animated XP counter ticking up from 0 to xpGained
//   • "Level Unlocked!" headline with complexity badge
//   • Two action buttons: Next Level / Back to Dashboard

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../bindings/app_bindings.dart';
import '../controllers/arithmetic_controller.dart';
import '../models/level_config.dart';
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

    // Entry scale + fade
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scaleAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.6, end: 1.0));
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    // XP counter tick (delayed 300 ms after entry)
    _xpCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _xpAnim = _xpCtrl.drive(
      IntTween(begin: 0, end: widget.xpGained)
          .chain(CurveTween(curve: Curves.easeOut)),
    );

    // Trophy bounce loop
    _trophyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _trophyBounce = Tween(begin: -6.0, end: 6.0)
        .animate(CurvedAnimation(parent: _trophyCtrl, curve: Curves.easeInOut));

    // Sequence
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
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0D2B1F), Color(0xFF0A1628)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF00C896), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00C896).withOpacity(0.35),
                  blurRadius: 40,
                  spreadRadius: 4,
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Trophy mascot ──
                AnimatedBuilder(
                  animation: _trophyBounce,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _trophyBounce.value),
                    child: _BrainyTrophyMascot(),
                  ),
                ),
                const SizedBox(height: 20),

                // ── "Level Unlocked!" ──
                const Text(
                  'Level Unlocked!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Complexity badge ──
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C896).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF00C896).withOpacity(0.5)),
                  ),
                  child: Text(
                    'Complexity increased to ${widget.newComplexity}%',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Color(0xFF00C896),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── XP counter ──
                AnimatedBuilder(
                  animation: _xpAnim,
                  builder: (_, __) => Column(
                    children: [
                      Text(
                        '+${_xpAnim.value} XP',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFB300),
                          height: 1,
                        ),
                      ),
                      const Text(
                        'earned this round',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Buttons ──
                Row(
                  children: [
                    // Back
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.back();
                          Get.offAllNamed(Routes.dashboard);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'Dashboard',
                          style: TextStyle(
                              fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next level
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          // Single Get.back() closes the dialog only.
                          // Get.off() replaces the game route underneath.
                          Get.back();
                          Get.delete<ArithmeticController>(force: true);
                          Get.off(
                                () => const ArithmeticChallengeView(),
                            binding: GameBinding(),
                            arguments: widget.nextLevel,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          foregroundColor: const Color(0xFF0A1628),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text(
                          '🚀 Next Level',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
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
      width: 130,
      height: 140,
      child: CustomPaint(painter: _TrophyMascotPainter()),
    );
  }
}

class _TrophyMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal   = Paint()..color = const Color(0xFF00C896);
    final dark   = Paint()..color = const Color(0xFF00352A);
    final white  = Paint()..color = Colors.white;
    final amber  = Paint()..color = const Color(0xFFFFB300);
    final glow   = Paint()
      ..color    = const Color(0xFF00C896).withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final cx = size.width / 2;

    // Glow halo
    canvas.drawCircle(Offset(cx, size.height * 0.28), 38, glow);

    // Head (circle)
    canvas.drawCircle(Offset(cx, size.height * 0.28), 34, teal);
    // Head shine
    canvas.drawCircle(Offset(cx - 10, size.height * 0.20), 10,
        Paint()..color = Colors.white.withOpacity(0.18));

    // Eyes
    canvas.drawCircle(Offset(cx - 10, size.height * 0.26), 5, dark);
    canvas.drawCircle(Offset(cx + 10, size.height * 0.26), 5, dark);
    // Eye shine
    canvas.drawCircle(Offset(cx - 8, size.height * 0.245), 2, white);
    canvas.drawCircle(Offset(cx + 12, size.height * 0.245), 2, white);

    // Smile
    final smilePath = Path()
      ..moveTo(cx - 10, size.height * 0.315)
      ..quadraticBezierTo(cx, size.height * 0.345, cx + 10, size.height * 0.315);
    canvas.drawPath(
        smilePath,
        Paint()
          ..color = dark.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);

    // Body
    final bodyRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, size.height * 0.60),
            width: 44,
            height: 44),
        const Radius.circular(10));
    canvas.drawRRect(bodyRect, teal);

    // Arms raised (trophy pose)
    // Left arm
    final leftArm = Path()
      ..moveTo(cx - 22, size.height * 0.55)
      ..quadraticBezierTo(
          cx - 44, size.height * 0.42, cx - 38, size.height * 0.36);
    canvas.drawPath(
        leftArm,
        Paint()
          ..color = teal.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);

    // Right arm
    final rightArm = Path()
      ..moveTo(cx + 22, size.height * 0.55)
      ..quadraticBezierTo(
          cx + 44, size.height * 0.42, cx + 38, size.height * 0.36);
    canvas.drawPath(
        rightArm,
        Paint()
          ..color = teal.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);

    // Legs
    canvas.drawLine(Offset(cx - 10, size.height * 0.82),
        Offset(cx - 14, size.height * 0.97),
        Paint()
          ..color = teal.color
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(Offset(cx + 10, size.height * 0.82),
        Offset(cx + 14, size.height * 0.97),
        Paint()
          ..color = teal.color
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);

    // ── Trophy ──────────────────────────────────────────────────────────────
    final trophyTop = Offset(cx, size.height * 0.10);

    // Trophy cup outline glow
    canvas.drawCircle(trophyTop, 22,
        Paint()
          ..color = const Color(0xFFFFB300).withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Cup body
    final cupPath = Path()
      ..moveTo(trophyTop.dx - 16, trophyTop.dy - 10)
      ..lineTo(trophyTop.dx - 12, trophyTop.dy + 10)
      ..quadraticBezierTo(
          trophyTop.dx, trophyTop.dy + 16, trophyTop.dx + 12, trophyTop.dy + 10)
      ..lineTo(trophyTop.dx + 16, trophyTop.dy - 10)
      ..close();
    canvas.drawPath(cupPath, amber);

    // Cup handles
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(trophyTop.dx - 14, trophyTop.dy - 2),
            width: 10,
            height: 12),
        -1.5,
        3.0,
        false,
        Paint()
          ..color = amber.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);
    canvas.drawArc(
        Rect.fromCenter(
            center: Offset(trophyTop.dx + 14, trophyTop.dy - 2),
            width: 10,
            height: 12),
        -1.6,
        -3.0,
        false,
        Paint()
          ..color = amber.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3);

    // Star on trophy
    _drawStar(canvas, trophyTop.translate(0, 0), 7, amber);

    // Trophy stem + base
    canvas.drawLine(
        Offset(trophyTop.dx, trophyTop.dy + 16),
        Offset(trophyTop.dx, trophyTop.dy + 22),
        Paint()
          ..color = amber.color
          ..strokeWidth = 4);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(trophyTop.dx, trophyTop.dy + 25),
                width: 24,
                height: 6),
            const Radius.circular(3)),
        amber);
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final outer = Offset(
        center.dx + r * _cos(i * 72 - 90),
        center.dy + r * _sin(i * 72 - 90),
      );
      final inner = Offset(
        center.dx + (r / 2.2) * _cos(i * 72 + 36 - 90),
        center.dy + (r / 2.2) * _sin(i * 72 + 36 - 90),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(outer.dx, outer.dy);
      }
      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _cos(double deg) => // ignore: unused_element
  (deg * 3.14159265358979 / 180).let((r) => r.let((_) => _cosRad(r)));
  double _sin(double deg) =>
      (deg * 3.14159265358979 / 180).let((r) => _sinRad(r));

  double _cosRad(double r) {
    // Simple Taylor approximation sufficient for small star
    double val = 1.0, term = 1.0;
    for (int n = 1; n <= 6; n++) {
      term *= -r * r / ((2 * n - 1) * (2 * n));
      val  += term;
    }
    return val;
  }

  double _sinRad(double r) {
    double val = r, term = r;
    for (int n = 1; n <= 6; n++) {
      term *= -r * r / ((2 * n) * (2 * n + 1));
      val  += term;
    }
    return val;
  }

  @override
  bool shouldRepaint(_TrophyMascotPainter old) => false;
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}