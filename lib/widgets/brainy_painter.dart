// lib/features/mascot/brainy_painter.dart
//
// BrainyPainter — draws the full Brainy mascot as seen on the dashboard:
//   • Round teal head with shine highlight and visor band
//   • Large happy eyes with pupils and white shine dots
//   • Wide smile
//   • Dark-teal square torso with rounded corners
//   • Number dumbbell bar held across arms (shows "5" and "3" weights)
//   • Short teal legs
//
// The painter is stateless — all animation (idle bob, etc.) is applied
// externally via Transform.translate in the view layer.
//
// Usage:
//   SizedBox(
//     width: 160,
//     height: 170,
//     child: CustomPaint(painter: BrainyPainter()),
//   )

import 'dart:math' as math;
import 'package:flutter/material.dart';

class BrainyPainter extends CustomPainter {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const Color _teal       = Color(0xFF00C896);   // main body colour
  static const Color _tealLight  = Color(0xFF4DDBB0);   // highlight / shine
  static const Color _tealDark   = Color(0xFF007A5E);   // shadow / depth
  static const Color _bodyDark   = Color(0xFF0D3B2E);   // torso + limbs
  static const Color _eyeWhite   = Color(0xFFFFFFFF);
  static const Color _pupil      = Color(0xFF003D30);
  static const Color _weightBar  = Color(0xFF005C46);   // dumbbell bar
  static const Color _weightPlate= Color(0xFF007A5E);   // dumbbell ends
  static const Color _numberText = Color(0xFF00C896);   // "5" and "3" on weights

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // All coordinates expressed as fractions so the painter scales to any
    // SizedBox you drop it into.

    _drawLegs(canvas, w, h);
    _drawTorso(canvas, w, h);
    _drawArmsAndDumbbell(canvas, w, h);
    _drawHead(canvas, w, h);
  }

  // ── Legs ───────────────────────────────────────────────────────────────────
  void _drawLegs(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = _bodyDark
      ..strokeWidth = w * 0.095
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left leg — slight outward splay
    canvas.drawLine(
      Offset(w * 0.40, h * 0.81),
      Offset(w * 0.33, h * 0.97),
      paint,
    );
    // Right leg
    canvas.drawLine(
      Offset(w * 0.60, h * 0.81),
      Offset(w * 0.67, h * 0.97),
      paint,
    );

    // Foot caps (slightly wider rounded end)
    final footPaint = Paint()
      ..color = _bodyDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.33, h * 0.97), w * 0.055, footPaint);
    canvas.drawCircle(Offset(w * 0.67, h * 0.97), w * 0.055, footPaint);
  }

  // ── Torso ──────────────────────────────────────────────────────────────────
  void _drawTorso(Canvas canvas, double w, double h) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.69),
        width:  w * 0.38,
        height: h * 0.22,
      ),
      Radius.circular(w * 0.07),
    );

    // Base fill
    canvas.drawRRect(rect, Paint()..color = _bodyDark);

    // Subtle inner highlight (top edge glow)
    final shineRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        w * 0.315, h * 0.579,
        w * 0.37,  h * 0.03,
      ),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(
      shineRect,
      Paint()
        ..color = _teal.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // ── Arms + dumbbell ────────────────────────────────────────────────────────
  void _drawArmsAndDumbbell(Canvas canvas, double w, double h) {
    final armPaint = Paint()
      ..color = _bodyDark
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // ── Left arm: shoulder → hand holding bar ──
    final leftShoulder = Offset(w * 0.315, h * 0.63);
    final leftHand     = Offset(w * 0.14,  h * 0.61);
    canvas.drawLine(leftShoulder, leftHand, armPaint);

    // ── Right arm ──
    final rightShoulder = Offset(w * 0.685, h * 0.63);
    final rightHand     = Offset(w * 0.86,  h * 0.61);
    canvas.drawLine(rightShoulder, rightHand, armPaint);

    // ── Dumbbell bar ──────────────────────────────────────────────────────
    final barY = h * 0.595;

    // Bar rod
    canvas.drawLine(
      Offset(w * 0.10, barY),
      Offset(w * 0.90, barY),
      Paint()
        ..color = _weightBar
        ..strokeWidth = h * 0.025
        ..strokeCap = StrokeCap.round,
    );

    // Left weight plate
    _drawWeightPlate(canvas, Offset(w * 0.115, barY), w * 0.11, h * 0.075, '5');

    // Right weight plate
    _drawWeightPlate(canvas, Offset(w * 0.885, barY), w * 0.11, h * 0.075, '3');
  }

  void _drawWeightPlate(
      Canvas canvas, Offset centre, double rx, double ry, String label) {
    // Outer plate
    canvas.drawOval(
      Rect.fromCenter(center: centre, width: rx * 2, height: ry * 2),
      Paint()..color = _weightPlate,
    );

    // Inner recess ring
    canvas.drawOval(
      Rect.fromCenter(center: centre, width: rx * 1.35, height: ry * 1.35),
      Paint()
        ..color = _weightBar
        ..style = PaintingStyle.stroke
        ..strokeWidth = rx * 0.18,
    );

    // Number label
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: _numberText,
          fontSize: rx * 1.0,
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(centre.dx - tp.width / 2, centre.dy - tp.height / 2),
    );
  }

  // ── Head ───────────────────────────────────────────────────────────────────
  void _drawHead(Canvas canvas, double w, double h) {
    final cx    = w * 0.50;
    final cy    = h * 0.30;
    final r     = w * 0.34;

    // ── Outer glow / aura ──
    canvas.drawCircle(
      Offset(cx, cy),
      r * 1.12,
      Paint()
        ..color = _teal.withOpacity(0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // ── Main head sphere ──
    final headGradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.35),
        radius: 0.85,
        colors: [_tealLight, _teal, _tealDark],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, headGradientPaint);

    // ── Visor band (the horizontal dark stripe across mid-head) ──
    final visorRect = Rect.fromCenter(
      center: Offset(cx, cy + r * 0.02),
      width:  r * 2.0,
      height: r * 0.30,
    );
    // Clip to head circle so band doesn't bleed outside
    canvas.save();
    canvas.clipPath(Path()..addOval(
        Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    canvas.drawRect(visorRect, Paint()..color = _bodyDark.withOpacity(0.55));
    canvas.restore();

    // ── Shine highlight (top-left crescent) ──
    canvas.drawCircle(
      Offset(cx - r * 0.28, cy - r * 0.30),
      r * 0.28,
      Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Smaller specular dot
    canvas.drawCircle(
      Offset(cx - r * 0.32, cy - r * 0.34),
      r * 0.09,
      Paint()..color = Colors.white.withOpacity(0.55),
    );

    // ── Eyes ──
    _drawEye(canvas, Offset(cx - r * 0.30, cy - r * 0.04), r * 0.20);
    _drawEye(canvas, Offset(cx + r * 0.30, cy - r * 0.04), r * 0.20);

    // ── Smile ──
    _drawSmile(canvas, cx, cy, r);

    // ── Antenna nub (small dome on top) ──
    _drawAntenna(canvas, cx, cy, r);
  }

  void _drawEye(Canvas canvas, Offset centre, double r) {
    // White sclera
    canvas.drawCircle(centre, r, Paint()..color = _eyeWhite);

    // Pupil (slightly off-centre upward for alert look)
    canvas.drawCircle(
      Offset(centre.dx, centre.dy - r * 0.08),
      r * 0.56,
      Paint()..color = _pupil,
    );

    // Pupil highlight
    canvas.drawCircle(
      Offset(centre.dx + r * 0.22, centre.dy - r * 0.28),
      r * 0.22,
      Paint()..color = Colors.white,
    );

    // Subtle eye rim
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..color = _tealDark.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12,
    );
  }

  void _drawSmile(Canvas canvas, double cx, double cy, double r) {
    final path = Path();
    final startX = cx - r * 0.30;
    final startY = cy + r * 0.30;
    final endX   = cx + r * 0.30;
    final endY   = cy + r * 0.30;
    final cpY    = cy + r * 0.54; // control point pulls smile down

    path.moveTo(startX, startY);
    path.quadraticBezierTo(cx, cpY, endX, endY);

    canvas.drawPath(
      path,
      Paint()
        ..color = _pupil
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.18
        ..strokeCap = StrokeCap.round,
    );

    // Inner smile fill (makes it look like an open happy mouth)
    final mouthFill = Path();
    mouthFill.moveTo(startX, startY);
    mouthFill.quadraticBezierTo(cx, cpY, endX, endY);
    mouthFill.lineTo(endX, endY - r * 0.04);
    mouthFill.quadraticBezierTo(cx, cpY - r * 0.10, startX, startY - r * 0.04);
    mouthFill.close();
    canvas.drawPath(mouthFill, Paint()..color = _pupil.withOpacity(0.5));

    // Cheek blush spots
    final blushPaint = Paint()
      ..color = const Color(0xFFFF8A65).withOpacity(0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx - r * 0.46, cy + r * 0.28),
          width: r * 0.40,
          height: r * 0.22),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx + r * 0.46, cy + r * 0.28),
          width: r * 0.40,
          height: r * 0.22),
      blushPaint,
    );
  }

  void _drawAntenna(Canvas canvas, double cx, double cy, double r) {
    // Short stem
    canvas.drawLine(
      Offset(cx, cy - r),
      Offset(cx, cy - r * 1.18),
      Paint()
        ..color = _tealDark
        ..strokeWidth = r * 0.10
        ..strokeCap = StrokeCap.round,
    );

    // Top dome
    canvas.drawCircle(
      Offset(cx, cy - r * 1.22),
      r * 0.11,
      Paint()..color = _tealDark,
    );
    // Dome shine
    canvas.drawCircle(
      Offset(cx - r * 0.03, cy - r * 1.26),
      r * 0.045,
      Paint()..color = _tealLight.withOpacity(0.7),
    );
  }

  @override
  bool shouldRepaint(BrainyPainter oldDelegate) => false;
}
