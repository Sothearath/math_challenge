// lib/views/game_map_view.dart
//
// Duolingo-inspired, fully gamified map screen.
// Requires: GameMapController, StreakController (both injected before use).

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/game_map_controller.dart';
import '../controllers/streak_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';
import '../widgets/chunky_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Zone metadata: per-level colour, symbol pattern, path colour
// ─────────────────────────────────────────────────────────────────────────────

class _ZoneMeta {
  final Color primary;
  final Color secondary;   // path shadow / darker tone
  final Color bgFrom;      // zone card gradient top
  final Color bgTo;        // zone card gradient bottom
  final String symbol;     // repeated texture glyph
  final String zoneName;

  const _ZoneMeta({
    required this.primary,
    required this.secondary,
    required this.bgFrom,
    required this.bgTo,
    required this.symbol,
    required this.zoneName,
  });
}

const List<_ZoneMeta> _zones = [
  _ZoneMeta(
    primary: Color(0xFF4ADE80), secondary: Color(0xFF16A34A),
    bgFrom: Color(0xFF0D2416), bgTo: Color(0xFF0A1F12),
    symbol: '+', zoneName: 'Addition Zone',
  ),
  _ZoneMeta(
    primary: Color(0xFFFBBF24), secondary: Color(0xFFD97706),
    bgFrom: Color(0xFF221A07), bgTo: Color(0xFF1A1305),
    symbol: '−', zoneName: 'Subtraction Zone',
  ),
  _ZoneMeta(
    primary: Color(0xFF38BDF8), secondary: Color(0xFF0369A1),
    bgFrom: Color(0xFF071B26), bgTo: Color(0xFF051520),
    symbol: '±', zoneName: 'Mixed Zone',
  ),
  _ZoneMeta(
    primary: Color(0xFFCE82FF), secondary: Color(0xFF7E22CE),
    bgFrom: Color(0xFF160D22), bgTo: Color(0xFF10081A),
    symbol: '×', zoneName: 'Multiply Zone',
  ),
  _ZoneMeta(
    primary: Color(0xFFFF6B6B), secondary: Color(0xFFB91C1C),
    bgFrom: Color(0xFF210D0D), bgTo: Color(0xFF1A0808),
    symbol: '÷', zoneName: 'Division Zone',
  ),
  _ZoneMeta(
    primary: Color(0xFFFFD700), secondary: Color(0xFFB45309),
    bgFrom: Color(0xFF211A04), bgTo: Color(0xFF1A1503),
    symbol: '∞', zoneName: 'Grand Master',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  Zigzag X offsets for the winding path (indices 0-4 for 5 stages)
// ─────────────────────────────────────────────────────────────────────────────
const List<double> _zigzag = [0.0, 0.38, 0.0, -0.38, 0.0];

// ─────────────────────────────────────────────────────────────────────────────
//  Root view
// ─────────────────────────────────────────────────────────────────────────────

class GameMapView extends StatelessWidget {
  const GameMapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazily put GameMapController if not already registered
    if (!Get.isRegistered<GameMapController>()) {
      Get.put(GameMapController());
    }
    final mapCtrl   = Get.find<GameMapController>();
    final streak    = Get.find<StreakController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode;
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── 1. Gradient background ──────────────────────────────
            _GradientBackground(isDark: isDark),
            // ── 2. Parallax floating shapes ─────────────────────────
            Obx(() => _ParallaxShapes(
              scrollOffset: mapCtrl.scrollOffset.value,
              isDark: isDark,
            )),
            // ── 3. Scrollable content ───────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _TopBar(streak: streak, isDark: isDark, themeCtrl: themeCtrl),
                  Expanded(
                    child: _MapScroll(
                      mapCtrl: mapCtrl,
                      streak: streak,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Background gradient (deep indigo → dark blue)
// ─────────────────────────────────────────────────────────────────────────────

class _GradientBackground extends StatelessWidget {
  final bool isDark;
  const _GradientBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF0B0D1A), Color(0xFF111426), Color(0xFF0D1020)]
              : const [Color(0xFFE8F4FF), Color(0xFFF0F8FF), Color(0xFFE5F0FB)],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Parallax floating geometric shapes
// ─────────────────────────────────────────────────────────────────────────────

class _ParallaxShapes extends StatelessWidget {
  final double scrollOffset;
  final bool isDark;
  const _ParallaxShapes({required this.scrollOffset, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    // parallax: shapes move at 15% of scroll speed
    final dy = scrollOffset * 0.15;

    final color = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.indigo.withOpacity(0.04);

    return IgnorePointer(
      child: ClipRect(
        child: Stack(
          children: [
            _floatShape(w * 0.12, h * 0.08 - dy,       80,  color, 0),
            _floatShape(w * 0.78, h * 0.15 - dy * 0.8, 56,  color, 1),
            _floatShape(w * 0.55, h * 0.32 - dy * 1.2, 100, color, 2),
            _floatShape(w * 0.08, h * 0.50 - dy * 0.6, 64,  color, 3),
            _floatShape(w * 0.88, h * 0.44 - dy,       48,  color, 4),
            _floatShape(w * 0.35, h * 0.65 - dy * 1.1, 88,  color, 5),
            _floatShape(w * 0.72, h * 0.72 - dy * 0.7, 60,  color, 6),
            _floatShape(w * 0.20, h * 0.82 - dy * 0.9, 72,  color, 7),
          ],
        ),
      ),
    );
  }

  Widget _floatShape(double x, double y, double size, Color col, int variant) {
    return Positioned(
      left: x, top: y,
      child: variant % 3 == 0
          ? _hexagon(size, col)
          : variant % 3 == 1
              ? _circle(size, col)
              : _diamond(size, col),
    );
  }

  Widget _hexagon(double size, Color col) => CustomPaint(
    size: Size(size, size),
    painter: _HexPainter(col),
  );

  Widget _circle(double size, Color col) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: col, width: 2),
    ),
  );

  Widget _diamond(double size, Color col) => Transform.rotate(
    angle: math.pi / 4,
    child: Container(
      width: size * 0.7, height: size * 0.7,
      decoration: BoxDecoration(
        border: Border.all(color: col, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class _HexPainter extends CustomPainter {
  final Color color;
  _HexPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HexPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Top bar: streak + daily ring + theme toggle
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final StreakController streak;
  final bool isDark;
  final ThemeController themeCtrl;
  const _TopBar({required this.streak, required this.isDark, required this.themeCtrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // App title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Color(0xFF4ADE80), Color(0xFF22D3EE)],
                ).createShader(b),
                child: Text('MATH',
                  style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w900,
                    letterSpacing: -0.5, height: 1,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  )),
              ),
              Text('CHALLENGE',
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                  color: isDark ? Colors.white38 : Colors.black38,
                )),
            ],
          ),
          const Spacer(),
          // Streak flame badge
          Obx(() => _StreakPill(days: streak.streakDays.value, isDark: isDark)),
          const SizedBox(width: 10),
          // Daily goal ring
          Obx(() => _GoalRing(progress: streak.dailyProgress, isDark: isDark)),
          const SizedBox(width: 10),
          // Theme toggle
          GestureDetector(
            onTap: themeCtrl.toggleTheme,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12),
              ),
              child: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                size: 18,
                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFF6366F1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakPill extends StatelessWidget {
  final int days;
  final bool isDark;
  const _StreakPill({required this.days, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF6B35).withOpacity(0.4),
              blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 4),
          Text('$days',
            style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w900,
              color: Colors.white, letterSpacing: -0.5,
            )),
        ],
      ),
    );
  }
}

class _GoalRing extends StatelessWidget {
  final double progress;
  final bool isDark;
  const _GoalRing({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42, height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF4ADE80)),
            strokeCap: StrokeCap.round,
          ),
          Text('${(progress * 100).toInt()}',
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w900,
              color: isDark ? Colors.white70 : Colors.black54,
            )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Scrollable map content
// ─────────────────────────────────────────────────────────────────────────────

class _MapScroll extends StatelessWidget {
  final GameMapController mapCtrl;
  final StreakController streak;
  final bool isDark;

  const _MapScroll({required this.mapCtrl, required this.streak, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: mapCtrl.scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 48),
      itemCount: kLevels.length,
      itemBuilder: (ctx, i) => _ZoneSection(
        level: kLevels[i],
        zone: _zones[i % _zones.length],
        mapCtrl: mapCtrl,
        streak: streak,
        isDark: isDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Zone section: header card + winding path with nodes
// ─────────────────────────────────────────────────────────────────────────────

class _ZoneSection extends StatelessWidget {
  final GameLevel level;
  final _ZoneMeta zone;
  final GameMapController mapCtrl;
  final StreakController streak;
  final bool isDark;

  const _ZoneSection({
    required this.level, required this.zone, required this.mapCtrl,
    required this.streak, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Zone header card ───────────────────────────────────────
        _ZoneHeaderCard(level: level, zone: zone, isDark: isDark),
        // ── Winding path with nodes ────────────────────────────────
        _ZonePath(
          level: level,
          zone: zone,
          mapCtrl: mapCtrl,
          streak: streak,
          isDark: isDark,
        ),
        // Obx(() => _ZonePath(
        //   level: level,
        //   zone: zone,
        //   mapCtrl: mapCtrl,
        //   streak: streak,
        //   isDark: isDark,
        // )),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Zone header: 3-D pressed card with repeating symbol texture
// ─────────────────────────────────────────────────────────────────────────────

class _ZoneHeaderCard extends StatelessWidget {
  final GameLevel level;
  final _ZoneMeta zone;
  final bool isDark;
  const _ZoneHeaderCard({required this.level, required this.zone, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          // 3-D pressed look: light top-left inner light, shadow bottom-right
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [zone.bgFrom, zone.bgTo],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: zone.primary.withOpacity(0.25), width: 1.5),
          boxShadow: [
            // Outer glow
            BoxShadow(color: zone.primary.withOpacity(0.15),
                blurRadius: 20, offset: const Offset(0, 6)),
            // Inner top highlight (simulated via paint)
            BoxShadow(color: Colors.white.withOpacity(0.04),
                blurRadius: 1, offset: const Offset(0, -1)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Texture: repeating math symbols
              Positioned.fill(
                child: CustomPaint(
                  painter: _SymbolTexturePainter(
                    symbol: zone.symbol,
                    color: zone.primary.withOpacity(0.07),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Zone icon orb (mini)
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [zone.primary.withOpacity(0.3), Colors.transparent],
                        ),
                        border: Border.all(color: zone.primary.withOpacity(0.5), width: 2),
                      ),
                      child: Center(
                        child: Text(level.emoji,
                          style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(zone.zoneName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w800,
                              letterSpacing: 2.5,
                              color: zone.primary.withOpacity(0.7),
                            )),
                          const SizedBox(height: 3),
                          Text(level.title,
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900,
                              color: Colors.white, letterSpacing: -0.3,
                            )),
                          Text(level.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            )),
                        ],
                      ),
                    ),
                    // Stage progress dots
                    _StageDots(level: level, zone: zone),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageDots extends StatelessWidget {
  final GameLevel level;
  final _ZoneMeta zone;
  const _StageDots({required this.level, required this.zone});

  @override
  Widget build(BuildContext context) {
    final streak = Get.find<StreakController>();
    return Column(
      children: List.generate(5, (i) {
        final done = streak.isStageCompleted(level.index, i);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? zone.primary : Colors.white.withOpacity(0.15),
              boxShadow: done ? [
                BoxShadow(color: zone.primary.withOpacity(0.6), blurRadius: 4),
              ] : [],
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Zone path: custom-painted winding trail + stage nodes
// ─────────────────────────────────────────────────────────────────────────────

class _ZonePath extends StatelessWidget {
  final GameLevel level;
  final _ZoneMeta zone;
  final GameMapController mapCtrl;
  final StreakController streak;
  final bool isDark;

  const _ZonePath({
    required this.level, required this.zone, required this.mapCtrl,
    required this.streak, required this.isDark,
  });

  static const double _nodeStep   = 100.0;
  static const double _nodeRadius = 34.0;
  static const double _pathHeight = 5 * _nodeStep + 20.0;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final cx = sw / 2;

    // Pre-compute node centres
    final centres = List.generate(5, (i) {
      final dx = _zigzag[i] * (cx * 0.48);
      return Offset(cx + dx, 20 + i * _nodeStep + _nodeRadius);
    });

    return SizedBox(
      width: sw,
      height: _pathHeight + _nodeRadius * 2,
      child: Stack(
        children: [
          // ── Winding path painter ──────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _WindingPathPainter(
                centres: centres,
                primaryColor: zone.primary,
                shadowColor: zone.secondary,
                completedCount: _completedCount(),
              ),
            ),
          ),
          // ── Stage nodes ───────────────────────────────────────
          ...List.generate(5, (i) {
            final centre = centres[i];
            final completed = streak.isStageCompleted(level.index, i);
            final unlocked  = streak.isStageUnlocked(level.index, i);
            final isFirst   = level.index == 0 && i == 0;
            final isActive  = unlocked && !completed;

            return Positioned(
              left:  centre.dx - _nodeRadius,
              top:   centre.dy - _nodeRadius,
              width: _nodeRadius * 2,
              height: _nodeRadius * 2,
              child: _StageNode(
                levelIdx: level.index,
                stageIdx: i,
                stage: level.stages[i],
                zone: zone,
                completed: completed,
                unlocked: unlocked,
                isActive: isActive,
                isPulse: isFirst || isActive,
                mapCtrl: mapCtrl,
                streak: streak,
                isDark: isDark,
              ),
              // Obx(() => _StageNode(
              //   levelIdx: level.index,
              //   stageIdx: i,
              //   stage: level.stages[i],
              //   zone: zone,
              //   completed: completed,
              //   unlocked: unlocked,
              //   isActive: isActive,
              //   isPulse: isFirst || isActive,
              //   mapCtrl: mapCtrl,
              //   streak: streak,
              //   isDark: isDark,
              // )),
            );
          }),
        ],
      ),
    );
  }

  int _completedCount() {
    int c = 0;
    for (int i = 0; i < 5; i++) {
      if (streak.isStageCompleted(level.index, i)) c++;
    }
    return c;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Winding path painter — thick, rounded, coloured trail
// ─────────────────────────────────────────────────────────────────────────────

class _WindingPathPainter extends CustomPainter {
  final List<Offset> centres;
  final Color primaryColor;
  final Color shadowColor;
  final int completedCount;

  const _WindingPathPainter({
    required this.centres,
    required this.primaryColor,
    required this.shadowColor,
    required this.completedCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (centres.length < 2) return;

    // Build the full bezier spine
    final spinePath = _buildSpine();

    // ── Shadow / emboss layer ──────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = shadowColor.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(spinePath, shadowPaint);

    // ── Unfinished (dim) track ─────────────────────────────────────────────
    final dimPaint = Paint()
      ..color = primaryColor.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(spinePath, dimPaint);

    // ── Dashed centre line (texture) ───────────────────────────────────────
    _drawDashes(canvas, spinePath, primaryColor.withOpacity(0.12));

    // ── Completed portion ─────────────────────────────────────────────────
    if (completedCount > 0) {
      final completedPath = _buildPartialSpine(completedCount);

      final glowPaint = Paint()
        ..color = primaryColor.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(completedPath, glowPaint);

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(completedPath, fillPaint);

      // Bright centre highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(completedPath, highlightPaint);
    }
  }

  Path _buildSpine() {
    final path = Path();
    path.moveTo(centres[0].dx, centres[0].dy);
    for (int i = 0; i < centres.length - 1; i++) {
      final p1 = centres[i];
      final p2 = centres[i + 1];
      final cp1 = Offset(p1.dx, p1.dy + (p2.dy - p1.dy) * 0.4);
      final cp2 = Offset(p2.dx, p2.dy - (p2.dy - p1.dy) * 0.4);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  Path _buildPartialSpine(int segmentsComplete) {
    final path = Path();
    path.moveTo(centres[0].dx, centres[0].dy);
    final end = math.min(segmentsComplete, centres.length - 1);
    for (int i = 0; i < end; i++) {
      final p1 = centres[i];
      final p2 = centres[i + 1];
      final cp1 = Offset(p1.dx, p1.dy + (p2.dy - p1.dy) * 0.4);
      final cp2 = Offset(p2.dx, p2.dy - (p2.dy - p1.dy) * 0.4);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  void _drawDashes(Canvas canvas, Path path, Color color) {
    final metrics = path.computeMetrics();
    const dash = 6.0, gap = 10.0;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end   = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_WindingPathPainter old) =>
      old.completedCount != completedCount || old.primaryColor != primaryColor;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Stage node: active orb (pulsing) / completed star / locked padlock
// ─────────────────────────────────────────────────────────────────────────────

class _StageNode extends StatelessWidget {
  final int levelIdx, stageIdx;
  final LevelStage stage;
  final _ZoneMeta zone;
  final bool completed, unlocked, isActive, isPulse;
  final GameMapController mapCtrl;
  final StreakController streak;
  final bool isDark;

  const _StageNode({
    required this.levelIdx, required this.stageIdx, required this.stage,
    required this.zone, required this.completed, required this.unlocked,
    required this.isActive, required this.isPulse, required this.mapCtrl,
    required this.streak, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final shaking = mapCtrl.isShaking(levelIdx, stageIdx);

    return GestureDetector(
      onTap: () => _onTap(context),
      child: _ShakeWrapper(
        shaking: shaking,
        child: isActive || completed
            ? (isPulse
                ? _PulsingOrb(zone: zone, completed: completed,
                    stageIdx: stageIdx, mapCtrl: mapCtrl)
                : _ActiveOrb(zone: zone, completed: completed, stageIdx: stageIdx))
            : _LockedOrb(zone: zone),
      ),
    );
  }

  void _onTap(BuildContext context) {
    if (!unlocked) {
      mapCtrl.shakeNode(levelIdx, stageIdx);
      Get.snackbar(
        '🔒 Locked!',
        'Complete the previous stage to unlock.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1C1E2A),
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.lock_rounded, color: Color(0xFFFBBF24)),
      );
      return;
    }
    // Show mode picker
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _ModePicker(
        stage: stage,
        zone: zone,
        isDark: isDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pulsing orb (active stage with heartbeat animation)
// ─────────────────────────────────────────────────────────────────────────────

class _PulsingOrb extends StatelessWidget {
  final _ZoneMeta zone;
  final bool completed;
  final int stageIdx;
  final GameMapController mapCtrl;

  const _PulsingOrb({required this.zone, required this.completed,
      required this.stageIdx, required this.mapCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mapCtrl.pulseCtrl,
      builder: (_, __) {
        final scale = mapCtrl.pulseAnim.value;
        final glow  = mapCtrl.glowAnim.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  zone.primary.withOpacity(0.9),
                  zone.primary.withOpacity(0.55),
                ],
                stops: const [0.4, 1.0],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2.5),
              boxShadow: [
                BoxShadow(color: zone.primary.withOpacity(glow),
                    blurRadius: 28, spreadRadius: 4),
                BoxShadow(color: zone.primary.withOpacity(glow * 0.4),
                    blurRadius: 50, spreadRadius: 10),
              ],
            ),
            child: Center(
              child: completed
                  ? const Icon(Icons.star_rounded, color: Colors.white, size: 32)
                  : Text('${stageIdx + 1}',
                      style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: -1,
                      )),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Active (unlocked, non-pulsing) orb
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveOrb extends StatelessWidget {
  final _ZoneMeta zone;
  final bool completed;
  final int stageIdx;

  const _ActiveOrb({required this.zone, required this.completed, required this.stageIdx});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68, height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [zone.primary.withOpacity(0.75), zone.primary.withOpacity(0.4)],
          stops: const [0.35, 1.0],
        ),
        border: Border.all(color: zone.primary.withOpacity(0.7), width: 2.5),
        boxShadow: [
          BoxShadow(color: zone.primary.withOpacity(0.35), blurRadius: 16, spreadRadius: 2),
        ],
      ),
      child: Center(
        child: completed
            ? const Icon(Icons.star_rounded, color: Colors.white, size: 30)
            : Text('${stageIdx + 1}',
                style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900,
                  color: Colors.white, letterSpacing: -1,
                )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Locked orb — desaturated version + cartoonish brass padlock
// ─────────────────────────────────────────────────────────────────────────────

class _LockedOrb extends StatelessWidget {
  final _ZoneMeta zone;
  const _LockedOrb({required this.zone});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68, height: 68,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Desaturated base orb
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E2030),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 2),
            ),
            child: Center(
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: zone.primary.withOpacity(0.12),
                ),
              ),
            ),
          ),
          // Brass padlock sitting on top-right
          Positioned(
            right: -4, bottom: -4,
            child: _BrassPadlock(),
          ),
        ],
      ),
    );
  }
}

class _BrassPadlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30, height: 34,
      child: CustomPaint(painter: _PadlockPainter()),
    );
  }
}

class _PadlockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bodyColor  = const Color(0xFFB8860B);
    final shineColor = const Color(0xFFFFD700);
    final shadowCol  = const Color(0xFF7A5A00);
    final darkCol    = const Color(0xFF2D1F00);

    // ── Body (rounded rect) ───────────────────────────────────────────────
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, size.height * 0.38, size.width - 4, size.height * 0.58),
      const Radius.circular(6),
    );
    // Shadow
    canvas.drawRRect(
      bodyRect.shift(const Offset(0, 2)),
      Paint()..color = shadowCol,
    );
    // Body fill gradient
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [shineColor, bodyColor, shadowCol],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bodyRect.outerRect),
    );
    // Keyhole
    final khCx = size.width / 2;
    final khCy = size.height * 0.66;
    canvas.drawCircle(Offset(khCx, khCy - 2), 4, Paint()..color = darkCol);
    final kholePath = Path()
      ..moveTo(khCx - 2.5, khCy)
      ..lineTo(khCx + 2.5, khCy)
      ..lineTo(khCx + 2, khCy + 6)
      ..lineTo(khCx - 2, khCy + 6)
      ..close();
    canvas.drawPath(kholePath, Paint()..color = darkCol);

    // ── Shackle (arch) ────────────────────────────────────────────────────
    final shacklePaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    final shackleGlow = Paint()
      ..color = shineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final archRect = Rect.fromLTWH(
      size.width * 0.2, 1,
      size.width * 0.6, size.height * 0.42,
    );
    canvas.drawArc(archRect, math.pi, math.pi, false, shacklePaint);
    canvas.drawArc(archRect, math.pi, math.pi, false, shackleGlow);
  }

  @override
  bool shouldRepaint(_PadlockPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shake wrapper — translates the child left-right on trigger
// ─────────────────────────────────────────────────────────────────────────────

class _ShakeWrapper extends StatefulWidget {
  final bool shaking;
  final Widget child;
  const _ShakeWrapper({required this.shaking, required this.child});

  @override
  State<_ShakeWrapper> createState() => _ShakeWrapperState();
}

class _ShakeWrapperState extends State<_ShakeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _anim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0),   weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_ShakeWrapper old) {
    super.didUpdateWidget(old);
    if (widget.shaking && !old.shaking) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: Offset(_anim.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Symbol texture painter — repeating math glyphs as background
// ─────────────────────────────────────────────────────────────────────────────

class _SymbolTexturePainter extends CustomPainter {
  final String symbol;
  final Color color;
  _SymbolTexturePainter({required this.symbol, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    const step = 44.0;

    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step / 2; x < size.width + step; x += step) {
        final offset = (y ~/ step).isEven ? 0.0 : step / 2;
        tp.text = TextSpan(
          text: symbol,
          style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w900,
            color: color,
          ),
        );
        tp.layout();
        tp.paint(canvas, Offset(x + offset, y));
      }
    }
  }

  @override
  bool shouldRepaint(_SymbolTexturePainter old) =>
      old.symbol != symbol || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Mode picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ModePicker extends StatelessWidget {
  final LevelStage stage;
  final _ZoneMeta zone;
  final bool isDark;

  const _ModePicker({required this.stage, required this.zone, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final game = Get.find<GameController>();

    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [zone.bgFrom, zone.bgTo],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: zone.primary.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            )),
          const SizedBox(height: 20),
          // Stage info
          Text(stage.title,
            style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900,
              color: Colors.white, letterSpacing: -0.5,
            )),
          const SizedBox(height: 4),
          Text('Answer ${stage.questionsRequired} questions to complete',
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 24),
          // Solo button
          ChunkyButton(
            label: 'Solo Practice',
            color: zone.primary,
            shadowColor: zone.secondary,
            textColor: Colors.white,
            icon: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
            onTap: () {
              Get.back();
              game.setMode(GameMode.singlePlayer);
              game.startStage(stage);
              Get.toNamed('/game');
            },
          ),
          const SizedBox(height: 12),
          // VS Machine button
          ChunkyButton(
            label: 'VS Machine',
            color: const Color(0xFF1CB0F6),
            shadowColor: const Color(0xFF0A91D4),
            textColor: Colors.white,
            icon: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
            onTap: () {
              Get.back();
              game.setMode(GameMode.vsMachine);
              game.startStage(stage);
              Get.toNamed('/game');
            },
          ),
        ],
      ),
    );
  }
}
