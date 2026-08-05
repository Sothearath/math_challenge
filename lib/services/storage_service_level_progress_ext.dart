// lib/services/storage_service_level_progress_ext.dart
//
// Additive extension on StorageService for resuming a standard Arithmetic
// Challenge level (1-15) after a mid-session quit — mirrors the Daily
// Challenge resume pattern in storage_service_daily_challenge_ext.dart,
// but scoped by levelNumber instead of a calendar date, since standard
// levels are replayable (not one-shot per day).
//
// Lifecycle for a given levelNumber:
//   1. First entry this session  -> setLevelInProgress(level, true)
//   2. Every wrong/correct answer -> setLevelHeartsFor / setLevelProgressFor
//   3. Quit mid-level             -> state above stays as-is, nothing to do
//   4. Re-entry while in progress -> read hearts/progress back, resume
//   5. Level concludes (win/loss/timeout) -> clearLevelProgress(level), so
//      the *next* attempt at this level starts fresh at full hearts.
//
// Kept standalone (not folded into storage_service.dart) for the same
// reason as the Daily Challenge extension: that file wasn't available to
// edit directly, and this way there's no risk of colliding with its
// existing fields.

import 'package:get_storage/get_storage.dart';

import 'storage_service.dart';

extension LevelProgressStorageX on StorageService {
  static const String _inProgressPrefix = 'level_challenge_inprogress_';
  static const String _heartsPrefix = 'level_challenge_hearts_';
  static const String _progressPrefix = 'level_challenge_progress_';

  bool levelInProgress(int levelNumber) {
    return GetStorage().read('$_inProgressPrefix$levelNumber') as bool? ?? false;
  }

  void setLevelInProgress(int levelNumber, bool value) {
    GetStorage().write('$_inProgressPrefix$levelNumber', value);
  }

  /// Defaults to 3 (full hearts) when nothing's been persisted yet.
  int levelHeartsFor(int levelNumber) {
    return GetStorage().read('$_heartsPrefix$levelNumber') as int? ?? 3;
  }

  void setLevelHeartsFor(int levelNumber, int hearts) {
    GetStorage().write('$_heartsPrefix$levelNumber', hearts);
  }

  int levelProgressFor(int levelNumber) {
    return GetStorage().read('$_progressPrefix$levelNumber') as int? ?? 0;
  }

  void setLevelProgressFor(int levelNumber, int questionIndex) {
    GetStorage().write('$_progressPrefix$levelNumber', questionIndex);
  }

  /// Call when a level session concludes (win, loss, or timeout) so the
  /// *next* attempt at this level starts fresh instead of silently
  /// resuming a finished session.
  void clearLevelProgress(int levelNumber) {
    GetStorage().remove('$_inProgressPrefix$levelNumber');
    GetStorage().remove('$_heartsPrefix$levelNumber');
    GetStorage().remove('$_progressPrefix$levelNumber');
  }
}