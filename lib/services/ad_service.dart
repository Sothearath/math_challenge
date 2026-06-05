// lib/core/ad_config/services/ad_service.dart
//
// Refactored AdService — reads ad config exclusively from AdConfigRepository.
// No Firebase imports. No platform checks. No hardcoded ad unit IDs.
// Dependency-injected via constructor so it's trivially testable.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/ad_config/ad_config_repository.dart';

class AdService extends GetxService {
  final AdConfigRepository _adConfigRepo;

  AdService({AdConfigRepository? adConfigRepo})
      : _adConfigRepo = adConfigRepo ?? Get.find<AdConfigRepository>();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  // ── Ad unit ID — resolved from Remote Config via repository ───────────────
  // Falls back to AdConfigEntity.fallback() values if Remote Config is offline.
  String get rewardedAdUnitId {
    final config = _adConfigRepo.getAdConfig();
    if (Platform.isAndroid) return config.rewardedUnitIdAndroid;
    if (Platform.isIOS)     return config.rewardedUnitIdIos;
    throw UnsupportedError('Unsupported platform for ads');
  }

  // ── Master ads switch from Remote Config ─────────────────────────────────
  bool get _adsEnabled => _adConfigRepo.getAdConfig().adsEnabled;

  // ── Load ──────────────────────────────────────────────────────────────────
  void loadRewardedAd() {
    // Guard 1: already loading or loaded
    if (_isLoading || _rewardedAd != null) return;

    // Guard 2: Remote Config master switch
    if (!_adsEnabled) {
      debugPrint('[AdService] ads_enabled = false — skipping load');
      return;
    }

    _isLoading = true;
    final unitId = rewardedAdUnitId;
    debugPrint('[AdService] loading rewarded ad: $unitId');

    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading  = false;
          debugPrint('[AdService] rewarded ad loaded');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _isLoading  = false;
          debugPrint('[AdService] load failed: ${error.message}');
        },
      ),
    );
  }

  // ── Show ──────────────────────────────────────────────────────────────────
  void showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdClosedOrFailed,
  }) {
    // Check master switch at show-time too — the flag may have changed
    // between when the ad was loaded and when it's shown.
    if (!_adsEnabled) {
      debugPrint('[AdService] ads_enabled = false — skipping show');
      onAdClosedOrFailed();
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('[AdService] no ad ready — triggering fallback');
      onAdClosedOrFailed();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // Pre-load next ad for subsequent shows
        onAdClosedOrFailed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] show failed: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosedOrFailed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('[AdService] reward earned: ${reward.amount} ${reward.type}');
        onRewardEarned();
      },
    );
  }

  // ── Dispose ───────────────────────────────────────────────────────────────
  @override
  void onClose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    super.onClose();
  }
}
