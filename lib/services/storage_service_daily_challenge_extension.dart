// lib/services/storage_service_daily_challenge_ext.dart
//
// Additive extension on StorageService for the Daily Challenge 3-state
// calendar (notStarted / inProgress / completed / missed).
//
// Deliberately kept as a standalone extension rather than a patch to
// storage_service.dart, since that file wasn't available to edit directly —
// this reads/writes its own GetStorage keys and won't collide with any
// existing StorageService fields. If you'd rather fold these methods
// directly into StorageService for consistency with your other storage
// accessors, the bodies below can be copy-pasted in as-is (just drop the
// `on StorageService` extension wrapper and the GetStorage() lookups become
// whatever your box instance is called there).

import 'package:get_storage/get_storage.dart';

import '../models/daily_challenge_status.dart';
import 'storage_service.dart';

extension DailyChallengeStorageX on StorageService {
  static const String _statusKeyPrefix = 'daily_challenge_status_';
  static const String _progressKeyPrefix = 'daily_challenge_progress_';
  static const String _heartsKeyPrefix = 'daily_challenge_hearts_';
  static const String _historyKey = 'daily_challenge_history';

  // ── Per-day status (notStarted / inProgress / completed / missed) ───────
  DailyChallengeStatus statusFor(String dateStr) {
    final raw = GetStorage().read('$_statusKeyPrefix$dateStr') as String?;
    return DailyChallengeStatus.fromStorageString(raw);
  }

  void setStatusFor(String dateStr, DailyChallengeStatus status) {
    GetStorage().write('$_statusKeyPrefix$dateStr', status.toStorageString());
  }

  // ── Resume progress (question index within today's attempt) ─────────────
  int progressFor(String dateStr) {
    return GetStorage().read('$_progressKeyPrefix$dateStr') as int? ?? 0;
  }

  void setProgressFor(String dateStr, int questionIndex) {
    GetStorage().write('$_progressKeyPrefix$dateStr', questionIndex);
  }

  // ── Resume hearts (lives remaining within today's attempt) ───────────────
  // Defaults to 3 (full hearts) when nothing has been persisted yet — i.e.
  // the attempt hasn't taken any damage, not that it was ever saved at 0.
  int heartsFor(String dateStr) {
    return GetStorage().read('$_heartsKeyPrefix$dateStr') as int? ?? 3;
  }

  void setHeartsFor(String dateStr, int hearts) {
    GetStorage().write('$_heartsKeyPrefix$dateStr', hearts);
  }

  // ── Full history map for the calendar grid ───────────────────────────────
  Map<String, DailyChallengeRecord> get dailyChallengeHistory {
    final raw = GetStorage().read(_historyKey);
    if (raw == null) return <String, DailyChallengeRecord>{};
    final decoded = Map<String, dynamic>.from(raw as Map);
    return decoded.map(
          (dateStr, value) => MapEntry(
        dateStr,
        DailyChallengeRecord.fromJson(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }

  void saveDailyChallengeHistoryEntry(String dateStr, DailyChallengeRecord record) {
    final current = dailyChallengeHistory;
    current[dateStr] = record;
    GetStorage().write(
      _historyKey,
      current.map((dateStr, record) => MapEntry(dateStr, record.toJson())),
    );
  }
}