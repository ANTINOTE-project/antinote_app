import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

class Pressable extends StatelessWidget {
  final Widget child;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final bool hasFeedback;
  final bool hasVibration;
  final bool hasVisuals;

  final HitTestBehavior behavior;
  final BorderRadius? borderRadius;

  const Pressable({
    super.key,

    required this.child,

    this.onPressed,
    this.onLongPress,

    this.hasFeedback = true,
    this.hasVibration = true,
    this.hasVisuals = true,

    this.behavior = HitTestBehavior.deferToChild,
    this.borderRadius,
  });

  void _onTapDown() async {
    if (!hasFeedback || !hasVibration) return;

    await HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: borderRadius,

      child: InkWell(
        onTap: onPressed,
        onLongPress: onLongPress,
        onTapDown: hasFeedback && (onPressed != null || onLongPress != null)
            ? (_) => _onTapDown()
            : null,

        highlightColor: hasFeedback && hasVisuals ? null : Colors.transparent,
        splashFactory: hasFeedback && hasVisuals
            ? null
            : NoSplash.splashFactory,

        borderRadius: borderRadius,

        child: child,
      ),
    );
  }
}
