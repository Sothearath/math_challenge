// lib/features/profile/bindings/profile_binding.dart

import 'package:get/get.dart';
import 'package:math_challenge/views/profile/profile_controller.dart';
import '../../services/storage_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService(), permanent: true);
    }
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
      fenix: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Wire-up checklist
// ─────────────────────────────────────────────────────────────────────────────
//
// 1. lib/core/constants.dart — Routes:
//      static const profile = '/profile';
//
// 2. app_pages.dart — GetPage list:
//      GetPage(
//        name:    Routes.profile,
//        page:    () => const ProfileView(),
//        binding: ProfileBinding(),
//      ),
//
// 3. brainy_dashboard_view.dart — settings button onTap:
//      onTap: () => Get.toNamed(Routes.profile),
//
// 4. lib/core/constants.dart — StorageKeys (if not already added):
//      static const username       = 'username';
//      static const onboardingDone = 'onboarding_done';
