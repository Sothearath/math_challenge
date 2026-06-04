// lib/features/onboarding/controllers/onboarding_controller.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants.dart';
import '../../services/storage_service.dart';

class OnboardingController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Page tracking ─────────────────────────────────────────────────────────
  final RxInt  activePage  = 0.obs;
  final int    totalPages  = 3;
  late final PageController pageController;

  // ── Username field ────────────────────────────────────────────────────────
  final TextEditingController usernameCtrl = TextEditingController();
  final RxBool   isLoading      = false.obs;
  final RxString errorMessage   = ''.obs;
  final RxString successMessage = ''.obs;

  // Character rules shown live under the input
  final RxBool   isValidLength  = false.obs; // 3–15 chars
  final RxBool   isValidChars   = false.obs; // alphanumeric + underscore only
  bool get inputIsValid => isValidLength.value && isValidChars.value;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    usernameCtrl.addListener(_validateInput);
  }

  @override
  void onClose() {
    pageController.dispose();
    usernameCtrl.dispose();
    super.onClose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void onPageChanged(int index) => activePage.value = index;

  void nextPage() {
    if (activePage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void previousPage() {
    if (activePage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void skipToUsername() {
    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  // ── Live input validation ─────────────────────────────────────────────────
  void _validateInput() {
    final val = usernameCtrl.text.trim();
    isValidLength.value = val.length >= 3 && val.length <= 15;
    isValidChars.value  = RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(val);

    // Clear error as soon as the user starts correcting
    if (errorMessage.value.isNotEmpty) errorMessage.value = '';
  }

  // ── Firebase username registration ────────────────────────────────────────
  // Flow:
  //   1. Client-side validation
  //   2. Firestore uniqueness check (case-insensitive)
  //   3. Write user document + mark onboarding complete in storage
  //   4. Navigate to dashboard
  Future<void> registerAndCheckUsername() async {
    final username = usernameCtrl.text.trim();

    // ── 1. Client-side guard ─────────────────────────────────────────────
    if (!inputIsValid) {
      errorMessage.value = 'Please fix the issues above before continuing.';
      return;
    }

    isLoading.value    = true;
    errorMessage.value = '';

    try {
      // ── 2. Uniqueness check ────────────────────────────────────────────
      // Store normalised (lowercase) username in a dedicated lookup document
      // so the check is O(1) — no collection scan required.
      final lookupRef = _firestore
          .collection('usernames')
          .doc(username.toLowerCase());

      final existing = await lookupRef.get();

      if (existing.exists) {
        errorMessage.value =
            '"$username" is already taken — try a different one!';
        isLoading.value = false;
        return;
      }

      // ── 3. Write Firestore documents ───────────────────────────────────
      final batch = _firestore.batch();

      // Reserve the username (lookup document)
      batch.set(lookupRef, {
        'username':   username,
        'createdAt':  FieldValue.serverTimestamp(),
      });

      // Baseline user profile for the leaderboard
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final userRef = _firestore.collection('users').doc(uid);

      batch.set(userRef, {
        'uid': uid,
        'username': username,
        'displayName': username,
        'totalXP': 0,
        'highScore': 0,
        'currentLevel': 1,
        'streak': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // ── 4. Persist locally and navigate ───────────────────────────────
      _storage.write(StorageKeys.username,         username);
      _storage.write(StorageKeys.onboardingDone,   true);

      successMessage.value = 'Welcome, $username! 🎉';

      // Brief pause so the success state is visible before navigation
      await Future.delayed(const Duration(milliseconds: 600));
      Get.offAllNamed(Routes.dashboard);

    } on FirebaseException catch (e) {
      errorMessage.value =
          'Network error: ${e.message ?? 'Please try again.'}';
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
