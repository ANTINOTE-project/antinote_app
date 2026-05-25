import "package:antinote_app/frontend/extensions/colors.dart";
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
  final BorderRadius borderRadius;

  const Pressable({
    super.key,

    required this.child,

    this.onPressed,
    this.onLongPress,

    this.hasFeedback = true,
    this.hasAnimation = true,
    this.hasVibration = true,

    this.behavior = HitTestBehavior.deferToChild,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _brightness;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    )..value = 1;

    _brightness = Tween<double>(
      begin: 0.15,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await Future.delayed(const Duration(milliseconds: 50));

    if (!mounted) return;

    widget.onPressed?.call();
  }

  void _onTapDown() async {
    if (!widget.hasFeedback) return;

    if (widget.hasAnimation) {
      _controller.reverse();
    }

    if (widget.hasVibration && mounted) {
      await Vibration.vibrate(duration: 7);
    }
  }

  void _onTapUp() async {
    if (!widget.hasFeedback || !widget.hasAnimation) return;

    await _controller.reverse().orCancel.catchError((_) {});
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

      child: ClipRRect(
        borderRadius: widget.borderRadius,

        child: Stack(
          children: [
            widget.child,

            Positioned.fill(
              child: FadeTransition(
                opacity: _brightness,
                child: ColoredBox(color: context.c.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
