// lib/views/home_view.dart
// Redirects to /map — kept for route compatibility
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'level_map_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) => const LevelMapView();
}
