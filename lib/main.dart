// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:math_challenge/services/auth_service.dart';
import 'package:math_challenge/services/storage_service.dart';
import 'package:math_challenge/views/arithmetic_challenge_view.dart';
import 'package:math_challenge/views/awards_view.dart';
import 'package:math_challenge/views/brainy_dashboard_view.dart';
import 'package:math_challenge/views/game_map_view.dart';
import 'package:math_challenge/views/level_map_view.dart';
import 'package:math_challenge/views/onboarding/onboarding_binding.dart';
import 'package:math_challenge/views/onboarding/onboarding_view.dart';
import 'package:math_challenge/views/profile/profile_binding.dart';
import 'package:math_challenge/views/profile/profile_view.dart';
import 'bindings/app_bindings.dart';
import 'controllers/daily_challenge_view.dart';
import 'core/ad_config/ad_config_binding.dart';
import 'core/constants.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'views/game_view.dart';
import 'views/result_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initRemoteConfig();
  // Initialise storage before any controller reads it
  await StorageService.init();
  MobileAds.instance.initialize();
  Get.put<StorageService>(StorageService(), permanent: true);
  await Get.putAsync<AuthService>(
        () async => await AuthService().init(),
    permanent: true,

  );

  runApp(const MathChallengeApp());
}

class MathChallengeApp extends StatelessWidget {
  const MathChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
      final initialRoute = storage.read<bool>(StorageKeys.onboardingDone) == true
      ? Routes.dashboard
      : Routes.onboarding;
    return GetMaterialApp(
      title: 'FlexiArithmetic: Brainy Challenge',
      debugShowCheckedModeBanner: false,
      // Theme
      theme:     AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // ThemeController will override at runtime

      // Bindings — permanent controllers registered here
      initialBinding: AppBindings(),

      // Routes — all names are Routes.* constants, never bare strings
      initialRoute: initialRoute,
      getPages: [
        GetPage(
          name:    Routes.dashboard,
          page:    () => const BrainyDashboardView(),
          binding: DashboardBinding(),
        ),
        GetPage(
          name:    Routes.game,
          page:    () => const ArithmeticChallengeView(),
          binding: GameBinding(),
        ),
        GetPage(
          name:    Routes.result,
          page:    () => const ResultView(),
        ),
        GetPage(
          name:    Routes.levelMap,
          page:    () => const LevelMapView(),
        ),
        GetPage(
          name:    Routes.gameMap,
          page:    () => const GameMapView(),
        ),
        GetPage(
          name:    Routes.dailyChallenge,
          page:    () => const DailyChallengeTabView(),
        ),
        GetPage(
          name:    Routes.awards,
          page:    () => const AwardsView(),
        ),
        GetPage(
          name:    Routes.onboarding, page:    () => const OnboardingView(), binding: OnboardingBinding(),
        ),
        GetPage(
          name:    Routes.profile,
          page:    () => const ProfileView(),
          binding: ProfileBinding(),
        ),
      ],
    );
  }
}
