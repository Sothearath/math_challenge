// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:math_challenge/services/storage_service.dart';
import 'package:math_challenge/views/arithmetic_challenge_view.dart';
import 'package:math_challenge/views/awards_view.dart';
import 'package:math_challenge/views/brainy_dashboard_view.dart';
import 'package:math_challenge/views/game_map_view.dart';
import 'package:math_challenge/views/level_map_view.dart';
import 'bindings/app_bindings.dart';
import 'controllers/daily_challenge_view.dart';
import 'core/constants.dart';
import 'theme/app_theme.dart';
import 'views/game_view.dart';
import 'views/result_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialise storage before any controller reads it
  await StorageService.init();

  runApp(const MathChallengeApp());
}

class MathChallengeApp extends StatelessWidget {
  const MathChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      initialRoute: Routes.dashboard,
      getPages: [
        GetPage(
          name:    Routes.dashboard,
          page:    () => const BrainyDashboardView(),
          binding: DashboardBinding(),
        ),
        // GetPage(
        //   name:    Routes.game,
        //   page:    () => const GameView(),
        //   binding: GameBinding(),
        // ),
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
          name:       Routes.game,
          page:       () => const ArithmeticChallengeView(),
          binding:    GameBinding(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
