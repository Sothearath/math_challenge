// lib/features/game/painters/particle_burst_painter.dart
//
// Lightweight confetti/particle burst — NO external packages needed.
// Usage: wrap the submit button area in a Stack and overlay
// ParticleBurstOverlay, then call ParticleBurstOverlay.trigger() from
// the controller's particleBurstTick watcher.

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ── Particle data model ────────────────────────────────────────────────────────
class _Particle {
  late double x;       // normalised 0-1 relative to canvas size
  late double y;
  late double vx;      // velocity per frame
  late double vy;
  late double radius;
  late Color  color;
  late double rotation;
  late double rotSpeed;
  late double opacity;
  late bool   isRect;  // rect vs circle

  static final _rng = math.Random();
  static const _palette = [
    Color(0xFF00E676), // spring green
    Color(0xFF69F0AE), // light green
    Color(0xFFFFFFFF), // white
    Color(0xFFFFEB3B), // yellow
    Color(0xFF40C4FF), // sky blue
    Color(0xFFFF6D00), // orange accent
  ];

  _Particle.spawn({required double originX, required double originY}) {
    final angle  = _rng.nextDouble() * math.pi * 2;
    final speed  = 2.5 + _rng.nextDouble() * 4.5;
    x        = originX;
    y        = originY;
    vx       = math.cos(angle) * speed;
    vy       = math.sin(angle) * speed - 3; // bias upward
    radius   = 3.0 + _rng.nextDouble() * 4.0;
    color    = _palette[_rng.nextInt(_palette.length)];
    rotation = _rng.nextDouble() * math.pi * 2;
    rotSpeed = (_rng.nextDouble() - 0.5) * 0.3;
    opacity  = 1.0;
    isRect   = _rng.nextBool();
  }

  /// Returns false when the particle should be removed.
  bool update() {
    x       += vx / 400; // normalised delta
    y       += vy / 400;
    vy      += 0.25;     // gravity
    rotation += rotSpeed;
    opacity -= 0.022;
    return opacity > 0;
  }
}

// ── Painter ───────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlePainter(this.particles) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      paint.color = p.color.withOpacity(p.opacity.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.rotation);
      if (p.isRect) {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.radius * 2, height: p.radius),
          paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.radius, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

// ── Widget ────────────────────────────────────────────────────────────────────
/// Overlay that emits a burst of particles whenever [burstTick] increments.
/// Place this in a Stack above the checkmark button area; it is fully
/// transparent between bursts.
///
/// ```dart
/// Stack(
///   children: [
///     _buildCheckButton(),
///     Obx(() {
///       // Re-create widget each tick so the animation restarts.
///       final tick = controller.particleBurstTick.value;
///       return ParticleBurstOverlay(key: ValueKey(tick));
///     }),
///   ],
/// )
/// ```
class ParticleBurstOverlay extends StatefulWidget {
  /// Origin of the burst in normalised canvas coordinates.
  /// (0.5, 0.8) places the burst near the bottom-centre (over the ✓ button).
  final double originX;
  final double originY;
  final int    particleCount;

  const ParticleBurstOverlay({
    super.key,
    this.originX      = 0.83,  // roughly where the ✓ button is (right column)
    this.originY      = 0.92,  // near bottom
    this.particleCount = 28,
  });

  @override
  State<ParticleBurstOverlay> createState() => _ParticleBurstOverlayState();
}

class _ParticleBurstOverlayState extends State<ParticleBurstOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(_step)..forward();

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_Particle.spawn(
        originX: widget.originX,
        originY: widget.originY,
      ));
    }
  }

  void _step() {
    setState(() {
      _particles.removeWhere((p) => !p.update());
    });
    if (_particles.isEmpty) _ctrl.stop();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(_particles),
        size: Size.infinite,
      ),
    );
  }
}
