import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../models/daily_challenge_status.dart';
import '../../theme/app_theme.dart';

/// Local amber tokens for the "quit half-way" state.
///
/// TODO(design-system): these belong in AppColors alongside `mint`/`cobalt`
/// for consistency with the "centralized constants" convention — kept local
/// here only because app_colors.dart wasn't available to patch directly.
class _HalfwayColors {
  static const bg = Color(0xFFFFF3E0);
  static const border = Color(0xFFFFA726);
  static const icon = Color(0xFFFF8F00);
}

class DailyChallengeHistoryView extends StatelessWidget {
  final bool hasPlayedToday;

  /// True when today's attempt was started but not finished. Drives the
  /// dock CTA into "Continue Challenge" instead of "Play Today's Challenge".
  final bool isInProgress;

  /// dateStr (yyyy-MM-dd) -> record, used to render the completed / quit
  /// half-way / missed states across the whole grid, not just today.
  final Map<String, DailyChallengeRecord> history;

  final VoidCallback onPlayPressed;

  /// Called when the user taps "Continue Challenge" while isInProgress.
  /// Falls back to onPlayPressed if not provided.
  final VoidCallback? onContinuePressed;

  const DailyChallengeHistoryView({
    super.key,
    required this.hasPlayedToday,
    required this.history,
    this.isInProgress = false,
    required this.onPlayPressed,
    this.onContinuePressed,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstOfMonth = DateTime(now.year, now.month, 1);
    final int totalDays = DateUtils.getDaysInMonth(now.year, now.month);
    // DateTime.weekday is 1=Mon..7=Sun; grid header starts on Sunday, so
    // convert to a 0=Sun..6=Sat offset for the leading blank cells.
    final int startingWeekday = firstOfMonth.weekday % 7;
    final int currentDayIndex = now.day;

    final int completedCount =
        history.values.where((r) => r.status == DailyChallengeStatus.completed).length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header block
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.32,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Daily Challenges',
                          style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
                          ),
                          child: const Text('🏆', style: TextStyle(fontSize: 54)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content body & calendar
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _monthYearLabel(now),
                        style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.cobalt),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD54F), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              '$completedCount/$totalDays',
                              style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w900, color: const Color(0xFFFF8F00)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                      return SizedBox(
                        width: 40,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.withOpacity(0.70)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: totalDays + startingWeekday,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      if (index < startingWeekday) return const SizedBox.shrink();

                      final int displayDay = index - startingWeekday + 1;
                      final bool isToday = displayDay == currentDayIndex;
                      final bool isFuture = displayDay > currentDayIndex;
                      final String dateStr = _dateStringFor(now, displayDay);
                      final DailyChallengeRecord record =
                          history[dateStr] ?? DailyChallengeRecord.notStartedRecord;

                      return _CalendarCell(
                        displayDay: displayDay,
                        isToday: isToday,
                        isFuture: isFuture,
                        status: isToday && isInProgress && record.status != DailyChallengeStatus.completed
                            ? DailyChallengeStatus.inProgress
                            : record.status,
                        onTap: isFuture
                            ? null
                            : () => _handleDayTap(context, dateStr, displayDay, isToday, record),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Dock CTA
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 12),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasPlayedToday ? Colors.grey.shade400 : AppColors.cobalt,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                ),
                onPressed: hasPlayedToday
                    ? null
                    : (isInProgress ? (onContinuePressed ?? onPlayPressed) : onPlayPressed),
                child: Text(
                  _dockButtonLabel(),
                  style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dockButtonLabel() {
    if (hasPlayedToday) return 'Challenge Completed! 🎉';
    if (isInProgress) return 'Continue Challenge';
    return "Play Today's Challenge";
  }

  String _monthYearLabel(DateTime now) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  String _dateStringFor(DateTime now, int day) {
    final d = DateTime(now.year, now.month, day);
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _handleDayTap(
      BuildContext context,
      String dateStr,
      int displayDay,
      bool isToday,
      DailyChallengeRecord record,
      ) {
    // Today, unplayed/in-progress -> no sheet, the dock CTA already handles it.
    if (isToday && record.status != DailyChallengeStatus.completed) return;

    final effectiveStatus = isToday && isInProgress && record.status != DailyChallengeStatus.completed
        ? DailyChallengeStatus.inProgress
        : record.status;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => _DayDetailSheet(
        dayLabel: '${_monthYearLabel(DateTime.now()).split(' ').first} $displayDay',
        status: effectiveStatus,
        record: record,
        showPlayTodayCta: !hasPlayedToday,
        onPlayToday: () {
          Get.back();
          onPlayPressed();
        },
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final int displayDay;
  final bool isToday;
  final bool isFuture;
  final DailyChallengeStatus status;
  final VoidCallback? onTap;

  const _CalendarCell({
    required this.displayDay,
    required this.isToday,
    required this.isFuture,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == DailyChallengeStatus.completed;

    // "Quit half-way" styling applies whenever status == inProgress — for
    // today that's the live in-progress state; for past days the controller
    // rolls a stale inProgress into `missed` on day-rollover per the spec,
    // so this branch naturally stops applying once a day is in the past.
    final bool showHalfwayStyle = status == DailyChallengeStatus.inProgress;

    Color fill = Colors.transparent;
    Color border = Colors.transparent;
    Widget content;

    if (isCompleted) {
      fill = AppColors.mint.withOpacity(0.12);
      border = AppColors.mint;
      content = const Icon(Icons.check_rounded, color: AppColors.mint, size: 20);
    } else if (showHalfwayStyle) {
      fill = _HalfwayColors.bg;
      border = _HalfwayColors.border;
      content = const Icon(Icons.pause_circle_outline_rounded, color: _HalfwayColors.icon, size: 18);
    } else if (isToday) {
      fill = AppColors.cobalt;
      border = AppColors.cobalt;
      content = Text(
        '$displayDay',
        style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
      );
    } else {
      content = Text(
        '$displayDay',
        style: GoogleFonts.nunito(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.black.withOpacity(isFuture ? 0.25 : 0.35),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 2),
        ),
        child: content,
      ),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  final String dayLabel;
  final DailyChallengeStatus status;
  final DailyChallengeRecord record;
  final bool showPlayTodayCta;
  final VoidCallback onPlayToday;

  const _DayDetailSheet({
    required this.dayLabel,
    required this.status,
    required this.record,
    required this.showPlayTodayCta,
    required this.onPlayToday,
  });

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color iconColor;
    late final String title;
    late final String body;

    switch (status) {
      case DailyChallengeStatus.completed:
        icon = Icons.emoji_events_rounded;
        iconColor = AppColors.mint;
        title = 'Nice work on $dayLabel!';
        body = record.isPerfect
            ? 'Perfect round — you earned +${record.xpEarned} XP.'
            : 'Challenge completed — you earned +${record.xpEarned} XP.';
        break;
      case DailyChallengeStatus.inProgress:
        icon = Icons.pause_circle_outline_rounded;
        iconColor = _HalfwayColors.icon;
        title = 'Started, Not Finished';
        body = "You started this challenge but didn't finish it. That's okay — "
            "today's challenge is ready and waiting!";
        break;
      case DailyChallengeStatus.missed:
      case DailyChallengeStatus.notStarted:
        icon = Icons.calendar_today_rounded;
        iconColor = Colors.black.withOpacity(0.35);
        title = 'No Challenge Played';
        body = "You didn't play on $dayLabel — every day is a fresh start!";
        break;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.cobalt),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black.withOpacity(0.6)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: status == DailyChallengeStatus.completed
                  ? OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cobalt, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.cobalt),
                ),
              )
                  : showPlayTodayCta
                  ? ElevatedButton(
                onPressed: onPlayToday,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cobalt,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                ),
                child: Text(
                  "Play Today's Challenge",
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              )
                  : OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cobalt, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.cobalt),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}