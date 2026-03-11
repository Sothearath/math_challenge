import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:math_challenge/theme/app_theme.dart';
import 'package:math_challenge/views/game_view.dart';
import 'package:math_challenge/views/home_view.dart';
import 'package:math_challenge/views/result_view.dart';

import 'controllers/game_controller.dart';
import 'controllers/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MathChallengeApp());
}

class MathChallengeApp extends StatelessWidget {
  const MathChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Math Challenge',
      debugShowCheckedModeBanner: false,

      // ── Themes ──────────────────────────────────────────────────────
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark, // Start in dark mode
      // ── Dependency injection (permanent controllers) ─────────────────
      initialBinding: BindingsBuilder(() {
        Get.put<ThemeController>(ThemeController(), permanent: true);
        Get.put<GameController>(GameController(), permanent: true);
      }),

      // ── Routes ───────────────────────────────────────────────────────
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeView(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/game',
          page: () => const GameView(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/result',
          page: () => const ResultView(),
          transition: Transition.upToDown,
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ],
    );
  }
}
