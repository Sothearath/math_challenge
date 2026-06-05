// lib/core/ad_config/bindings/ad_config_binding.dart
//
// Registers the full Remote Config → Repository → AdService chain.
// Call AdConfigBinding().dependencies() in your app's initial binding
// (or in main.dart before runApp) so AdService is available globally.
//
// Initialization order:
//   1. RemoteConfigDataSource.init()  — fetches & activates Remote Config
//   2. AdConfigRepositoryImpl         — registered after datasource is ready
//   3. AdService                      — registered last, reads from repository

import 'package:get/get.dart';
import '../../services/ad_service.dart';
import '../remote_config_datasource.dart';
import 'ad_config_repository.dart';
import 'ad_config_repository_impl.dart';

class AdConfigBinding extends Bindings {
  @override
  void dependencies() {
    // Step 1 — Data source (owns Firebase SDK)
    // Put as permanent so it survives route changes.
    final dataSource = RemoteConfigDataSource();
    Get.put<RemoteConfigDataSource>(dataSource, permanent: true);

    // Step 2 — Repository implementation (maps datasource → entity)
    Get.put<AdConfigRepository>(
      AdConfigRepositoryImpl(dataSource: dataSource),
      permanent: true,
    );

    // Step 3 — AdService (reads from repository, no Firebase dependency)
    Get.put<AdService>(
      AdService(adConfigRepo: Get.find<AdConfigRepository>()),
      permanent: true,
    );
  }
}

// ── Async initialization helper ───────────────────────────────────────────────
// Call this in main.dart AFTER Firebase.initializeApp() and BEFORE runApp()
// so Remote Config values are ready before any gameplay view loads.
//
// Usage in main.dart:
//
//   Future<void> main() async {
//     WidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp();
//     await initRemoteConfig();           // ← add this line
//     runApp(const MyApp());
//   }

Future<void> initRemoteConfig() async {
  final dataSource = RemoteConfigDataSource();
  await dataSource.init(); // fetch + activate before any UI renders

  // Register the full chain so Get.find<AdService>() works immediately
  Get.put<RemoteConfigDataSource>(dataSource, permanent: true);
  Get.put<AdConfigRepository>(
    AdConfigRepositoryImpl(dataSource: dataSource),
    permanent: true,
  );
  Get.put<AdService>(
    AdService(adConfigRepo: Get.find<AdConfigRepository>()),
    permanent: true,
  );
}


// ── pubspec.yaml additions ────────────────────────────────────────────────────
//
// dependencies:
//   firebase_remote_config: ^5.x.x   # check pub.dev for latest
//   google_mobile_ads:      ^5.x.x
//
// ── Firebase Console setup ────────────────────────────────────────────────────
//
// 1. Go to Firebase Console → Remote Config → Create configuration
// 2. Add these three parameters:
//
//    Key                          Type     Default value
//    ─────────────────────────────────────────────────────────────────────
//    ad_rewarded_unit_id_android  String   ca-app-pub-XXXX/XXXXXXXXXX
//    ad_rewarded_unit_id_ios      String   ca-app-pub-XXXX/XXXXXXXXXX
//    ads_enabled                  Boolean  true
//
// 3. Publish changes.
// 4. To disable ads globally: set ads_enabled = false and publish.
// 5. To swap ad IDs: update the string values and publish — no app update needed.
