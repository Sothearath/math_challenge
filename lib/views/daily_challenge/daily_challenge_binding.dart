// lib/features/game/bindings/daily_challenge_binding.dart

import 'package:get/get.dart';

import 'daily_challenge_controller.dart';

class DailyChallengeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DailyChallengeController>(
          () => DailyChallengeController(),
      fenix: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wire-up checklist
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. Register on the Dashboard route (the card needs it) AND on the Game
//    route (so ArithmeticController can call completeChallenge() when the
//    daily challenge level finishes):
//
//    GetPage(
//      name: Routes.dashboard,
//      page: () => const BrainyDashboardView(),
//      bindings: [DashboardBinding(), DailyChallengeBinding()],
//    ),
//    GetPage(
//      name: Routes.game,
//      page: () => const ArithmeticChallengeView(),
//      bindings: [GameBinding(), DailyChallengeBinding()],
//    ),
//
// 2. pubspec.yaml — ensure intl is present:
//      intl: ^0.19.0
//
// 3. ArithmeticController integration (see daily_challenge_integration.dart
//    for the exact diff to apply to _handleCorrect / _endGame).