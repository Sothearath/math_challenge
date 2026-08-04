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
//
// 4. NEW — 3-state calendar support (completed / quit-half-way / missed):
//
//    a) In ArithmeticController.onInit(), when levelNumber == 0 (the Daily
//       Challenge sentinel), call:
//         Get.find<DailyChallengeController>().markInProgress();
//       and after each answered question:
//         Get.find<DailyChallengeController>().updateProgress(currentQuestionIndex);
//
//    b) DailyChallengeHistoryView now requires `history` (the controller's
//       `history` RxMap) and accepts optional `isInProgress` /
//       `onContinuePressed`. Wherever this view is instantiated (Dashboard
//       or wherever it's pushed from), update the call to:
//
//         Obx(() => DailyChallengeHistoryView(
//           currentStreak: controller.currentStreak, // if you track this elsewhere
//           hasPlayedToday: controller.hasPlayedToday.value,
//           isInProgress: controller.isInProgress.value,
//           history: controller.history,
//           onPlayPressed: () => Get.off(() => const ArithmeticChallengeView(),
//               binding: GameBinding()),
//           onContinuePressed: () => Get.off(() => const ArithmeticChallengeView(),
//               binding: GameBinding()), // game screen should read resumeFromIndex
//         ))
//
//    c) See daily-challenge-calendar-state-spec.md for the full state/CTA/
//       copy reference this implements.