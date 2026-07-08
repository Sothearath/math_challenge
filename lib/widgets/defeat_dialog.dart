// lib/features/game/widgets/defeat_dialog.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants.dart';
import '../bindings/app_bindings.dart';
import '../controllers/arithmetic_controller.dart';
import '../models/level_config.dart';
import '../theme/app_theme.dart';
import '../views/arithmetic_challenge_view.dart';

class DefeatDialog extends StatefulWidget {
  final LevelConfig currentLevel;
  final int remainingHearts;

  const DefeatDialog({
    super.key,
    required this.currentLevel,
    required this.remainingHearts,
  });

  @override
  State<DefeatDialog> createState() => _DefeatDialogState();
}

class _DefeatDialogState extends State<DefeatDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _shake;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0,   end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12,  end: -8),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8,  end: 8),   weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8,   end: 0),   weight: 1),
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
    final isDailyChallenge = widget.currentLevel.levelNumber == 0;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child: Transform.translate(offset: Offset(_shake.value, 0), child: child),
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(AppTheme.radiusDialog),
            border: Border.all(color: AppColors.heartDanger.withValues(alpha: 0.30)),
            boxShadow: [
              BoxShadow(
                color: AppColors.heartDanger.withValues(alpha: 0.18),
                blurRadius: 40,
                spreadRadius: 4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Danger header band ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.heartDanger.withValues(alpha: 0.22),
                      AppColors.darkCard,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 130,
                      child: CustomPaint(painter: _ExhaustedBrainyPainter()),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Close one! 😓',
                      style: GoogleFonts.nunito(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // ── Body — dark card surface ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  children: [
                    Text(
                      isDailyChallenge
                          ? (widget.remainingHearts <= 0
                          ? "You dropped to 0 hearts. Today's attempt has been locked out!"
                          : "Time's up! Today's attempt has been locked out!")
                          : "Let's rest the brain and try again.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(fontSize: 15, color: AppColors.mintDim, height: 1.4),
                    ),
                    const SizedBox(height: 28),

                    // ── Buttons Row ──
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Get.back();
                              Get.offAllNamed(Routes.dashboard);
                            },
                            child: Text(
                              isDailyChallenge ? 'Leave' : 'Rest',
                              style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.mintDim),
                            ),
                          ),
                        ),

                        // Clean Extracted Action Slot
                        if (!isDailyChallenge) ...[
                          const SizedBox(width: 12),
                          _buildTryAgainButton(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Extracted Try Again Action Button ───────────────────────────────────────
  Widget _buildTryAgainButton() {
    return Expanded(
      flex: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mint, AppColors.mintGlow],
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusKey),
          boxShadow: [
            BoxShadow(
              color: AppColors.mint.withValues(alpha: 0.40),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Get.back();
            if (Get.isRegistered<ArithmeticController>()) {
              Get.find<ArithmeticController>().loadNextLevel(widget.currentLevel);
            } else {
              Get.off(() => const ArithmeticChallengeView(), binding: GameBinding(), arguments: widget.currentLevel);
            }
          },
          child:Padding(
            padding: const EdgeInsets.symmetric(vertical: 14), child:  Center(
            child: Text(
              '🔄 Try Again',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white),
            ),
          ),)
        ),
      ),
    );
  }
}

// ── Exhausted Brainy painter ──────────────────────────────────────────────────
class _ExhaustedBrainyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal  = Paint()..color = AppColors.brainyBody;
    final dark  = Paint()..color = AppColors.darkBg;
    final sweat = Paint()..color = AppColors.gradientBottom.withValues(alpha: 0.80);

    final cx = size.width / 2;
    final hy = size.height * 0.30;

    canvas.drawCircle(Offset(cx, hy), 36,
        Paint()
          ..color = AppColors.heartDanger.withValues(alpha: 0.10)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));

    canvas.drawCircle(Offset(cx, hy), 32, teal);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, hy), radius: 32),
      math.pi + 0.3, math.pi - 0.6, false,
      Paint()
        ..color = AppColors.heartDanger
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );

    _drawTiredEye(canvas, Offset(cx - 10, hy + 2), dark);
    _drawTiredEye(canvas, Offset(cx + 10, hy + 2), dark);

    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 28, hy - 6), width: 6, height: 9), sweat);
    canvas.drawOval(
        Rect.fromCenter(center: Offset(cx + 34, hy + 4), width: 4, height: 7), sweat);

    canvas.drawPath(
      Path()
        ..moveTo(cx - 9, hy + 16)
        ..quadraticBezierTo(cx, hy + 12, cx + 9, hy + 16),
      Paint()
        ..color = AppColors.darkBg
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, size.height * 0.63), width: 42, height: 42),
        const Radius.circular(10),
      ),
      teal,
    );

    for (final path in [
      Path()
        ..moveTo(cx - 21, size.height * 0.56)
        ..quadraticBezierTo(cx - 38, size.height * 0.66, cx - 32, size.height * 0.75),
      Path()
        ..moveTo(cx + 21, size.height * 0.56)
        ..quadraticBezierTo(cx + 38, size.height * 0.66, cx + 32, size.height * 0.75),
    ]) {
      canvas.drawPath(path,
          Paint()
            ..color = AppColors.brainyBody
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round);
    }

    for (final pts in [
      [Offset(cx - 10, size.height * 0.84), Offset(cx - 13, size.height * 0.97)],
      [Offset(cx + 10, size.height * 0.84), Offset(cx + 13, size.height * 0.97)],
    ]) {
      canvas.drawLine(pts[0], pts[1],
          Paint()..color = AppColors.brainyBody..strokeWidth = 10..strokeCap = StrokeCap.round);
    }
  }

  void _drawTiredEye(Canvas canvas, Offset center, Paint paint) {
    canvas.drawArc(
      Rect.fromCenter(center: center, width: 10, height: 8),
      0, math.pi, false,
      Paint()..color = paint.color..style = PaintingStyle.fill,
    );
    canvas.drawLine(
      Offset(center.dx - 5, center.dy),
      Offset(center.dx + 5, center.dy),
      Paint()..color = paint.color..strokeWidth = 2.0..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ExhaustedBrainyPainter old) => false;
}