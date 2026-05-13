// lib/views/arithmetic_challenge_view.dart
//
// FlexiArithmetic: Brainy Challenge — Active Challenge screen.
// Spring Green Harmony palette, rounded 24px+ containers.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/arithmetic_controller.dart';
import '../core/constants.dart';

// ─── Screen-level color constants ────────────────────────────────────────────

const _kBg          = Color(0xFF10172A);
const _kCard        = Color(0xFF1A2540);
const _kCardBorder  = Color(0xFF1E2D4A);
const _kGreen       = Color(0xFF00E5BC);   // Spring Green — primary accent
const _kGreenText   = Color(0xFF032B22);   // text ON green
const _kBlue        = Color(0xFF1F78FF);   // Electric Blue — secondary
const _kRed         = Color(0xFFFF4B4B);   // hearts / wrong
const _kGold        = Color(0xFFFFD700);   // score star
const _kKeyNum      = Color(0xFF1E2D4A);   // number key bg
const _kKeyDel      = Color(0xFF2A1A28);   // delete key bg
const _kTextPrimary = Colors.white;
const _kTextMuted   = Color(0xFF4A6080);
const _kTextDim     = Color(0xFF2E4060);

// ─── View ─────────────────────────────────────────────────────────────────────

class ArithmeticChallengeView extends GetView<ArithmeticController> {
  const ArithmeticChallengeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _kBg,
        body: SafeArea(
          child: Obx(() {
            // Full-screen overlay when game ends
            if (controller.gameState.value == GameState.timeUp ||
                controller.gameState.value == GameState.gameOver) {
              return _GameEndOverlay(
                isTimeUp: controller.gameState.value == GameState.timeUp,
              );
            }
            return _GamePlayBody();
          }),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GAME PLAY BODY
// ═══════════════════════════════════════════════════════════════════════════════

class _GamePlayBody extends GetView<ArithmeticController> {
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Column(
      children: [
        SizedBox(height: h * 0.015),
        const _Header(),
        SizedBox(height: h * 0.012),
        const _ProgressBar(),
        SizedBox(height: h * 0.012),
        const _HeartsRow(),
        const _StreakBar(),
        SizedBox(height: h * 0.012),
        const _EquationBox(),
        SizedBox(height: h * 0.01),
        const _InputArea(),
        SizedBox(height: h * 0.012),
        const Expanded(child: _NumberPad()),
        SizedBox(height: h * 0.01),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends GetView<ArithmeticController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Close button
          _CircleButton(
            icon:    Icons.close_rounded,
            color:   _kTextMuted,
            bgColor: _kCard,
            onTap:   () => _showQuitDialog(context),
          ),

          // Timer pill — center
          Expanded(
            child: Center(
              child: Obx(() {
                final warn = controller.isTimeWarning;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color:        _kCard,
                    borderRadius: BorderRadius.circular(100),
                    border:       Border.all(
                      color: warn ? _kRed : _kGreen,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        warn
                            ? Icons.warning_amber_rounded
                            : Icons.timer_outlined,
                        size:  18,
                        color: warn ? _kRed : _kGreen,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        '${controller.timeLeft.value}s',
                        style: TextStyle(
                          fontSize:   20,
                          fontWeight: FontWeight.w800,
                          color:      warn ? _kRed : _kGreen,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Score pill
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color:        _kCard,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 18, color: _kGold),
                const SizedBox(width: 5),
                Text(
                  '${controller.score.value}',
                  style: const TextStyle(
                    fontSize:   17,
                    fontWeight: FontWeight.w800,
                    color:      _kTextPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('Quit session?',
            style: TextStyle(color: _kTextPrimary,
                fontWeight: FontWeight.w800)),
        content: const Text(
            'Your current progress won\'t be saved.',
            style: TextStyle(color: _kTextMuted)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep playing',
                style: TextStyle(color: _kGreen,
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.stopGame();
              Get.offAllNamed(Routes.dashboard);
            },
            child: const Text('Quit',
                style: TextStyle(color: _kRed,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Progress bar ─────────────────────────────────────────────────────────────

class _ProgressBar extends GetView<ArithmeticController> {
  const _ProgressBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Obx(() => TweenAnimationBuilder<double>(
          tween:    Tween(end: controller.progress.value),
          duration: const Duration(milliseconds: 500),
          builder:  (_, v, __) => LinearProgressIndicator(
            value:           v,
            minHeight:       6,
            backgroundColor: _kCard,
            valueColor: AlwaysStoppedAnimation<Color>(
              controller.isTimeWarning ? _kRed : _kGreen,
            ),
          ),
        )),
      ),
    );
  }
}

// ─── Hearts ───────────────────────────────────────────────────────────────────

class _HeartsRow extends GetView<ArithmeticController> {
  const _HeartsRow();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        ArithmeticController.maxLives,
            (i) {
          final alive = i < controller.lives.value;
          return AnimatedOpacity(
            opacity:  alive ? 1.0 : 0.2,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                alive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _kRed,
                size:  26,
              ),
            ),
          );
        },
      ),
    ));
  }
}

// ─── Streak bar ───────────────────────────────────────────────────────────────

class _StreakBar extends GetView<ArithmeticController> {
  const _StreakBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Streak',
              style: TextStyle(fontSize: 12, color: _kTextMuted)),
          Obx(() => Text(
            controller.streakLabel,
            style: const TextStyle(
                fontSize: 12, color: _kGreen, fontWeight: FontWeight.w600),
          )),
        ],
      ),
    );
  }
}

// ─── Equation box ─────────────────────────────────────────────────────────────

class _EquationBox extends GetView<ArithmeticController> {
  const _EquationBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width:   double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          color:        _kCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _kCardBorder, width: 0.5),
        ),
        child: Column(
          children: [
            const Text(
              'Solve the equation',
              style: TextStyle(fontSize: 11, color: _kTextMuted,
                  letterSpacing: 0.8, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Obx(() {
              final flash = controller.equationFlash.value;
              Color textColor = _kTextPrimary;
              if (flash == 'correct') textColor = _kGreen;
              if (flash == 'wrong')   textColor = _kRed;

              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 120),
                style: TextStyle(
                  fontSize:     42,
                  fontWeight:   FontWeight.w900,
                  color:        textColor,
                  letterSpacing: -1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                child: Text(
                  controller.currentEquation.value?.toString() ?? '—',
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─── Input area ───────────────────────────────────────────────────────────────

class _InputArea extends GetView<ArithmeticController> {
  const _InputArea();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Obx(() {
        final hasInput = controller.hasInput;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width:   double.infinity,
          height:  54,
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color:        _kCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasInput ? _kGreen : _kCardBorder,
              width: hasInput ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Text(
                hasInput ? controller.inputValue.value : '_',
                style: TextStyle(
                  fontSize:   26,
                  fontWeight: FontWeight.w800,
                  color:      hasInput ? _kTextPrimary : _kTextDim,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (hasInput) ...[
                const SizedBox(width: 3),
                const _BlinkingCursor(),
              ],
              const Spacer(),
              if (!hasInput)
                const Text('Type your answer',
                    style: TextStyle(fontSize: 13, color: _kTextDim)),
            ],
          ),
        );
      }),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

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
      vsync:    this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child:   Container(
        width: 2, height: 28,
        color: _kGreen,
      ),
    );
  }
}

// ─── Number pad ───────────────────────────────────────────────────────────────

class _NumberPad extends GetView<ArithmeticController> {
  const _NumberPad();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount:  3,
        mainAxisSpacing:  8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.3,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Row 1
          _NumKey('7'), _NumKey('8'), _NumKey('9'),
          // Row 2
          _NumKey('4'), _NumKey('5'), _NumKey('6'),
          // Row 3
          _NumKey('1'), _NumKey('2'), _NumKey('3'),
          // Row 4
          _DelKey(), _NumKey('0'), _CheckKey(),
        ],
      ),
    );
  }
}

// ── Individual key widgets ────────────────────────────────────────────────────

class _NumKey extends GetView<ArithmeticController> {
  final String digit;
  const _NumKey(this.digit);

  @override
  Widget build(BuildContext context) {
    return _KeyBase(
      bgColor:  _kKeyNum,
      onTap:    () => controller.onDigitTap(digit),
      child:    Text(digit,
          style: const TextStyle(fontSize: 22,
              fontWeight: FontWeight.w700, color: _kTextPrimary)),
    );
  }
}

class _DelKey extends GetView<ArithmeticController> {
  @override
  Widget build(BuildContext context) {
    return _KeyBase(
      bgColor: _kKeyDel,
      onTap:   controller.onDeleteTap,
      child:   const Icon(
        Icons.backspace_outlined,
        size: 22, color: _kRed,
      ),
    );
  }
}

class _CheckKey extends GetView<ArithmeticController> {
  @override
  Widget build(BuildContext context) {
    return _KeyBase(
      bgColor: _kGreen,
      onTap:   controller.onCheckTap,
      child:   const Icon(
        Icons.check_rounded,
        size: 26, color: _kGreenText,
      ),
    );
  }
}

class _KeyBase extends StatefulWidget {
  final Color    bgColor;
  final Widget   child;
  final VoidCallback onTap;

  const _KeyBase({
    required this.bgColor,
    required this.child,
    required this.onTap,
  });

  @override
  State<_KeyBase> createState() => _KeyBaseState();
}

class _KeyBaseState extends State<_KeyBase> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _scale = 0.93),
      onTapUp:    (_) { setState(() => _scale = 1.0); widget.onTap(); },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale:    _scale,
        duration: const Duration(milliseconds: 90),
        child:    Container(
          decoration: BoxDecoration(
            color:        widget.bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

// ─── Circle button ────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final Color    bgColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  40, height: 40,
        decoration: BoxDecoration(
            color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GAME END OVERLAY
// ═══════════════════════════════════════════════════════════════════════════════

class _GameEndOverlay extends GetView<ArithmeticController> {
  final bool isTimeUp;
  const _GameEndOverlay({required this.isTimeUp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding:     const EdgeInsets.all(28),
          decoration:  BoxDecoration(
            color:        _kCard,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _kCardBorder, width: 0.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isTimeUp
                    ? Icons.hourglass_empty_rounded
                    : Icons.heart_broken_rounded,
                size:  56,
                color: isTimeUp ? _kGold : _kRed,
              ),
              const SizedBox(height: 14),
              Text(
                isTimeUp ? "Time's up!" : 'Game over',
                style: const TextStyle(fontSize: 26,
                    fontWeight: FontWeight.w900, color: _kTextPrimary),
              ),
              const SizedBox(height: 10),
              // Score row
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 20, color: _kGold),
                  const SizedBox(width: 6),
                  Text(
                    '${controller.score.value} points',
                    style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.w700, color: _kTextPrimary),
                  ),
                ],
              )),
              const SizedBox(height: 4),
              Obx(() => Text(
                'Best streak: ${controller.bestStreak.value}',
                style: const TextStyle(
                    fontSize: 14, color: _kTextMuted),
              )),
              const SizedBox(height: 8),
              Text(
                isTimeUp
                    ? "Great session! Every rep sharpens your mind."
                    : "Brainy believes in you — try again!",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _kTextMuted),
              ),
              const SizedBox(height: 24),
              // Play again
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: _kGreenText,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    controller.startGame();
                  },
                  child: const Text('Play again',
                      style: TextStyle(fontSize: 17,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 10),
              // Back to dashboard
              SizedBox(
                width:  double.infinity,
                height: 52,
                child:  OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kTextMuted,
                    side: const BorderSide(color: _kCardBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  onPressed: () {
                    controller.stopGame();
                    Get.offAllNamed(Routes.dashboard);
                  },
                  child: const Text('Back to dashboard',
                      style: TextStyle(fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}