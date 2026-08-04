// lib/features/game/models/daily_challenge_status.dart
//
// Status model for the Daily Challenge calendar's 3-state system:
// completed / quit-half-way (in progress, abandoned) / missed.
//
// See: daily-challenge-calendar-state-spec.md §0 for the full rationale.

/// Per-day status for a single Daily Challenge attempt.
enum DailyChallengeStatus {
  /// No attempt made yet for this date.
  notStarted,

  /// Game screen was opened for this date but the user backgrounded/quit
  /// before finishing. Only meaningful for *today* while it's still "today";
  /// once the date rolls over, an unresolved inProgress entry should be
  /// converted to [missed] (see DailyChallengeController._checkLockoutStatus).
  inProgress,

  /// Finished — perfect or not. XP/star already awarded.
  completed,

  /// The date has passed with no completed attempt (was notStarted or
  /// inProgress when the day rolled over).
  missed;

  /// Serialize for GetStorage (stored as plain strings, one per date key).
  String toStorageString() => name;

  static DailyChallengeStatus fromStorageString(String? raw) {
    return DailyChallengeStatus.values.firstWhere(
          (s) => s.name == raw,
      orElse: () => DailyChallengeStatus.notStarted,
    );
  }
}

/// A single day's record in the history map, keyed by yyyy-MM-dd.
class DailyChallengeRecord {
  final DailyChallengeStatus status;
  final bool isPerfect;
  final int score;
  final int xpEarned;

  const DailyChallengeRecord({
    required this.status,
    this.isPerfect = false,
    this.score = 0,
    this.xpEarned = 0,
  });

  Map<String, dynamic> toJson() => {
    'status': status.toStorageString(),
    'isPerfect': isPerfect,
    'score': score,
    'xpEarned': xpEarned,
  };

  factory DailyChallengeRecord.fromJson(Map<String, dynamic> json) {
    return DailyChallengeRecord(
      status: DailyChallengeStatus.fromStorageString(json['status'] as String?),
      isPerfect: json['isPerfect'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      xpEarned: json['xpEarned'] as int? ?? 0,
    );
  }

  static const notStartedRecord =
  DailyChallengeRecord(status: DailyChallengeStatus.notStarted);
}