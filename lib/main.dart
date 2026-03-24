// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/game_controller.dart';
import 'controllers/streak_controller.dart';
import 'controllers/theme_controller.dart';
import 'theme/app_theme.dart';
import 'views/home_view.dart';
import 'views/game_view.dart';
import 'views/result_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MathChallengeApp());
}

class MathChallengeApp extends StatelessWidget {
  const MathChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Math Challenge',
      debugShowCheckedModeBanner: false,

      theme:     AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      initialBinding: BindingsBuilder(() {
        Get.put<ThemeController>(ThemeController(), permanent: true);
        Get.put<StreakController>(StreakController(), permanent: true);
        Get.put<GameController>(GameController(),   permanent: true);
      }),

      initialRoute: '/',
      getPages: [
        GetPage(name: '/',       page: () => const HomeView(),   transition: Transition.fadeIn),
        GetPage(name: '/game',   page: () => const GameView(),   transition: Transition.rightToLeft,
            transitionDuration: const Duration(milliseconds: 300)),
        GetPage(name: '/result', page: () => const ResultView(), transition: Transition.upToDown,
            transitionDuration: const Duration(milliseconds: 350)),
      ],
    );
  }
}
