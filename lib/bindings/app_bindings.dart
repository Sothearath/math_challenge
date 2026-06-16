// lib/bindings/app_bindings.dart
//
// Registered as `initialBinding` in GetMaterialApp.
// Only permanent, app-wide controllers go here.

import 'package:get/get.dart';
import '../controllers/arithmetic_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/theme_controller.dart';
import '../controllers/streak_controller.dart';
import '../controllers/awards_controller.dart';
import '../controllers/heart_controller.dart';
import '../services/storage_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Services first — controllers may depend on them
    Get.put(StorageService(), permanent: true);

    // App-wide controllers (never disposed)
    Get.put(ThemeController(),   permanent: true);
    Get.put(StreakController(),  permanent: true);
    Get.put(AwardsController(),  permanent: true);
    Get.put(HeartController(),   permanent: true);
  }
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardController());
  }
}

class GameBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => GameController());
    // Get.lazyPut(() => GameMapController());
    Get.lazyPut<ArithmeticController>(() => ArithmeticController(), fenix: true,);
  }
}
