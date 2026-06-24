import "package:antinote_app/frontend/screens/settings/screen.dart";
import "package:antinote_app/frontend/widgets/customs/list.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class ColorPicker extends StatefulWidget {
  const ColorPicker();

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _activeColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _activeColor = context.s.theme.seedColor;
  }

  @override
  Widget build(BuildContext context) {
    final areColorsEnabled = !context.s.theme.isDynamic;

    return ListWidget.list(
      items: [
        ItemWidgetData(
          title: GridView.builder(
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

                    onPressed: areColorsEnabled
                        ? () async {
                            setState(() {
                              _activeColor = color;
                            });

                            await context.s.theme.setSeedColor(color);
                          }
                        : null,

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
                          color: areColorsEnabled
                              ? color
                              : color.withAlpha(128),
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
                    style: TextStyle(
                      fontWeight: .w800,
                      fontSize: 15,
                      color: areColorsEnabled
                          ? null
                          : context.c.onSurface.withAlpha(128),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ItemWidgetData(
          title: Text(context.l10n.deviceTheme),
          subtitle: Text(context.l10n.deviceThemeDescription, maxLines: 3),
          trailing: Switch(
            value: context.s.theme.isDynamic,
            onChanged: (value) async {
              await context.s.theme.setIsDynamic(value);

              if (context.mounted) {
                setState(() {});
              }
            },
          ),
        ),
      ],
    );
  }
}

class PreviewColor extends StatelessWidget {
  const PreviewColor();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
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
                style: TextStyle(
                  color: context.c.onSecondary,
                  fontWeight: .bold,
                ),
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
                style: TextStyle(
                  color: context.c.onTertiary,
                  fontWeight: .bold,
                ),
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
      ),
    );
  }
}
