import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, tertiary, dangerous }

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  final String? label;
  final IconData? icon;

  final ButtonVariant variant;
  final bool enabled;

  const ButtonWidget({
    super.key,
    required this.onPressed,

    this.label,
    this.icon,

    this.variant = .primary,
    this.enabled = true,
  });

  bool get notEnabled => !enabled;

  Future<void> _onPressed() async {
    if (notEnabled) return;
    onPressed.call();
  }

  Color _getButtonColor(BuildContext context) {
    if (notEnabled) return context.c.onInverseSurface;

    return switch (variant) {
      .dangerous => context.c.errorContainer,
      .tertiary => context.c.tertiaryContainer,
      .secondary => context.c.secondaryContainer,
      .primary => context.c.primaryContainer,
    };
  }

  Color _getBorderColor(BuildContext context) {
    if (notEnabled) return context.c.outlineVariant;

    return switch (variant) {
      .dangerous => context.c.onError,
      .secondary => context.c.onSecondary,
      .tertiary => context.c.onTertiary,
      .primary => context.c.onPrimary,
    };
  }

  Color _getTextColor(BuildContext context) {
    if (notEnabled) return context.c.outline;

    return switch (variant) {
      .dangerous => context.c.error,
      .secondary => context.c.onSecondaryContainer,
      .tertiary => context.c.onTertiaryContainer,
      .primary => context.c.onPrimaryContainer,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: _onPressed,

      borderRadius: .circular(8),
      hasFeedback: enabled,

      child: Ink(
        padding: const .symmetric(horizontal: 16, vertical: 8),

        width: double.infinity,
        height: 50,

        decoration: BoxDecoration(
          border: .all(color: _getBorderColor(context)),
          color: _getButtonColor(context),
          borderRadius: .circular(8),
        ),

        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,

            children: [
              if (icon != null)
                Icon(icon!, color: _getTextColor(context), size: 24)
              else
                const SizedBox.shrink(),

              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    color: _getTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
