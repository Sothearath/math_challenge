// lib/features/profile/controllers/profile_controller.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../../services/storage_service.dart';

class ProfileController extends GetxController {
  late final StorageService _storage;
  final _firestore = FirebaseFirestore.instance;
  final _auth      = FirebaseAuth.instance;

  // ── Observable profile data ───────────────────────────────────────────────
  final RxString username     = ''.obs;
  final RxInt    totalXP      = 0.obs;
  final RxInt    highScore    = 0.obs;
  final RxInt    currentLevel = 1.obs;
  final RxInt    streak       = 0.obs;

  // ── UI state ──────────────────────────────────────────────────────────────
  final RxBool isLoading  = false.obs;
  final RxBool isEditing  = false.obs;
  final RxString errorMsg = ''.obs;

  StreamSubscription<DocumentSnapshot>? _profileSub;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageService>();
    // Seed from local storage immediately so UI isn't blank while Firestore loads
    username.value = _storage.read<String>(StorageKeys.username) ?? '';
    _subscribeToProfile();
  }

  @override
  void onClose() {
    _profileSub?.cancel();
    super.onClose();
  }

  // ── Real-time Firestore stream ────────────────────────────────────────────
  void _subscribeToProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _profileSub = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snap) {
      if (!snap.exists) return;
      final data = snap.data()!;
      username.value     = data['username']     as String? ?? username.value;
      totalXP.value      = data['totalXP']      as int?    ?? 0;
      highScore.value    = data['highScore']     as int?    ?? 0;
      currentLevel.value = data['currentLevel']  as int?    ?? 1;
      streak.value       = data['streak']        as int?    ?? 0;
    }, onError: (e) {
      errorMsg.value = 'Could not load profile: $e';
    });
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    isLoading.value = true;
    try {
      // Clear all local state
      _storage.write(StorageKeys.username,       null);
      _storage.write(StorageKeys.onboardingDone, false);
      _storage.write(StorageKeys.currentLevel,   1);

      await _auth.signOut();
      Get.offAllNamed(Routes.onboarding);
    } catch (e) {
      errorMsg.value = 'Sign-out failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Toggle edit mode ──────────────────────────────────────────────────────
  void toggleEdit() => isEditing.value = !isEditing.value;
}
