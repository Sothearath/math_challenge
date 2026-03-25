// lib/controllers/game_map_controller.dart
//
// Drives all UI state for the GameMapView:
//   • parallax background offset (scroll-linked)
//   • active orb pulse animation control
//   • shake state for denied taps
//   • scroll controller for parallax

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameMapController extends GetxController with GetTickerProviderStateMixin {
  // ── Scroll / parallax ─────────────────────────────────────────────────────
  late final ScrollController scrollController;
  final RxDouble scrollOffset = 0.0.obs;

  // ── Pulse animation (active orb heartbeat glow) ───────────────────────────
  late AnimationController pulseCtrl;
  late Animation<double> pulseAnim;     // 1.0 → 1.18 → 1.0
  late Animation<double> glowAnim;      // 0.4 → 1.0 → 0.4

  // ── Shake (denied tap) ────────────────────────────────────────────────────
  // Maps "levelIdx_stageIdx" → true while shaking
  final RxMap<String, bool> shakingNodes = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();

    scrollController = ScrollController()
      ..addListener(() {
        scrollOffset.value = scrollController.offset;
      });

    // Heartbeat pulse: slow breathe in/out, continuous
    pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    pulseAnim = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut),
    );
    glowAnim = Tween<double>(begin: 0.35, end: 0.9).animate(
      CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut),
    );
  }

  /// Triggers a short shake on the node identified by [levelIdx]_[stageIdx].
  Future<void> shakeNode(int levelIdx, int stageIdx) async {
    final key = '${levelIdx}_$stageIdx';
    if (shakingNodes[key] == true) return; // already shaking
    shakingNodes[key] = true;
    await Future.delayed(const Duration(milliseconds: 480));
    shakingNodes.remove(key);
  }

  bool isShaking(int levelIdx, int stageIdx) =>
      shakingNodes['${levelIdx}_$stageIdx'] == true;

  @override
  void onClose() {
    scrollController.dispose();
    pulseCtrl.dispose();
    super.onClose();
  }
}
