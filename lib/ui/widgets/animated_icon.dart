import 'package:antinote_app/ui/utils/utils.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

class AnimatedIconWidget extends StatefulWidget {
  final IconData iconOn;
  final IconData iconOff;

  final bool value;

  final Color? colorOn;
  final Color? colorOff;

  final double size;

  const AnimatedIconWidget({
    super.key,

    required this.iconOn,
    required this.iconOff,

    required this.value,

    this.colorOn,
    this.colorOff,

    this.size = 24,
  });

  @override
  State<AnimatedIconWidget> createState() => _AnimatedIconWidgetState();
}

class _AnimatedIconWidgetState extends State<AnimatedIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _showOn;

  @override
  void initState() {
    super.initState();
    _showOn = widget.value;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedIconWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) _triggerAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerAnimation() async {
    await HapticFeedback.selectionClick();
    await _controller.reverse();

    if (!mounted) return;

    setState(() => _showOn = widget.value);
    await _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colorOn = widget.colorOn ?? context.c.primary;
    final colorOff = widget.colorOff ?? context.c.onSurfaceVariant;

    return FadeTransition(
      opacity: _controller,

      child: ScaleTransition(
        scale: Tween(begin: 0.5, end: 1.0).animate(_controller),

        child: Icon(
          _showOn ? widget.iconOn : widget.iconOff,

          color: _showOn ? colorOn : colorOff,
          size: widget.size,
        ),
      ),
    );
  }
}
