// lib/core/ad_config/data/datasources/remote_config_datasource.dart
//
// Only file in the project that imports firebase_remote_config.
// All other layers depend on abstractions, never on this class directly.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Key constants — defined once here, referenced nowhere else.
abstract class RemoteConfigKeys {
  static const rewardedUnitIdAndroid = 'ad_rewarded_unit_id_android';
  static const rewardedUnitIdIos     = 'ad_rewarded_unit_id_ios';
  static const adsEnabled            = 'ads_enabled';
}

/// Default values served when the device is offline or Remote Config
/// has never been fetched before.
const Map<String, dynamic> _kDefaults = {
  RemoteConfigKeys.rewardedUnitIdAndroid:
      'ca-app-pub-3940256099942544/5224354917', // AdMob Android test ID
  RemoteConfigKeys.rewardedUnitIdIos:
      'ca-app-pub-3940256099942544/1712485313', // AdMob iOS test ID
  RemoteConfigKeys.adsEnabled: true,
};

class RemoteConfigDataSource {
  final FirebaseRemoteConfig _rc;

  RemoteConfigDataSource({FirebaseRemoteConfig? remoteConfig})
      : _rc = remoteConfig ?? FirebaseRemoteConfig.instance;

  // ── Initialization ────────────────────────────────────────────────────────
  // Call once at app startup (from binding or main.dart).
  // Never throws — logs errors and falls back to defaults.
  Future<void> init() async {
    try {
      // 1. Set defaults so getters work immediately, even before first fetch.
      await _rc.setDefaults(_kDefaults);

      // 2. Configure fetch settings.
      await _rc.setConfigSettings(RemoteConfigSettings(
        // 1-hour cache means updates propagate within an hour of publishing.
        fetchTimeout:         const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // 3. Fetch and activate in one atomic call.
      //    fetchAndActivate() returns true if new values were activated.
      final updated = await _rc.fetchAndActivate();
      debugPrint('[RemoteConfig] initialized — fresh values: $updated');
    } on FirebaseException catch (e) {
      // Remote Config quota exceeded or network error — defaults remain active.
      debugPrint('[RemoteConfig] init FirebaseException: ${e.message}');
    } catch (e) {
      debugPrint('[RemoteConfig] init unexpected error: $e');
    }
  }

  // ── Typed getters — safe, never throw ────────────────────────────────────

  String getString(String key) {
    try {
      final val = _rc.getString(key);
      return val.isNotEmpty ? val : _kDefaults[key] as String;
    } catch (_) {
      return _kDefaults[key] as String;
    }
  }

  bool getBool(String key) {
    try {
      // Remote Config stores booleans; fall back to default if key missing.
      return _rc.getBool(key);
    } catch (_) {
      return _kDefaults[key] as bool? ?? true;
    }
  }

  // ── Force refresh (e.g. called on app resume) ─────────────────────────────
  Future<void> fetchAndActivate() async {
    try {
      await _rc.fetchAndActivate();
    } catch (e) {
      debugPrint('[RemoteConfig] refresh failed: $e');
    }
  }
}
