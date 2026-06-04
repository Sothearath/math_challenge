// lib/features/onboarding/views/onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brainy_painter.dart';
import 'onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: double.infinity),
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip button (hidden on last slide) ────────────────────
              Obx(() => AnimatedOpacity(
                opacity: ctrl.activePage.value < 2 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 16, 0),
                    child: GestureDetector(
                      onTap: ctrl.skipToUsername,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.55)),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.cobalt,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )),

              // ── Slide pages ───────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: ctrl.pageController,
                  onPageChanged: ctrl.onPageChanged,
                  physics: const ClampingScrollPhysics(),
                  children: const [
                    _SlideWelcome(),
                    _SlideFeatures(),
                    _SlideUsername(),
                  ],
                ),
              ),

              // ── Dot indicators ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(ctrl.totalPages, (i) {
                    final active = ctrl.activePage.value == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.cobalt
                            : Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 1 — Welcome
// ─────────────────────────────────────────────────────────────────────────────
class _SlideWelcome extends StatelessWidget {
  const _SlideWelcome();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Brainy mascot + ground shadow
          Column(
            children: [
              SizedBox(
                width: 200,
                height: 210,
                child: CustomPaint(painter: BrainyPainter()),
              ),
              // Ground shadow
              Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius:
                      const BorderRadius.all(Radius.elliptical(80, 10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // White card
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.keyWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: AppTheme.cardShadows,
            ),
            child: Column(
              children: [
                Text(
                  'Hi, I\'m Brainy! 👋',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cobalt,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Let\'s sharpen those math skills today!\nReady to become a math champion?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    color: AppColors.cobalt.withOpacity(0.65),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Next button
          _ChunkyButton(
            label: 'Let\'s Go! 🚀',
            onTap: ctrl.nextPage,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 2 — Features
// ─────────────────────────────────────────────────────────────────────────────
class _SlideFeatures extends StatelessWidget {
  const _SlideFeatures();

  static const _features = [
    (icon: '🎯', title: 'Level Up Skills',    body: 'Progress through 15 levels from Beginner to Expert'),
    (icon: '⚡', title: 'Earn +50 XP Bonus',  body: 'Answer fast for speed bonuses and combo multipliers'),
    (icon: '🏆', title: 'Unlock Milestones',  body: 'Collect trophies and rise up the global leaderboard'),
    (icon: '🔥', title: 'Daily Streak',        body: 'Play every day to keep your streak and earn rewards'),
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heading
          Text(
            'What awaits you',
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.cobalt,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Everything you need to become a math legend',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.mutedOnGrad,
            ),
          ),
          const SizedBox(height: 24),

          // Feature pills
          ..._features.map((f) => _FeaturePill(
                icon: f.icon,
                title: f.title,
                body: f.body,
              )),

          const SizedBox(height: 28),

          Row(
            children: [
              // Back
              Expanded(
                child: _ChunkyButton(
                  label: '← Back',
                  onTap: ctrl.previousPage,
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: 12),
              // Next
              Expanded(
                flex: 2,
                child: _ChunkyButton(
                  label: 'Next →',
                  onTap: ctrl.nextPage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String icon, title, body;
  const _FeaturePill(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.28),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: Colors.white.withOpacity(0.55)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cobalt)),
                Text(body,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.cobalt.withOpacity(0.65),
                        height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slide 3 — Username
// ─────────────────────────────────────────────────────────────────────────────
class _SlideUsername extends StatelessWidget {
  const _SlideUsername();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<OnboardingController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Heading
          Text(
            'Join the Leaderboard! 🚀',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.cobalt,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a unique username to compete globally',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.mutedOnGrad,
            ),
          ),
          const SizedBox(height: 28),

          // ── Input card ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.keyWhite,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: AppTheme.cardShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your username',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cobalt.withOpacity(0.60),
                  ),
                ),
                const SizedBox(height: 10),

                // TextField
                Obx(() {
                  final hasError   = ctrl.errorMessage.value.isNotEmpty;
                  final hasSuccess = ctrl.successMessage.value.isNotEmpty;
                  return TextField(
                    controller: ctrl.usernameCtrl,
                    maxLength: 15,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    inputFormatters: [
                      // Strip spaces as typed
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.cobalt,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. MathWizard99',
                      hintStyle: GoogleFonts.nunito(
                        fontSize: 15,
                        color: AppColors.cobalt.withOpacity(0.30),
                      ),
                      counterStyle: GoogleFonts.nunito(
                        fontSize: 11,
                        color: AppColors.cobalt.withOpacity(0.40),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      filled: true,
                      fillColor: AppColors.cobalt.withOpacity(0.04),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(
                            color: AppColors.cobalt.withOpacity(0.20)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(
                            color: hasError
                                ? AppColors.heartDanger
                                : AppColors.cobalt.withOpacity(0.20)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusInput),
                        borderSide: BorderSide(
                          color: hasError
                              ? AppColors.heartDanger
                              : hasSuccess
                                  ? AppColors.correctGreen
                                  : AppColors.cobalt,
                          width: 2,
                        ),
                      ),
                      suffixIcon: hasSuccess
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.correctGreen, size: 22)
                          : null,
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // ── Live validation hints ─────────────────────────────
                Obx(() => Column(
                  children: [
                    _ValidationHint(
                      label: '3–15 characters',
                      passed: ctrl.isValidLength.value,
                      empty: ctrl.usernameCtrl.text.isEmpty,
                    ),
                    const SizedBox(height: 4),
                    _ValidationHint(
                      label: 'Letters, numbers, underscores only',
                      passed: ctrl.isValidChars.value,
                      empty: ctrl.usernameCtrl.text.isEmpty,
                    ),
                  ],
                )),

                // ── Error message ─────────────────────────────────────
                Obx(() {
                  if (ctrl.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.heartDanger, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ctrl.errorMessage.value,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: AppColors.heartDanger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // ── Success message ───────────────────────────────────
                Obx(() {
                  if (ctrl.successMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.celebration_rounded,
                            color: AppColors.correctGreen, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ctrl.successMessage.value,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: AppColors.correctGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── CTA button ───────────────────────────────────────────────
          Obx(() => _ChunkyButton(
            label: ctrl.isLoading.value
                ? 'Checking...'
                : 'Claim My Spot! 🏆',
            onTap: ctrl.isLoading.value
                ? null
                : ctrl.registerAndCheckUsername,
            isLoading: ctrl.isLoading.value,
          )),

          const SizedBox(height: 12),

          // Back button
          TextButton(
            onPressed: ctrl.previousPage,
            onLongPress: null,
            child: Text(
              '← Back',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.cobalt.withOpacity(0.60),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Validation hint row
// ─────────────────────────────────────────────────────────────────────────────
class _ValidationHint extends StatelessWidget {
  final String label;
  final bool   passed;
  final bool   empty;

  const _ValidationHint({
    required this.label,
    required this.passed,
    required this.empty,
  });

  @override
  Widget build(BuildContext context) {
    final color = empty
        ? AppColors.cobalt.withOpacity(0.35)
        : passed
            ? AppColors.correctGreen
            : AppColors.heartDanger;

    final icon = empty
        ? Icons.radio_button_unchecked_rounded
        : passed
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chunky 3D button — matches Begin Challenge / Submit key aesthetic
// ─────────────────────────────────────────────────────────────────────────────
class _ChunkyButton extends StatefulWidget {
  final String      label;
  final VoidCallback? onTap;
  final bool        isPrimary;
  final bool        isLoading;

  const _ChunkyButton({
    required this.label,
    required this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  State<_ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<_ChunkyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double>   _scale;
  bool _pressed = false;

  // Shadow depth — 5px at rest, 0 when pressed (3D push effect)
  static const double _shadowDepth = 5.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _onDown(_) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
    _anim.forward();
  }

  void _onUp(_) {
    setState(() => _pressed = false);
    _anim.reverse();
    widget.onTap?.call();
  }

  void _onCancel() {
    setState(() => _pressed = false);
    _anim.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;

    // Primary: cobalt gradient. Secondary: frosted white.
    final topColor = widget.isPrimary
        ? AppColors.cobalt
        : Colors.white.withOpacity(0.70);
    final shadowColor = widget.isPrimary
        ? AppColors.cobaltDark
        : AppColors.cobalt.withOpacity(0.25);
    final textColor = widget.isPrimary
        ? Colors.white
        : AppColors.cobalt;

    return GestureDetector(
      onTapDown:   _onDown,
      onTapUp:     _onUp,
      onTapCancel: _onCancel,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          // 3D depth: outer shadow layer shifts down when released
          margin: EdgeInsets.only(bottom: _pressed ? _shadowDepth : 0),
          decoration: BoxDecoration(
            color: shadowColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            // Face lifts up when released, drops flush when pressed
            margin: EdgeInsets.only(bottom: _pressed ? 0 : _shadowDepth),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: widget.isPrimary
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.cobalt, AppColors.cobaltLight],
                    )
                  : null,
              color: widget.isPrimary ? null : Colors.white.withOpacity(0.40),
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
              border: widget.isPrimary
                  ? null
                  : Border.all(color: Colors.white.withOpacity(0.70)),
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: textColor,
                      ),
                    )
                  : Text(
                      widget.label,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDisabled
                            ? textColor.withOpacity(0.50)
                            : textColor,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
