// lib/core/ad_config/domain/entities/ad_config_entity.dart
//
// Pure domain entity — no Firebase, no platform imports.
// Houses the three Remote Config parameters the app cares about.

class AdConfigEntity {
  /// AdMob Rewarded Ad Unit ID for Android.
  final String rewardedUnitIdAndroid;

  /// AdMob Rewarded Ad Unit ID for iOS.
  final String rewardedUnitIdIos;

  /// Master switch — when false, no ads are loaded or shown.
  final bool adsEnabled;

  const AdConfigEntity({
    required this.rewardedUnitIdAndroid,
    required this.rewardedUnitIdIos,
    required this.adsEnabled,
  });

  // ── Hardcoded fallback — used when Remote Config is unavailable ──────────
  // These are AdMob test IDs; replace with real IDs in production Remote Config.
  factory AdConfigEntity.fallback() => const AdConfigEntity(
    rewardedUnitIdAndroid: 'ca-app-pub-3940256099942544/5224354917',
    rewardedUnitIdIos:     'ca-app-pub-3940256099942544/1712485313',
    adsEnabled:            true,
  );

  @override
  String toString() =>
      'AdConfigEntity(android: $rewardedUnitIdAndroid, '
      'ios: $rewardedUnitIdIos, adsEnabled: $adsEnabled)';
}
