// lib/widgets/numeric_keypad.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NumericKeypad extends StatelessWidget {
  final void Function(String) onKey;

  const NumericKeypad({super.key, required this.onKey});

  static const List<String> _keys = [
    '7','8','9',
    '4','5','6',
    '1','2','3',
    '⌫','0','✓',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.7,
      ),
      itemCount: _keys.length,
      itemBuilder: (context, i) {
        final key = _keys[i];
        final isDelete  = key == '⌫';
        final isConfirm = key == '✓';

        Color bg, fg, shadow;
        if (isConfirm) {
          bg     = AppColors.duoGreen;
          fg     = Colors.white;
          shadow = AppColors.duoGreenDark;
        } else if (isDelete) {
          bg     = isDark ? const Color(0xFF3A2A2A) : const Color(0xFFFFE4E4);
          fg     = AppColors.heartRed;
          shadow = isDark ? const Color(0xFF2A1A1A) : AppColors.heartRedDark.withOpacity(0.4);
        } else {
          bg     = isDark ? AppColors.darkCard : Colors.white;
          fg     = isDark ? Colors.white : const Color(0xFF2D2D2D);
          shadow = isDark ? AppColors.darkBg : AppColors.lightBorder;
        }

        return _KeyButton(label: key, bg: bg, fg: fg, shadow: shadow, onTap: () => onKey(key));
      },
    );
  }
}

class _KeyButton extends StatefulWidget {
  final String label;
  final Color bg, fg, shadow;
  final VoidCallback onTap;

  const _KeyButton({required this.label, required this.bg, required this.fg,
      required this.shadow, required this.onTap});

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;
  static const _sh = 3.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        margin: EdgeInsets.only(bottom: _pressed ? _sh : 0),
        decoration: BoxDecoration(
          color: widget.shadow,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 70),
          margin: EdgeInsets.only(bottom: _pressed ? 0 : _sh),
          decoration: BoxDecoration(
            color: widget.bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: widget.shadow, width: 1.5),
          ),
          child: Center(
            child: Text(widget.label,
              style: TextStyle(color: widget.fg, fontSize: 22, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }
}
