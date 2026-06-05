// lib/core/ad_config/domain/repositories/ad_config_repository.dart
//
// Abstract contract — the domain layer defines what it needs,
// not how it gets it. Nothing here imports Firebase.

import 'ad_config_entity.dart';

abstract class AdConfigRepository {
  /// Returns the current ad configuration.
  /// Must never throw — returns [AdConfigEntity.fallback()] on any error.
  AdConfigEntity getAdConfig();

  /// Forces a fresh fetch from Remote Config and activates the result.
  /// Safe to call at startup; silently falls back on network failures.
  Future<void> refresh();
}
