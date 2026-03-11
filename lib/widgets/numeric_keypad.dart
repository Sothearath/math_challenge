// lib/widgets/numeric_keypad.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

class NumericKeypad extends StatelessWidget {
  final void Function(String) onKey;

  const NumericKeypad({super.key, required this.onKey});

  static const List<String> _keys = [
    '7', '8', '9',
    '4', '5', '6',
    '1', '2', '3',
    '⌫', '0', '✓',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: _keys.length,
      itemBuilder: (context, index) {
        final key = _keys[index];
        final isDelete = key == '⌫';
        final isConfirm = key == '✓';

        Color bgColor;
        Color fgColor;

        if (isConfirm) {
          bgColor = primary;
          fgColor = isDark ? AppColors.darkBg : Colors.white;
        } else if (isDelete) {
          bgColor = isDark
              ? AppColors.neonPink.withOpacity(0.15)
              : AppColors.accentRed.withOpacity(0.1);
          fgColor = isDark ? AppColors.neonPink : AppColors.accentRed;
        } else {
          bgColor = isDark ? AppColors.darkCard : AppColors.lightCard;
          fgColor = isDark ? Colors.white : Colors.black87;
        }

        return _KeyButton(
          label: key,
          bgColor: bgColor,
          fgColor: fgColor,
          onTap: () => onKey(key),
        );
      },
    );
  }
}

class _KeyButton extends StatefulWidget {
  final String label;
  final Color bgColor;
  final Color fgColor;
  final VoidCallback onTap;

  const _KeyButton({
    required this.label,
    required this.bgColor,
    required this.fgColor,
    required this.onTap,
  });

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.fgColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.fgColor,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
