// lib/features/game/views/arithmetic_challenge_view.dart
//
// Upgraded Challenge Screen View
// New additions:
//   • Smooth TweenAnimationBuilder progress bar
//   • Floating labels (combo announce + speed bonus) — stack overlay
//   • Combo border glow on answer field
//   • Particle burst overlay on correct answer
//   • Danger-state pulsing red hearts area
//   • Victory / Defeat dialogs triggered by controller

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/arithmetic_controller.dart';
import '../painters/particle_burst_painter.dart';

class ArithmeticChallengeView extends StatefulWidget {
  const ArithmeticChallengeView({super.key});

  @override
  State<ArithmeticChallengeView> createState() =>
      _ArithmeticChallengeViewState();
}

class _ArithmeticChallengeViewState extends State<ArithmeticChallengeView>
    with SingleTickerProviderStateMixin {

  late final ArithmeticController _ctrl;

  // Danger pulse animation (hearts area)
  late final AnimationController _dangerCtrl;
  late final Animation<double>   _dangerPulse;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<ArithmeticController>();

    // Register this vsync provider so the controller's Ticker can use it
    // (if you follow the TickerProvider injection pattern)
    try { Get.put<TickerProvider>(this, permanent: false); } catch (_) {}

    _dangerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _dangerPulse = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _dangerCtrl, curve: Curves.easeInOut));

    // Watch danger state
    ever(_ctrl.dangerState, (bool danger) {
      if (danger) {
        _dangerCtrl.repeat(reverse: true);
      } else {
        _dangerCtrl.stop();
        _dangerCtrl.value = 0;
      }
    });
  }

  @override
  void dispose() {
    _dangerCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Stack(
          children: [
            // ── Main column ──
            Column(
              children: [
                _buildTopBar(),
                _buildProgressBar(),
                const SizedBox(height: 8),
                _buildHeartsRow(),
                const SizedBox(height: 10),
                Expanded(child: _buildEquationCard()),
                _buildAnswerField(),
                const SizedBox(height: 8),
                _buildNumpad(),
                const SizedBox(height: 8),
              ],
            ),

            // ── Floating label overlay ──
            Obx(() {
              final labels = _ctrl.floatingLabels.toList();
              return IgnorePointer(
                child: Stack(
                  children: labels
                      .map((l) => _FloatingLabelWidget(label: l))
                      .toList(),
                ),
              );
            }),

            // ── Particle burst overlay — re-keyed each tick ──
            Obx(() {
              final tick = _ctrl.particleBurstTick.value;
              if (tick == 0) return const SizedBox.shrink();
              return ParticleBurstOverlay(key: ValueKey(tick));
            }),
          ],
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Obx(() => Row(
        children: [
          // Quit button
          _iconButton(
              icon: Icons.close,
              onTap: _ctrl.quitGame),
          const SizedBox(width: 8),
          // Timer pill
          _pill(
            icon: Icons.timer_outlined,
            label: '${_ctrl.timeLeft.value}s',
            color: _ctrl.timeLeft.value < 10
                ? const Color(0xFFFF5252)
                : const Color(0xFF00C896),
          ),
          const SizedBox(width: 8),
          // Level pill
          _pill(
            icon: Icons.trending_up,
            label: 'Level ${_ctrl.currentLevel.levelNumber}',
            color: const Color(0xFF00C896),
          ),
          const Spacer(),
          // Score
          _pill(
            icon: Icons.star,
            label: '${_ctrl.score.value}',
            color: const Color(0xFFFFB300),
          ),
        ],
      )),
    );
  }

  Widget _iconButton(
          {required IconData icon, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2B3C),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      );

  Widget _pill(
          {required IconData icon,
          required String label,
          required Color color}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.nunito(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      );

  // ── Progress bar ──────────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${_ctrl.currentLevel.levelNumber} · ${_ctrl.currentLevel.label}',
                style: GoogleFonts.nunito(
                    fontSize: 11, color: Colors.white38),
              ),
              Text(
                '${_ctrl.questionsAnswered.value} / ${_ctrl.currentLevel.questionsPerRound}',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.white38,
                    fontWeight: FontWeight.w700),
              ),
            ],
          )),
          const SizedBox(height: 4),
          // Smoothly animated progress bar
          Obx(() => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _ctrl.progressTarget.value),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: const Color(0xFF1A2B3C),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF00C896)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ── Hearts row ────────────────────────────────────────────────────────────────
  Widget _buildHeartsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final hearts = _ctrl.hearts.value;
        final danger = _ctrl.dangerState.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hearts
            ...List.generate(
              3,
              (i) => AnimatedBuilder(
                animation: _dangerPulse,
                builder: (_, __) {
                  final isActive = i < hearts;
                  final scale    = (isActive && danger)
                      ? 1.0 + _dangerPulse.value * 0.15
                      : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.favorite,
                      size: 28,
                      color: isActive
                          ? (danger
                              ? Color.lerp(
                                  const Color(0xFFFF5252),
                                  const Color(0xFFFF1744),
                                  _dangerPulse.value)!
                              : const Color(0xFFFF5252))
                          : Colors.white10,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Streak counter
            Obx(() => Row(
              children: [
                Text('Streak',
                    style: GoogleFonts.nunito(
                        fontSize: 12, color: Colors.white38)),
                const SizedBox(width: 6),
                Text('${_ctrl.streak.value} in a row',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.white54,
                        fontWeight: FontWeight.w700)),
              ],
            )),
          ],
        );
      }),
    );
  }

  // ── Equation card ─────────────────────────────────────────────────────────────
  Widget _buildEquationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF162033),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00C896).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF00C896).withOpacity(0.4)),
              ),
              child: Text(
                _ctrl.currentLevel.label,
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: const Color(0xFF00C896),
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Text(
              _ctrl.equation.value,
              style: GoogleFonts.nunito(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1,
              ),
            )),
          ],
        ),
      ),
    );
  }

  // ── Answer field ──────────────────────────────────────────────────────────────
  Widget _buildAnswerField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Obx(() {
        final comboActive = _ctrl.comboActive.value;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF162033),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: comboActive
                  ? const Color(0xFF00E676)
                  : Colors.white12,
              width: comboActive ? 2.0 : 1.0,
            ),
            boxShadow: comboActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF00E676).withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Blinking cursor
              _BlinkingCursor(),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _ctrl.userInput.value.isEmpty
                      ? 'Type your answer'
                      : _ctrl.userInput.value,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: _ctrl.userInput.value.isEmpty
                        ? Colors.white24
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Numpad ────────────────────────────────────────────────────────────────────
  Widget _buildNumpad() {
    const rows = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: row
                    .map((k) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _NumKey(
                                label: k,
                                onTap: () => _ctrl.onKeyTap(k)),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          // Bottom row: delete | 0 | submit
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _NumKey(
                    label: '⌫',
                    isDelete: true,
                    onTap: () => _ctrl.onKeyTap('backspace'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _NumKey(
                      label: '0', onTap: () => _ctrl.onKeyTap('0')),
                ),
              ),
              // Submit button wrapped in particle-burst stack
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _SubmitKey(onTap: _ctrl.onSubmit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Number key widget ─────────────────────────────────────────────────────────
class _NumKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDelete;

  const _NumKey({
    required this.label,
    required this.onTap,
    this.isDelete = false,
  });

  @override
  State<_NumKey> createState() => _NumKeyState();
}

class _NumKeyState extends State<_NumKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.88).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: widget.isDelete
                ? const Color(0xFF3B1A1A)
                : const Color(0xFF1A2B3C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.nunito(
                fontSize: widget.label.length > 1 ? 18 : 24,
                fontWeight: FontWeight.w700,
                color: widget.isDelete
                    ? const Color(0xFFFF5252)
                    : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Submit key ────────────────────────────────────────────────────────────────
class _SubmitKey extends StatefulWidget {
  final VoidCallback onTap;
  const _SubmitKey({required this.onTap});

  @override
  State<_SubmitKey> createState() => _SubmitKeyState();
}

class _SubmitKeyState extends State<_SubmitKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: const Color(0xFF00C896),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}

// ── Blinking cursor ───────────────────────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 2,
        height: 20,
        color: const Color(0xFF00C896),
      ),
    );
  }
}

// ── Floating label widget ─────────────────────────────────────────────────────
/// Animates upward and fades out, positioned in the centre of the screen.
class _FloatingLabelWidget extends StatefulWidget {
  final FloatingLabel label;
  const _FloatingLabelWidget({required this.label});

  @override
  State<_FloatingLabelWidget> createState() => _FloatingLabelWidgetState();
}

class _FloatingLabelWidgetState extends State<_FloatingLabelWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _offset;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _offset = Tween(begin: 0.0, end: -80.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade   = Tween(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(
            parent: _ctrl, curve: const Interval(0.55, 1.0)));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Horizontally centred, vertically placed above the numpad
      left: 0,
      right: 0,
      bottom: 180,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _offset.value),
          child: Opacity(opacity: _fade.value, child: child),
        ),
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: widget.label.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: widget.label.color.withOpacity(0.5)),
            ),
            child: Text(
              widget.label.text,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: widget.label.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
