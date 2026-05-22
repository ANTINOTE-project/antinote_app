import "package:antinote_app/frontend/app.dart";
import "package:antinote_app/frontend/theme/app.dart";
import "package:antinote_app/frontend/widgets/animated/icon.dart";
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

  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.easeInOut;

  Future<void> _onPressed(BuildContext context) async {
    if (!isEnabled || isLoading) return;
    onPressed.call();
  }

  Color _getButtonColor(BuildContext context) {
    return switch ((isEnabled, isDangerous, isSecondary)) {
      (false, _, _) => AppTheme.onInverseSurface,
      (_, true, _) => AppTheme.errorContainer,
      (_, _, true) => AppTheme.surfaceContainerHigh,
      _ => AppTheme.primary,
    };
  }

  Color _getTextColor(BuildContext context) {
    return isEnabled ? AppTheme.onPrimary : AppTheme.outline;
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: () => _onPressed(context),
      hasFeedback: isEnabled || isLoading,

      child: AnimatedContainer(
        duration: _duration,
        curve: _curve,

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        width: double.infinity,
        height: 48,

        decoration: BoxDecoration(color: _getButtonColor(context), borderRadius: App.borderRadius),

        child: Center(
          child: AnimatedSwitcher(
            duration: _duration,

            switchInCurve: _curve,
            switchOutCurve: _curve,

            layoutBuilder: (currentChild, previousChildren) {
              return Stack(alignment: Alignment.center, children: [...previousChildren, ?currentChild]);
            },

            transitionBuilder: (child, animation) {
              final isIncoming = animation.status != AnimationStatus.reverse;

              final slideAnimation = Tween<Offset>(
                begin: isIncoming ? const Offset(0, 0.5) : const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

              final fadeAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

              final scaleAnimation = Tween<double>(
                begin: 0.6,
                end: 1.0,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(
                  position: slideAnimation,
                  child: ScaleTransition(scale: scaleAnimation, child: child),
                ),
              );
            },

            child: _buildChild(context),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    return isLoading ? _buildLoading() : _buildIconAndLabel(context);
  }

  Widget _buildLoading() {
    return const LoadingWidget(size: 24);
  }

  Widget _buildIconAndLabel(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 6,
      children: [_buildIcon(context), _buildLabel(context)],
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (icon == null) return const SizedBox.shrink();

    return IconWidget(iconOn: icon!, iconOff: icon!, colorOn: _getTextColor(context), value: true);
  }

  Widget _buildLabel(BuildContext context) {
    if (label == null) return const SizedBox.shrink();

    return AnimatedDefaultTextStyle(
      style: TextStyle(
        fontFamily: App.fontFamily,
        color: _getTextColor(context),
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),

      duration: _duration,
      curve: _curve,

      child: Text(label ?? ""),
    );
  }
}
