// lib/core/ad_config/data/repositories/ad_config_repository_impl.dart
//
// Implements the domain contract using RemoteConfigDataSource.
// Maps raw string/bool values → AdConfigEntity.
// The only file that knows about both layers.

import '../remote_config_datasource.dart';
import 'ad_config_entity.dart';
import 'ad_config_repository.dart';

class AdConfigRepositoryImpl implements AdConfigRepository {
  final RemoteConfigDataSource _dataSource;

  AdConfigRepositoryImpl({required RemoteConfigDataSource dataSource})
      : _dataSource = dataSource;

  // ── AdConfigRepository contract ───────────────────────────────────────────

  @override
  AdConfigEntity getAdConfig() {
    try {
      return AdConfigEntity(
        rewardedUnitIdAndroid: _dataSource.getString(
            RemoteConfigKeys.rewardedUnitIdAndroid),
        rewardedUnitIdIos: _dataSource.getString(
            RemoteConfigKeys.rewardedUnitIdIos),
        adsEnabled: _dataSource.getBool(RemoteConfigKeys.adsEnabled),
      );
    } catch (_) {
      // If anything goes wrong mapping values, return the safe fallback.
      return AdConfigEntity.fallback();
    }
  }

  @override
  Future<void> refresh() => _dataSource.fetchAndActivate();
}
