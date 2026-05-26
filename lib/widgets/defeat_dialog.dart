// lib/features/game/widgets/defeat_dialog.dart
//
// "Game Over" defeat dialog.
// Features:
//   • Exhausted Brainy with sweatband (CustomPainter)
//   • Empathetic message
//   • Shake entry animation
//   • Try Again / Dashboard buttons

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../bindings/app_bindings.dart';
import '../controllers/arithmetic_controller.dart';
import '../models/level_config.dart';
import '../views/arithmetic_challenge_view.dart';

class DefeatDialog extends StatefulWidget {
  final LevelConfig currentLevel;
  const DefeatDialog({super.key, required this.currentLevel});

  @override
  State<DefeatDialog> createState() => _DefeatDialogState();
}

class _DefeatDialogState extends State<DefeatDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _shake;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0),   weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4))
        .drive(Tween(begin: 0.0, end: 1.0));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child: Transform.translate(
          offset: Offset(_shake.value, 0),
          child: child,
        ),
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A0A0A), Color(0xFF0A1628)],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFF5252), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5252).withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Exhausted mascot ──
              SizedBox(
                width: 120,
                height: 130,
                child: CustomPaint(painter: _ExhaustedBrainyPainter()),
              ),
              const SizedBox(height: 20),

              // ── Headline ──
              const Text(
                'Close one!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // ── Subtitle ──
              const Text(
                "Let's rest the brain and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  color: Colors.white60,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // ── Buttons ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        Get.offAllNamed(Routes.dashboard);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Rest',
                        style: TextStyle(
                            fontFamily: 'Nunito', fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.delete<ArithmeticController>(force: true);
                        Get.off(
                              () => const ArithmeticChallengeView(),
                          binding: GameBinding(),
                          arguments: widget.currentLevel,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        '🔄 Try Again',
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
    );
  }
}

// ── Exhausted Brainy painter ──────────────────────────────────────────────────
class _ExhaustedBrainyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal   = Paint()..color = const Color(0xFF00C896);
    final dark   = Paint()..color = const Color(0xFF00352A);
    final white  = Paint()..color = Colors.white;
    final red    = Paint()..color = const Color(0xFFFF5252);
    final sweat  = Paint()..color = const Color(0xFF40C4FF).withOpacity(0.7);

    final cx = size.width / 2;
    final hy = size.height * 0.30; // head y centre

    // Head glow (dim red tint for defeat)
    canvas.drawCircle(
        Offset(cx, hy),
        36,
        Paint()
          ..color = const Color(0xFFFF5252).withOpacity(0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));

    // Head
    canvas.drawCircle(Offset(cx, hy), 32, teal);

    // Sweatband
    canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, hy), radius: 32),
        math.pi + 0.3,
        math.pi - 0.6,
        false,
        Paint()
          ..color = const Color(0xFFFF5252)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round);

    // Tired eyes (half-closed — drawn as short arcs)
    _drawTiredEye(canvas, Offset(cx - 10, hy + 2), dark);
    _drawTiredEye(canvas, Offset(cx + 10, hy + 2), dark);

    // Sweat drops
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + 28, hy - 6), width: 6, height: 9),
        sweat);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx + 34, hy + 4), width: 4, height: 7),
        sweat);

    // Slight frown
    final frownPath = Path()
      ..moveTo(cx - 9, hy + 16)
      ..quadraticBezierTo(cx, hy + 12, cx + 9, hy + 16);
    canvas.drawPath(
        frownPath,
        Paint()
          ..color = dark.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);

    // Body
    final bodyRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, size.height * 0.63),
            width: 42,
            height: 42),
        const Radius.circular(10));
    canvas.drawRRect(bodyRect, teal);

    // Arms drooping
    final leftArm = Path()
      ..moveTo(cx - 21, size.height * 0.56)
      ..quadraticBezierTo(
          cx - 38, size.height * 0.66, cx - 32, size.height * 0.75);
    canvas.drawPath(
        leftArm,
        Paint()
          ..color = teal.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);

    final rightArm = Path()
      ..moveTo(cx + 21, size.height * 0.56)
      ..quadraticBezierTo(
          cx + 38, size.height * 0.66, cx + 32, size.height * 0.75);
    canvas.drawPath(
        rightArm,
        Paint()
          ..color = teal.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);

    // Legs
    canvas.drawLine(
        Offset(cx - 10, size.height * 0.84),
        Offset(cx - 13, size.height * 0.97),
        Paint()
          ..color = teal.color
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);
    canvas.drawLine(
        Offset(cx + 10, size.height * 0.84),
        Offset(cx + 13, size.height * 0.97),
        Paint()
          ..color = teal.color
          ..strokeWidth = 10
          ..strokeCap = StrokeCap.round);
  }

  void _drawTiredEye(Canvas canvas, Offset center, Paint paint) {
    // Half-closed eye = a short horizontal ellipse with a flat top
    canvas.drawArc(
        Rect.fromCenter(center: center, width: 10, height: 8),
        0,
        math.pi,
        false,
        Paint()
          ..color = paint.color
          ..style = PaintingStyle.fill);
    // Eyelid line
    canvas.drawLine(
        Offset(center.dx - 5, center.dy),
        Offset(center.dx + 5, center.dy),
        Paint()
          ..color = paint.color
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_ExhaustedBrainyPainter old) => false;
}