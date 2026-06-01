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

                      // Headline — cobalt on gradient
                      Text(
                        'Level Unlocked! 🎉',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cobalt,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Complexity badge — frosted glass pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.30),
                          borderRadius:
                          BorderRadius.circular(AppTheme.radiusBadge),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.55)),
                        ),
                        child: Text(
                          'Complexity increased to ${widget.newComplexity}%',
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

                      // Buttons row
                      Row(
                        children: [

                          // Dashboard — outlined mint
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Get.back();
                                Get.offAllNamed(Routes.dashboard);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.mintDim,
                                side: BorderSide(
                                    color: AppColors.darkDivider, width: 1.5),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusKey)),
                              ),
                              child: Text('Dashboard',
                                  style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mintDim)),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Next Level — mint gradient matching submit key
                          Expanded(
                            flex: 2,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [AppColors.mint, AppColors.mintGlow],
                                ),
                                borderRadius:
                                BorderRadius.circular(AppTheme.radiusKey),
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
                                borderRadius:
                                BorderRadius.circular(AppTheme.radiusKey),
                                child: InkWell(
                                  borderRadius:
                                  BorderRadius.circular(AppTheme.radiusKey),
                                  onTap: () {
                                    // First, safely close the open overlay alert dialog container
                                    Get.back();

                                    // Find the operational controller already in your memory pipeline
                                    if (Get.isRegistered<ArithmeticController>()) {
                                      final controller = Get.find<ArithmeticController>();

                                      // Call the optimized recycler method we added to update parameters
                                      controller.loadNextLevel(widget.nextLevel);
                                    } else {
                                      // Fallback: If for any reason the instance is missing, use your original hard reload pipeline[cite: 4]
                                      Get.off(
                                              () => const ArithmeticChallengeView(),
                                          binding: GameBinding(),
                                    arguments: widget.nextLevel,
                                    );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    child: Center(
                                      child: Text(
                                        '🚀 Next Level',
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
      width: 130,
      height: 130,
      child: CustomPaint(painter: _TrophyMascotPainter()),
    );
  }
}

class _TrophyMascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal  = Paint()..color = AppColors.brainyBody;
    final dark  = Paint()..color = AppColors.darkBg;
    final white = Paint()..color = Colors.white;
    final amber = Paint()..color = AppColors.sunflower;

    // White glow on gradient bg
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.28),
      40,
      Paint()
        ..color = Colors.white.withOpacity(0.20)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final cx = size.width / 2;

    // Head
    canvas.drawCircle(Offset(cx, size.height * 0.28), 34, teal);
    canvas.drawCircle(Offset(cx - 10, size.height * 0.20), 10,
        Paint()..color = Colors.white.withOpacity(0.20));

    // Eyes
    canvas.drawCircle(Offset(cx - 10, size.height * 0.26), 5, dark);
    canvas.drawCircle(Offset(cx + 10, size.height * 0.26), 5, dark);
    canvas.drawCircle(Offset(cx - 8, size.height * 0.245), 2, white);
    canvas.drawCircle(Offset(cx + 12, size.height * 0.245), 2, white);

    // Smile
    canvas.drawPath(
      Path()
        ..moveTo(cx - 10, size.height * 0.315)
        ..quadraticBezierTo(cx, size.height * 0.345, cx + 10, size.height * 0.315),
      Paint()
        ..color = AppColors.darkBg
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, size.height * 0.60), width: 44, height: 44),
        const Radius.circular(10),
      ),
      teal,
    );

    // Arms raised
    for (final path in [
      Path()
        ..moveTo(cx - 22, size.height * 0.55)
        ..quadraticBezierTo(cx - 44, size.height * 0.42, cx - 38, size.height * 0.36),
      Path()
        ..moveTo(cx + 22, size.height * 0.55)
        ..quadraticBezierTo(cx + 44, size.height * 0.42, cx + 38, size.height * 0.36),
    ]) {
      canvas.drawPath(path,
          Paint()
            ..color = AppColors.brainyBody
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10
            ..strokeCap = StrokeCap.round);
    }

    // Legs
    for (final pts in [
      [Offset(cx - 10, size.height * 0.82), Offset(cx - 14, size.height * 0.97)],
      [Offset(cx + 10, size.height * 0.82), Offset(cx + 14, size.height * 0.97)],
    ]) {
      canvas.drawLine(pts[0], pts[1],
          Paint()..color = AppColors.brainyBody..strokeWidth = 10..strokeCap = StrokeCap.round);
    }

    // ── Trophy ────────────────────────────────────────────────────────────────
    final top = Offset(cx, size.height * 0.10);

    // Sunflower glow
    canvas.drawCircle(top, 22,
        Paint()
          ..color = AppColors.sunflower.withOpacity(0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // Cup
    canvas.drawPath(
      Path()
        ..moveTo(top.dx - 16, top.dy - 10)
        ..lineTo(top.dx - 12, top.dy + 10)
        ..quadraticBezierTo(top.dx, top.dy + 16, top.dx + 12, top.dy + 10)
        ..lineTo(top.dx + 16, top.dy - 10)
        ..close(),
      amber,
    );

    // Handles
    for (final r in [
      Rect.fromCenter(center: Offset(top.dx - 14, top.dy - 2), width: 10, height: 12),
      Rect.fromCenter(center: Offset(top.dx + 14, top.dy - 2), width: 10, height: 12),
    ]) {
      canvas.drawArc(r, r.left < top.dx ? -1.5 : -1.6,
          r.left < top.dx ? 3.0 : -3.0, false,
          Paint()..color = AppColors.sunflower..style = PaintingStyle.stroke..strokeWidth = 3);
    }

    // Star on cup
    _drawStar(canvas, top, 7, amber);

    // Stem + base
    canvas.drawLine(Offset(top.dx, top.dy + 16), Offset(top.dx, top.dy + 22),
        Paint()..color = AppColors.sunflower..strokeWidth = 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(top.dx, top.dy + 25), width: 24, height: 6),
        const Radius.circular(3),
      ),
      amber,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final a1 = (i * 72 - 90) * 3.14159265 / 180;
      final a2 = (i * 72 + 36 - 90) * 3.14159265 / 180;
      final o = Offset(center.dx + r * _c(a1), center.dy + r * _s(a1));
      final n = Offset(center.dx + (r / 2.2) * _c(a2), center.dy + (r / 2.2) * _s(a2));
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
      path.lineTo(n.dx, n.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  double _c(double r) { double v=1,t=1; for(int n=1;n<=6;n++){t*=-r*r/((2*n-1)*(2*n));v+=t;} return v; }
  double _s(double r) { double v=r,t=r; for(int n=1;n<=6;n++){t*=-r*r/((2*n)*(2*n+1));v+=t;} return v; }

  @override
  bool shouldRepaint(_TrophyMascotPainter old) => false;
}