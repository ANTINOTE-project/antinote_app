import "package:flutter/material.dart";
import "package:vibration/vibration.dart";

class Pressable extends StatefulWidget {
  final Widget child;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final bool hasFeedback;
  final bool hasAnimation;
  final bool hasVibration;

  final HitTestBehavior behavior;

  const Pressable({
    super.key,

    required this.child,

    this.onPressed,
    this.onLongPress,

    this.hasFeedback = true,
    this.hasAnimation = true,
    this.hasVibration = true,

    this.behavior = HitTestBehavior.deferToChild,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    )..value = 1.0;

    _scale = Tween<double>(
      begin: 0.97,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await Future.delayed(const Duration(milliseconds: 50));
    widget.onPressed?.call();
  }

  void _onTapDown() async {
    if (!widget.hasFeedback) return;

    if (widget.hasAnimation) {
      _controller.reverse();
    }

    if (widget.hasVibration) {
      await Vibration.vibrate(duration: 7);
    }
  }

  void _onTapUp() async {
    if (!widget.hasFeedback || !widget.hasAnimation) return;

    if (_controller.value > 0.3) {
      await _controller.reverse();
    }

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed == null ? null : _onTap,
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapUp,
      onLongPress: widget.onLongPress,

      behavior: widget.behavior,

      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
