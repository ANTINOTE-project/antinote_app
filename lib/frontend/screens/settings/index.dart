import "package:antinote_app/frontend/routing/routes.dart";
import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/customs/button.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

enum AppColor {
  coral(Color(0xff904a40)),
  blue(Color(0xFF1E88E5)),
  green(Color(0xFF43A047)),
  purple(Color(0xFF8E24AA)),
  amber(Color(0xFFFFB300)),
  teal(Color(0xFF00897B));

  const AppColor(this.color);
  final Color color;

  String label(AppLocalizations l10n) => switch (this) {
    AppColor.coral => l10n.themeCoral,
    AppColor.blue => l10n.themeBlue,
    AppColor.green => l10n.themeGreen,
    AppColor.purple => l10n.themePurple,
    AppColor.amber => l10n.themeAmber,
    AppColor.teal => l10n.themeTeal,
  };
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),

      body: SingleChildScrollView(
        padding: const .symmetric(horizontal: 12),

        child: Column(
          crossAxisAlignment: .start,
          spacing: 12,

          children: [
            _TextIcon(
              icon: HugeIconsSolid.paintBoard,
              label: context.l10n.themeSeed,
            ),

            const _ColorPicker(),

            _TextIcon(
              icon: HugeIconsSolid.colors,
              label: context.l10n.themePreview,
            ),

            const _PreviewColor(),

            _TextIcon(
              icon: HugeIconsSolid.userAccount,
              label: context.l10n.settingsAccounts,
            ),

            ButtonWidget(
              onPressed: () => context.push(Routes.auth.accounts),
              label: context.l10n.settingsChangeAccount,
            ),
          ],
        ),
      ),
    );
  }
}

class _TextIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TextIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(left: 6, top: 12),

      child: Row(
        spacing: 8,

        children: [
          Icon(icon, color: context.c.outline, size: 22),

          Text(
            label,
            style: TextStyle(
              color: context.c.outline,
              fontWeight: .bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPicker extends StatefulWidget {
  const _ColorPicker();

  @override
  State<_ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<_ColorPicker> {
  late Color _activeColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeColor = context.tn.seedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: .all(color: context.c.outlineVariant),
        color: context.c.surfaceContainer,
        borderRadius: .circular(20),
      ),

      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),

        itemCount: AppColor.values.length,
        padding: const .all(8),

        itemBuilder: (context, index) {
          final appColor = AppColor.values[index];
          final label = appColor.label(context.l10n);
          final color = appColor.color;
          final isSelected = color == _activeColor;

          return Column(
            mainAxisAlignment: .center,
            spacing: 4,

            children: [
              Pressable(
                hasVisuals: false,

                onPressed: () async {
                  setState(() {
                    _activeColor = color;
                  });

                  await context.tn.setSeedColor(color);
                },

                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),

                  switchInCurve: Curves.elasticOut,
                  switchOutCurve: Curves.easeInBack,

                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [...previousChildren, ?currentChild],
                    );
                  },

                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },

                  child: Container(
                    key: ValueKey(isSelected),

                    height: 64,
                    width: 64,

                    decoration: BoxDecoration(
                      borderRadius: .circular(14),
                      color: color,
                    ),

                    foregroundDecoration: BoxDecoration(
                      borderRadius: .circular(14),

                      border: Border.all(
                        color: isSelected
                            ? context.c.onPrimary
                            : context.c.outline,
                        width: isSelected ? 3 : 1,
                        strokeAlign: 1,
                      ),
                    ),

                    child: isSelected
                        ? Icon(
                            HugeIconsSolid.tick03,
                            size: 24,
                            color: context.c.onPrimary,
                          )
                        : null,
                  ),
                ),
              ),

              Text(
                label,
                overflow: .ellipsis,
                style: const TextStyle(fontWeight: .w800, fontSize: 15),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PreviewColor extends StatelessWidget {
  const _PreviewColor();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(16),
      width: double.infinity,

      decoration: BoxDecoration(
        border: .all(color: context.c.outlineVariant),
        color: context.c.surfaceContainer,
        borderRadius: .circular(20),
      ),

      child: Wrap(
        crossAxisAlignment: .center,
        alignment: .center,

        runSpacing: 12,
        spacing: 12,

        children: [
          Container(
            padding: const .symmetric(horizontal: 16, vertical: 8),

            decoration: BoxDecoration(
              color: context.c.primary,
              borderRadius: .circular(12),
            ),

            child: Text(
              context.l10n.themePrimary,
              style: TextStyle(color: context.c.onPrimary, fontWeight: .bold),
            ),
          ),

          Container(
            padding: const .symmetric(horizontal: 16, vertical: 8),

            decoration: BoxDecoration(
              color: context.c.secondary,
              borderRadius: .circular(12),
            ),

            child: Text(
              context.l10n.themeSecondary,
              style: TextStyle(color: context.c.onSecondary, fontWeight: .bold),
            ),
          ),

          Container(
            padding: const .symmetric(horizontal: 16, vertical: 8),

            decoration: BoxDecoration(
              color: context.c.tertiary,
              borderRadius: .circular(12),
            ),

            child: Text(
              context.l10n.themeTertiary,
              style: TextStyle(color: context.c.onTertiary, fontWeight: .bold),
            ),
          ),

          Container(
            padding: const .symmetric(horizontal: 16, vertical: 8),

            decoration: BoxDecoration(
              color: context.c.surfaceContainerHigh,
              borderRadius: .circular(12),
              border: .all(color: context.c.outlineVariant),
            ),

            child: Text(
              context.l10n.themeSurface,
              style: TextStyle(color: context.c.onSurface, fontWeight: .bold),
            ),
          ),

          Container(
            padding: const .symmetric(horizontal: 16, vertical: 8),

            decoration: BoxDecoration(
              color: context.c.error,
              borderRadius: .circular(12),
            ),

            child: Text(
              context.l10n.themeError,
              style: TextStyle(color: context.c.onError, fontWeight: .bold),
            ),
          ),
        ],
      ),
    );
  }
}
