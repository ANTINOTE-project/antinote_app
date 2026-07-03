import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";

class ButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  final String? label;
  final IconData? icon;

  final bool isSecondary;
  final bool isDangerous;
  final bool isLoading;
  final bool isEnabled;

  const ButtonWidget({
    super.key,
    required this.onPressed,

    this.label,
    this.icon,

    this.isSecondary = false,
    this.isDangerous = false,
    this.isLoading = false,
    this.isEnabled = true,
  });

  Future<void> _onPressed(BuildContext context) async {
    if (!isEnabled || isLoading) return;
    onPressed.call();
  }

  Color _getButtonColor(BuildContext context) {
    return switch ((isEnabled, isDangerous, isSecondary)) {
      (false, _, _) => context.c.onInverseSurface,
      (_, true, _) => context.c.errorContainer,
      (_, _, true) => context.c.surfaceContainerHigh,
      _ => context.c.primary,
    };
  }

  Color _getTextColor(BuildContext context) {
    return switch ((isEnabled, isDangerous)) {
      (false, _) => context.c.outline,
      (_, true) => context.c.error,
      _ => context.c.onPrimary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: const .all(.circular(16)),

      onPressed: () => _onPressed(context),
      hasFeedback: isEnabled || isLoading,

      child: Ink(
        padding: const .symmetric(horizontal: 16, vertical: 8),

        width: double.infinity,
        height: 48,

        decoration: BoxDecoration(
          color: _getButtonColor(context),
          borderRadius: const .all(.circular(16)),
        ),

        child: Center(
          child: isLoading
              ? const LoadingWidget(size: 24)
              : Row(
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
