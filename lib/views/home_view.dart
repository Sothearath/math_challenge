// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_map_controller.dart';
import 'game_map_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure GameMapController is available before the view renders
    if (!Get.isRegistered<GameMapController>()) {
      Get.put(GameMapController(), permanent: true);
    }
    return const GameMapView();
  }
}
