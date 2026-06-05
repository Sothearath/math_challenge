// lib/features/profile/views/profile_view.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:math_challenge/views/profile/profile_controller.dart';

import '../../core/constants.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brainy_painter.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: double.infinity),
        decoration: AppTheme.gradientBackground,
        child: SafeArea(
          child: Obx(() {
            // Full-screen loading overlay
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.cobalt),
              );
            }
            return Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      children: [
                        _buildMascotCard(),
                        const SizedBox(height: 16),
                        _buildStatGrid(),
                        const SizedBox(height: 24),
                        // _buildSignOutButton(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Back button — frosted glass pill matching dashboard style
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.30),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(color: Colors.white.withOpacity(0.55)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppColors.cobalt, size: 18),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Text(
              'My Profile',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.cobalt,
              ),
            ),
          ),

          // Edit / Done toggle
          Obx(() => GestureDetector(
            onTap: controller.toggleEdit,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: controller.isEditing.value
                    ? AppColors.cobalt
                    : Colors.white.withOpacity(0.30),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(
                  color: controller.isEditing.value
                      ? AppColors.cobaltDark
                      : Colors.white.withOpacity(0.55),
                ),
              ),
              child: Text(
                controller.isEditing.value ? 'Done' : 'Edit',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: controller.isEditing.value
                      ? Colors.white
                      : AppColors.cobalt,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ── Mascot card ───────────────────────────────────────────────────────────
  Widget _buildMascotCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.keyWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.cardShadows,
      ),
      child: Column(
        children: [
          // Brainy mascot
          SizedBox(
            width: 160,
            height: 170,
            child: CustomPaint(painter: BrainyPainter()),
          ),

          // Ground shadow anchoring Brainy to the card
          Container(
            width: 72,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: const BorderRadius.all(Radius.elliptical(72, 10)),
            ),
          ),
          const SizedBox(height: 16),

          // Username
          Obx(() => Text(
            '@${controller.username.value}',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.cobalt,
              letterSpacing: -0.5,
            ),
          )),
          const SizedBox(height: 6),

          // Level badge pill
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cobalt.withOpacity(0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusBadge),
              border: Border.all(color: AppColors.cobalt.withOpacity(0.25)),
            ),
            child: Text(
              'Level ${controller.currentLevel.value} Player',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.cobalt,
              ),
            ),
          )),

          // Error message
          Obx(() {
            if (controller.errorMsg.value.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                controller.errorMsg.value,
                style: GoogleFonts.nunito(
                    fontSize: 12, color: AppColors.heartDanger),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Stat grid — 3 cards in a row ──────────────────────────────────────────
  Widget _buildStatGrid() {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            iconColor: AppColors.sunflower,
            label: 'Total XP',
            value: _formatNumber(controller.totalXP.value),
            bgColor: AppColors.sunflower.withOpacity(0.10),
            borderColor: AppColors.sunflower.withOpacity(0.35),
            valueColor: AppColors.sunflower,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.cobalt,
            label: 'Top Level',
            value: '${controller.currentLevel.value}',
            bgColor: AppColors.cobalt.withOpacity(0.08),
            borderColor: AppColors.cobalt.withOpacity(0.25),
            valueColor: AppColors.cobalt,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.bolt_rounded,
            iconColor: AppColors.correctGreen,
            label: 'High Score',
            value: _formatNumber(controller.highScore.value),
            bgColor: AppColors.correctGreen.withOpacity(0.08),
            borderColor: AppColors.correctGreen.withOpacity(0.30),
            valueColor: AppColors.correctGreen,
          ),
        ),
      ],
    ));
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  // ── Sign out button ───────────────────────────────────────────────────────
  Widget _buildSignOutButton() {
    return _ChunkyButton(
      label: 'Sign Out',
      icon: Icons.logout_rounded,
      onTap: () => Get.dialog(_SignOutConfirmDialog(
        onConfirm: controller.signOut,
      )),
      isDestructive: true,
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   label;
  final String   value;
  final Color    bgColor;
  final Color    borderColor;
  final Color    valueColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.bgColor,
    required this.borderColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.keyWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: AppTheme.cardShadows,
      ),
      child: Column(
        children: [
          // Icon bubble
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),

          // Value — large bold number
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),

          // Label
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: AppColors.cobalt.withOpacity(0.45),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chunky 3D button ──────────────────────────────────────────────────────────
class _ChunkyButton extends StatefulWidget {
  final String      label;
  final IconData?   icon;
  final VoidCallback onTap;
  final bool        isDestructive;

  const _ChunkyButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.isDestructive = false,
  });

  @override
  State<_ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<_ChunkyButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double>   _scale;
  bool _pressed = false;

  static const double _depth = 5.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final faceColor   = widget.isDestructive
        ? AppColors.heartDanger
        : AppColors.cobalt;
    final shadowColor = widget.isDestructive
        ? const Color(0xFFCC1A0F)
        : AppColors.cobaltDark;

    return GestureDetector(
      onTapDown:   (_) { setState(() => _pressed = true);  _anim.forward(); },
      onTapUp:     (_) { setState(() => _pressed = false); _anim.reverse(); widget.onTap(); },
      onTapCancel: ()  { setState(() => _pressed = false); _anim.reverse(); },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          margin: EdgeInsets.only(bottom: _pressed ? _depth : 0),
          decoration: BoxDecoration(
            color: shadowColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            margin: EdgeInsets.only(bottom: _pressed ? 0 : _depth),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: faceColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusButton),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sign-out confirmation dialog ──────────────────────────────────────────────
class _SignOutConfirmDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const _SignOutConfirmDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.keyWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusDialog),
          boxShadow: AppTheme.cardShadows,
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded,
                color: AppColors.heartDanger, size: 40),
            const SizedBox(height: 14),
            Text(
              'Sign Out?',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.cobalt,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your progress is saved in the cloud.\nYou can always sign back in!',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.cobalt.withOpacity(0.60),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.cobalt,
                      side: BorderSide(
                          color: AppColors.cobalt.withOpacity(0.30)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusKey)),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            color: AppColors.cobalt)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.heartDanger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusKey)),
                    ),
                    child: Text('Sign Out',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
