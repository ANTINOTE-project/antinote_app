import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool hasFeedback;
  final bool hasVibration;
  final bool hasVisuals;
  final bool hasScale;
  final double scaleValue;
  final BorderRadius? borderRadius;

  const Pressable({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.hasFeedback = true,
    this.hasVibration = true,
    this.hasVisuals = true,
    this.hasScale = true,
    this.scaleValue = 0.97,
    this.borderRadius,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  bool get _canPress => widget.onPressed != null || widget.onLongPress != null;

  void _onTapDown() async {
    if (widget.hasScale && _canPress) setState(() => _pressed = true);
    if (!widget.hasFeedback || !widget.hasVibration) return;
    await HapticFeedback.selectionClick();
  }

  void _onTapEnd() {
    if (widget.hasScale && _pressed) setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? widget.scaleValue : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,

      child: Material(
        borderRadius: widget.borderRadius,
        type: .transparency,

        child: InkWell(
          onTap: widget.onPressed,
          onLongPress: widget.onLongPress,
          onTapDown: _canPress ? (_) => _onTapDown() : null,
          onTapUp: _canPress ? (_) => _onTapEnd() : null,
          onTapCancel: _canPress ? _onTapEnd : null,

          highlightColor: widget.hasFeedback && widget.hasVisuals
              ? null
              : Colors.transparent,
          splashFactory: widget.hasFeedback && widget.hasVisuals
              ? null
              : NoSplash.splashFactory,
          borderRadius: widget.borderRadius,

          child: widget.child,
        ),
      ),
    );
  }
}
