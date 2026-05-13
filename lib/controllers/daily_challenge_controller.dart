// lib/controllers/daily_challenge_controller.dart
//
// Handles:
//  • Daily Challenge countdown (resets at midnight)
//  • Monthly "Greenhouse Event" countdown (fixed end-date)
//  • NumberSums grid mechanic (target-sum selection + pen/pencil toggle)

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'awards_controller.dart';
import 'heart_controller.dart';

// ─── Ticker helper ────────────────────────────────────────────────────────────

class _CountdownTicker {
  final DateTime endTime;
  Timer? _timer;
  final void Function(Duration remaining) onTick;
  final void Function() onDone;

  _CountdownTicker({
    required this.endTime,
    required this.onTick,
    required this.onDone,
  });

  void start() {
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = endTime.difference(DateTime.now());
    if (remaining.isNegative) {
      _timer?.cancel();
      onDone();
    } else {
      onTick(remaining);
    }
  }

  void dispose() => _timer?.cancel();
}

// ─── NumberSums Cell Model ────────────────────────────────────────────────────

class GridCell {
  final int     value;
  bool          isSelected;
  bool          isPencilMarked; // "notes" mode
  bool          isCorrect;      // highlight green after validation
  bool          isWrong;        // highlight red briefly

  GridCell({
    required this.value,
    this.isSelected    = false,
    this.isPencilMarked = false,
    this.isCorrect     = false,
    this.isWrong       = false,
  });
}

// ─── Controller ───────────────────────────────────────────────────────────────

class DailyChallengeController extends GetxController {
  AwardsController get _awards => Get.find<AwardsController>();

  // ── countdown observables ────────────────────────────────────────────────────
  final RxString dailyCountdown    = '00:00:00'.obs;
  final RxString eventCountdown    = '0d 00:00:00'.obs;
  final RxBool   dailyAvailable    = true.obs;
  final RxBool   eventActive       = true.obs;

  // ── grid mechanic ────────────────────────────────────────────────────────────
  final RxInt             targetSum    = 0.obs;
  final RxList<GridCell>  gridCells    = <GridCell>[].obs;
  final RxBool            isPencilMode = false.obs;   // false = Pen, true = Pencil
  final RxInt             selectedSum  = 0.obs;
  final RxBool            gridSolved   = false.obs;

  // Grid config
  static const int _gridSize = 5; // 5×5
  static const int _gridCount = _gridSize * _gridSize;

  // ── tickers ──────────────────────────────────────────────────────────────────
  _CountdownTicker? _dailyTicker;
  _CountdownTicker? _eventTicker;

  // ── lifecycle ────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _startDailyCountdown();
    _startEventCountdown();
    _generateGrid();
  }

  @override
  void onClose() {
    _dailyTicker?.dispose();
    _eventTicker?.dispose();
    super.onClose();
  }

  // ── countdown logic ──────────────────────────────────────────────────────────

  void _startDailyCountdown() {
    final now       = DateTime.now();
    final midnight  = DateTime(now.year, now.month, now.day + 1);

    _dailyTicker = _CountdownTicker(
      endTime: midnight,
      onTick: (rem) {
        final h = rem.inHours.toString().padLeft(2, '0');
        final m = (rem.inMinutes % 60).toString().padLeft(2, '0');
        final s = (rem.inSeconds % 60).toString().padLeft(2, '0');
        dailyCountdown.value = '$h:$m:$s';
      },
      onDone: () {
        dailyCountdown.value = '00:00:00';
        dailyAvailable.value = true;
        _startDailyCountdown(); // restart for next day
      },
    );
    _dailyTicker!.start();
  }

  void _startEventCountdown() {
    // "Greenhouse Event" ends on fixed date – adjust as needed
    final eventEnd = DateTime(DateTime.now().year, DateTime.now().month + 1, 1);

    _eventTicker = _CountdownTicker(
      endTime: eventEnd,
      onTick: (rem) {
        final d = rem.inDays;
        final h = (rem.inHours % 24).toString().padLeft(2, '0');
        final m = (rem.inMinutes % 60).toString().padLeft(2, '0');
        final s = (rem.inSeconds % 60).toString().padLeft(2, '0');
        eventCountdown.value = '${d}d $h:$m:$s';
      },
      onDone: () {
        eventActive.value   = false;
        eventCountdown.value = 'Event Ended';
      },
    );
    _eventTicker!.start();
  }

  // ── grid mechanic ────────────────────────────────────────────────────────────

  void _generateGrid() {
    gridSolved.value = false;
    selectedSum.value = 0;

    // Generate numbers 1–9 randomly
    final nums = List.generate(
      _gridCount,
      (_) => (DateTime.now().millisecondsSinceEpoch % 9 + 1),
    );
    // Randomise with a proper shuffle
    nums.shuffle();

    // Pick a random target (sum of 3-5 random cells)
    final solutionIndices = (List.generate(_gridCount, (i) => i)..shuffle())
        .take(4)
        .toList();
    targetSum.value = solutionIndices.fold(0, (s, i) => s + nums[i]);

    gridCells.assignAll(nums.map((v) => GridCell(value: v)).toList());
  }

  void regenerateGrid() => _generateGrid();

  void togglePencilMode() => isPencilMode.toggle();

  void onCellTap(int index) {
    HapticFeedback.mediumImpact();

    final cell = gridCells[index];

    if (isPencilMode.value) {
      // Notes mode: just toggle pencil mark, no sum change
      cell.isPencilMarked = !cell.isPencilMarked;
    } else {
      // Pen mode: toggle selection & update running sum
      cell.isSelected = !cell.isSelected;
      selectedSum.value = gridCells
          .where((c) => c.isSelected)
          .fold(0, (s, c) => s + c.value);
    }

    gridCells.refresh();
  }

  /// Validate the current selection against targetSum.
  void validateSelection() {
    if (selectedSum.value == targetSum.value) {
      // Mark correct
      for (final c in gridCells) {
        if (c.isSelected) c.isCorrect = true;
      }
      gridCells.refresh();
      gridSolved.value = true;
      _onChallengeCompleted();
    } else {
      // Flash wrong
      for (final c in gridCells) {
        if (c.isSelected) c.isWrong = true;
      }
      gridCells.refresh();

      Future.delayed(const Duration(milliseconds: 600), () {
        for (final c in gridCells) {
          c.isWrong    = false;
          c.isSelected = false;
        }
        selectedSum.value = 0;
        gridCells.refresh();
        // Deduct a life
        final heartCtrl = Get.find<HeartController>();
        heartCtrl.loseLife();
      });
    }
  }

  void _onChallengeCompleted() {
    _awards.markDailyChallengeComplete();
    // Optionally navigate to result screen or show a congrats overlay
    Get.snackbar(
      '🎉 Challenge Complete!',
      'You solved today\'s challenge. Come back tomorrow!',
      duration: const Duration(seconds: 3),
    );
  }
}

// Convenience import alias so GameController can resolve HeartController
// without a circular import – just add this line to main.dart:
//
//   Get.put(HeartController());
//
// The HeartController file is in heart_controller.dart.
