// lib/features/game/views/arithmetic_challenge_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/arithmetic_controller.dart';
import '../core/constants.dart';
import '../painters/particle_burst_painter.dart';
import '../theme/app_theme.dart';

class ArithmeticChallengeView extends GetView<ArithmeticController> {
  const ArithmeticChallengeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient body — DecoratedBox wraps the entire safe area
      body: Container(
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildTopBar(),
                  _buildProgressBar(),
                  const SizedBox(height: 6),
                  _buildHeartsRow(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildEquationCard()),
                  _buildAnswerField(),
                  const SizedBox(height: 10),
                  _buildNumpad(),
                  const SizedBox(height: 10),
                ],
              ),

              // Floating combo / speed-bonus labels
              Obx(() {
                final labels = controller.floatingLabels.toList();
                return IgnorePointer(
                  child: Stack(
                    children: labels
                        .map((l) => _FloatingLabelWidget(label: l))
                        .toList(),
                  ),
                );
              }),

              // Particle burst — re-keyed each correct answer
              Obx(() {
                final tick = controller.particleBurstTick.value;
                if (tick == 0) return const SizedBox.shrink();
                return ParticleBurstOverlay(key: ValueKey(tick));
              }),

              // Wrong answer flash — red overlay, re-keyed each wrong answer
              Obx(() {
                final tick = controller.wrongAnswerTick.value;
                if (tick == 0) return const SizedBox.shrink();
                return _WrongAnswerFlash(key: ValueKey('w$tick'));
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Obx(() => Row(
        children: [
          // Quit button
          _iconButton(icon: Icons.close_rounded, onTap: controller.quitGame),
          const SizedBox(width: 8),

          // Timer pill — turns red below 10 s
          _pill(
            icon: Icons.timer_outlined,
            label: '${controller.timeLeft.value}s',
            color: controller.timeLeft.value < 10
                ? AppColors.heartDanger
                : AppColors.cobalt,
          ),
          const SizedBox(width: 8),

          // Level pill
          _pill(
            icon: Icons.trending_up_rounded,
            label: 'Level ${controller.currentLevel.levelNumber}',
            color: AppColors.cobalt,
          ),

          const Spacer(),

          // Score pill
          _pill(
            icon: Icons.star_rounded,
            label: '${controller.score.value}',
            color: AppColors.sunflower,
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.30),
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(color: Colors.white.withOpacity(0.5)),
          ),
          child: Icon(icon, color: AppColors.cobalt, size: 20),
        ),
      );

  Widget _pill({
    required IconData icon,
    required String label,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.28),
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(color: Colors.white.withOpacity(0.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );

  // ── Progress bar ──────────────────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${controller.currentLevel.levelNumber} · ${controller.currentLevel.label}',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: AppColors.mutedOnGrad,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${controller.questionsAnswered.value} / ${controller.currentLevel.questionsPerRound}',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: AppColors.mutedOnGrad,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          )),
          const SizedBox(height: 5),
          // Smooth TweenAnimationBuilder slide
          Obx(() => TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: controller.progressTarget.value),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.sunflower, AppColors.sunflowerLight],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sunflower.withOpacity(0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Obx(() {
        final hearts = controller.hearts.value;
        final danger = controller.dangerState.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(3, (i) {
              final isActive = i < hearts;
              return TweenAnimationBuilder<double>(
                tween: Tween(
                    begin: 1.0, end: (isActive && danger) ? 1.18 : 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (_, scale, __) => Transform.scale(
                  scale: scale,
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 30,
                    color: isActive
                        ? (danger ? AppColors.heartDanger : AppColors.heartRed)
                        : Colors.white.withOpacity(0.25),
                  ),
                ),
              );
            }),
            const SizedBox(width: 14),
            Obx(() => Row(
              children: [
                Text(
                  'Streak ',
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: AppColors.mutedOnGrad),
                ),
                Text(
                  '${controller.streak.value} in a row',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.keyWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          boxShadow: AppTheme.cardShadows,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cobalt.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
                border: Border.all(color: AppColors.cobalt.withOpacity(0.25)),
              ),
              child: Text(
                controller.currentLevel.label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: AppColors.cobalt,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Equation text in Cobalt Blue
            Obx(() => Text(
              controller.equation.value,
              style: GoogleFonts.nunito(
                fontSize: 46,
                fontWeight: FontWeight.w900,
                color: AppColors.cobalt,
                letterSpacing: 1.5,
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
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Obx(() {
        final comboActive = controller.comboActive.value;
        final hasInput    = controller.userInput.value.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.keyWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(
              color: comboActive
                  ? AppColors.correctGreen
                  : AppColors.cobalt.withOpacity(0.20),
              width: comboActive ? 2.5 : 1.5,
            ),
            boxShadow: comboActive
                ? AppTheme.correctGlow
                : AppTheme.cardShadows,
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Forces the row to wrap tightly around the text content
                  children: [
                    // 1. If there is no input, place the blinking cursor first
                    if (!hasInput) ...[
                      const _BlinkingCursor(),
                      const SizedBox(width: 6),
                    ],

                    // 2. The main answer input display text string
                    Text(
                      hasInput ? controller.userInput.value : 'Type your answer',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: hasInput
                            ? AppColors.cobalt
                            : AppColors.cobalt.withOpacity(0.30),
                      ),
                    ),

                    // 3. If there is input typed, attach the blinking cursor right after the final digit
                    if (hasInput) ...[
                      const SizedBox(width: 4),
                      const _BlinkingCursor(),
                    ],
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          ...rows.map(
                (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: row.map((k) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _NumKey(
                      label: k,
                      onTap: () => controller.onKeyTap(k),
                    ),
                  ),
                )).toList(),
              ),
            ),
          ),

          // Bottom row: ⌫ | 0 | ✓
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _NumKey(
                    label: '⌫',
                    isDelete: true,
                    onTap: () => controller.onKeyTap('backspace'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _NumKey(
                    label: '0',
                    onTap: () => controller.onKeyTap('0'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _SubmitKey(onTap: controller.onSubmit),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Number key ────────────────────────────────────────────────────────────────
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
  late final AnimationController _anim;
  late final Animation<double>   _scale;

  // Track pressed state for sunflower pulse background
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween(begin: 1.0, end: 0.87)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onDown(_) {
    setState(() => _pressed = true);
    _anim.forward();
  }

  void _onUp(_) {
    setState(() => _pressed = false);
    _anim.reverse();
    widget.onTap();
  }

  void _onCancel() {
    setState(() => _pressed = false);
    _anim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // Sunflower pulse on press; delete key gets a rose tint
    final bg = widget.isDelete
        ? (_pressed
        ? AppColors.heartRed.withOpacity(0.10)
        : AppColors.keyWhite)
        : (_pressed
        ? AppColors.sunflower.withOpacity(0.18)
        : AppColors.keyWhite);

    final textColor = widget.isDelete ? AppColors.heartDanger : AppColors.cobalt;

    return GestureDetector(
      onTapDown:  _onDown,
      onTapUp:    _onUp,
      onTapCancel: _onCancel,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 72,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTheme.radiusKey),
            boxShadow: _pressed ? [] : AppTheme.keyShadows,
            border: _pressed
                ? Border.all(color: AppColors.sunflower, width: 2.0)
                : Border.all(color: Colors.transparent),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.nunito(
                fontSize: widget.label.length > 1 ? 20 : 26,
                fontWeight: FontWeight.w900,
                color: textColor,
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
  late final AnimationController _anim;
  late final Animation<double>   _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _scale = Tween(begin: 1.0, end: 0.87)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) { setState(() => _pressed = true);  _anim.forward(); },
      onTapUp:     (_) { setState(() => _pressed = false); _anim.reverse(); widget.onTap(); },
      onTapCancel: ()  { setState(() => _pressed = false); _anim.reverse(); },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _pressed
                  ? [AppColors.cobalt, AppColors.cobaltDark]
                  : [AppColors.cobalt, AppColors.cobaltLight],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusKey),
            boxShadow: _pressed
                ? []
                : [
              BoxShadow(
                color: AppColors.cobalt.withOpacity(0.45),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    );
  }
}

// ── Blinking cursor ───────────────────────────────────────────────────────────
class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 2.5,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.cobalt,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── Floating label ────────────────────────────────────────────────────────────
class _FloatingLabelWidget extends StatefulWidget {
  final FloatingLabel label;
  const _FloatingLabelWidget({required this.label});

  @override
  State<_FloatingLabelWidget> createState() => _FloatingLabelWidgetState();
}

class _FloatingLabelWidgetState extends State<_FloatingLabelWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double>   _offset;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _offset = Tween(begin: 0.0, end: -80.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _fade = Tween(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _anim, curve: const Interval(0.55, 1.0)));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 180,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _offset.value),
          child: Opacity(opacity: _fade.value, child: child),
        ),
        child: Center(
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: widget.label.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
              border: Border.all(color: widget.label.color.withOpacity(0.55)),
              boxShadow: [
                BoxShadow(
                  color: widget.label.color.withOpacity(0.20),
                  blurRadius: 12,
                ),
              ],
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

// ── Wrong answer flash ────────────────────────────────────────────────────────
// Semi-transparent red overlay that fades in fast then fades out slowly.
// Re-keyed by wrongAnswerTick so it always replays from scratch.
// IgnorePointer ensures it never blocks taps on the numpad beneath.
class _WrongAnswerFlash extends StatefulWidget {
  const _WrongAnswerFlash({super.key});

  @override
  State<_WrongAnswerFlash> createState() => _WrongAnswerFlashState();
}

class _WrongAnswerFlashState extends State<_WrongAnswerFlash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double>   _opacity;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    // Flash in quickly (1 part = ~75 ms), fade out slowly (5 parts = ~375 ms)
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.32), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.32, end: 0.0), weight: 5),
    ]).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (_, __) => IgnorePointer(
        child: Container(
          color: AppColors.heartDanger.withOpacity(_opacity.value),
        ),
      ),
    );
  }
}