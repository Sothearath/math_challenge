import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants.dart';
import '../../theme/app_theme.dart';

class DailyChallengeHistoryView extends StatelessWidget {
  final int currentStreak;
  final bool hasPlayedToday; // ⭐ 1. Added completion tracker flag
  final VoidCallback onPlayPressed;

  const DailyChallengeHistoryView({
    super.key,
    required this.currentStreak,
    required this.hasPlayedToday, // ⭐ 2. Require it in constructor
    required this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final int totalDays = 30;
    final int startingWeekday = 1; // June 1st, 2026 is a Monday (1)
    final int currentDayIndex = 17; // Today is June 17th

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🏆 1. Premium Dynamic Header Block
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

          // 📅 2. Content Body & Custom Calendar Structure
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
                        'June 2026',
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
                              '$currentStreak/$totalDays',
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

                      // ⭐ 3. Fixed logic: A day is completed if it matches streak offsets OR it's today and state says played!
                      final bool isCompleted = (displayDay <= 2) || (isToday && hasPlayedToday);

                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.mint.withOpacity(0.12)
                              : isToday
                              ? AppColors.cobalt
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.mint
                                : isToday
                                ? AppColors.cobalt
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, color: AppColors.mint, size: 20)
                            : Text(
                          '$displayDay',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w700,
                            color: isToday
                                ? Colors.white
                                : Colors.black.withOpacity(displayDay > currentDayIndex ? 0.25 : 0.8),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 📌 3. Reactive Primary Action Button Dock
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 12),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Soften button color if already completed to signify non-actionable state
                  backgroundColor: hasPlayedToday ? Colors.grey.shade400 : AppColors.cobalt,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusButton)),
                ),
                onPressed: hasPlayedToday ? null : onPlayPressed, // Disable click if taken
                child: Text(
                  // ⭐ 4. Dynamic Text representation matching gameplay states
                  hasPlayedToday ? 'Challenge Completed! 🎉' : 'Play Today\'s Challenge',
                  style: GoogleFonts.nunito(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}