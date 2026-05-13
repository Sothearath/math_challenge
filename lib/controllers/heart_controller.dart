// lib/controllers/heart_controller.dart
//
// Drop-in companion to AwardsController.
// Manages the animated heart / lives system.  Wire it into GameController
// by calling heartController.loseLife() instead of decrementing lives directly.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'awards_controller.dart';

// ─── Enum ─────────────────────────────────────────────────────────────────────

enum HeartState { full, losing, empty }

// ─── Controller ───────────────────────────────────────────────────────────────

class HeartController extends GetxController with GetTickerProviderStateMixin {
  // Lazily resolved so it works even if AwardsController is registered later.
  AwardsController get _awards => Get.find<AwardsController>();

  // ── observables ─────────────────────────────────────────────────────────────
  final RxInt  lives     = 3.obs;
  final RxBool isAlive   = true.obs;

  /// Per-heart animation state – index 0..2
  final heartStates = List.generate(3, (_) => HeartState.full).obs;

  // ── animation controllers (one per heart slot) ────────────────────────────
  late final List<AnimationController> _animCtrls;
  late final List<Animation<double>>   _scaleAnims;
  late final List<Animation<double>>   _fadeAnims;

  // ── lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    // Restore from storage via AwardsController
    lives.value = _awards.lives.value.clamp(0, 3);
    _buildAnimations();
    _syncHeartStates();
  }

  @override
  void onClose() {
    for (final c in _animCtrls) c.dispose();
    super.onClose();
  }

  // ── animation setup ──────────────────────────────────────────────────────────

  void _buildAnimations() {
    _animCtrls = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );

    _scaleAnims = _animCtrls.map((ctrl) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.0), weight: 70),
      ]).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
    }).toList();

    _fadeAnims = _animCtrls.map((ctrl) {
      return Tween<double>(begin: 1.0, end: 0.0)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeIn));
    }).toList();
  }

  void _syncHeartStates() {
    for (int i = 0; i < 3; i++) {
      heartStates[i] = i < lives.value ? HeartState.full : HeartState.empty;
    }
    heartStates.refresh();
  }

  // ── public API ───────────────────────────────────────────────────────────────

  /// Returns the scale animation for heart at [index].
  Animation<double> scaleFor(int index) => _scaleAnims[index];

  /// Returns the fade animation for heart at [index].
  Animation<double> fadeFor(int index) => _fadeAnims[index];

  /// Call on wrong answer.  Returns false when game is over (0 lives).
  Future<bool> loseLife() async {
    if (lives.value <= 0) return false;

    // Haptic
    HapticFeedback.mediumImpact();

    final slot = lives.value - 1; // 0-based index of the heart to remove

    heartStates[slot] = HeartState.losing;
    heartStates.refresh();

    // Run burst animation
    _animCtrls[slot].reset();
    await _animCtrls[slot].forward();

    lives.value--;
    heartStates[slot] = HeartState.empty;
    heartStates.refresh();

    _awards.saveLives(lives.value);

    if (lives.value <= 0) {
      isAlive.value = false;
      _showGameOverSheet();
      return false;
    }
    return true;
  }

  /// Restore all hearts (ad-revive / in-game purchase).
  void revive() {
    lives.value = 3;
    isAlive.value = true;
    _awards.saveLives(3);
    for (final ctrl in _animCtrls) ctrl.reset();
    _syncHeartStates();
    Get.back(); // close the bottom sheet
  }

  // ── game-over sheet ──────────────────────────────────────────────────────────

  void _showGameOverSheet() {
    Get.bottomSheet(
      _GameOverSheet(heartController: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
    );
  }
}

// ─── Game-Over Bottom Sheet ───────────────────────────────────────────────────

class _GameOverSheet extends StatelessWidget {
  final HeartController heartController;
  const _GameOverSheet({required this.heartController});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF1E1E2E) : Colors.white;
    final accent = const Color(0xFF4A90E2);

    return Container(
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.25),
            blurRadius: 24,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color:        Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // skull / broken-heart icon
          const Text('💔', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'Out of Hearts!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Watch a short ad to revive and keep your progress.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          // Revive button (simulate ad)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              icon:  const Icon(Icons.play_circle_outline_rounded),
              label: const Text(
                'Watch Ad & Revive',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => heartController.revive(),
            ),
          ),
          const SizedBox(height: 12),
          // Quit button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey,
                side: BorderSide(color: Colors.grey.withOpacity(0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Get.back();              // close sheet
                Get.offAllNamed('/');    // back to home
              },
              child: const Text(
                'Quit Game',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Heart Widget ─────────────────────────────────────────────────────────────
//
// Place HeartsRow() inside an Obx() in your game AppBar or HUD.

class HeartsRow extends StatelessWidget {
  final HeartController ctrl;
  const HeartsRow({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => _HeartIcon(ctrl: ctrl, index: i)),
    ));
  }
}

class _HeartIcon extends StatelessWidget {
  final HeartController ctrl;
  final int             index;
  const _HeartIcon({required this.ctrl, required this.index});

  @override
  Widget build(BuildContext context) {
    final state = ctrl.heartStates[index];

    if (state == HeartState.losing) {
      return AnimatedBuilder(
        animation: ctrl.scaleFor(index),
        builder: (_, __) => Transform.scale(
          scale: ctrl.scaleFor(index).value,
          child: Opacity(
            opacity: ctrl.fadeFor(index).value,
            child: const _HeartImage(full: true),
          ),
        ),
      );
    }

    return _HeartImage(full: state == HeartState.full);
  }
}

class _HeartImage extends StatelessWidget {
  final bool full;
  const _HeartImage({required this.full});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Icon(
        full ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        color: full ? const Color(0xFFEF4444) : Colors.grey.shade400,
        size: 28,
      ),
    );
  }
}
