// lib/widgets/chunky_button.dart
// 3-D "Duolingo-style" button that depresses on tap

import 'package:flutter/material.dart';

class ChunkyButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final VoidCallback onTap;
  final double height;
  final double fontSize;
  final Widget? icon;

  const ChunkyButton({
    super.key,
    required this.label,
    required this.color,
    required this.shadowColor,
    required this.textColor,
    required this.onTap,
    this.height = 56,
    this.fontSize = 17,
    this.icon,
  });

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;
  static const _shadowHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: widget.height + (_pressed ? 0 : _shadowHeight),
        margin: EdgeInsets.only(bottom: _pressed ? _shadowHeight : 0),
        decoration: BoxDecoration(
          color: widget.shadowColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: widget.height,
          margin: EdgeInsets.only(bottom: _pressed ? 0 : _shadowHeight),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
