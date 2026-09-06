import 'package:antinote_app/ui/screens/settings/screen.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class Appearance extends StatefulWidget {
  const Appearance({super.key});

  @override
  State<Appearance> createState() => _AppearanceState();
}

class _AppearanceState extends State<Appearance> {
  @override
  Widget build(BuildContext context) {
    final isDynamic = context.s.theme.isDynamic;
    final currentColorScheme = context.c;

    return SliverMainAxisGroup(
      slivers: [
        SliverTextIcon(
          icon: HugeIconsSolid.paintBoard,
          label: context.l10n.theme,
        ),

        ListWidget.list(
          items: [
            TileWidgetData(
              padding: .zero,

              title: SizedBox(
                height: 110,

                child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),

                  padding: const .symmetric(horizontal: 20, vertical: 14),

                  itemCount: AppColor.values.length,
                  scrollDirection: .horizontal,
                  shrinkWrap: true,

                  itemBuilder: (context, index) {
                    final appColor = AppColor.values[index];

                    final label = appColor.label(context.l10n);
                    final color = appColor.color;

                    final isSelected = color == context.s.theme.seedColor;

                    return Padding(
                      padding: .only(
                        right: index == AppColor.values.length - 1 ? 0 : 20,
                      ),

                      child: Column(
                        mainAxisAlignment: .center,
                        spacing: 4,

                        children: [
                          Pressable(
                            borderRadius: .circular(90),

                            onPressed: isDynamic
                                ? null
                                : () async {
                                    await context.s.theme.setSeedColor(color);
                                    if (mounted) setState(() {});
                                  },

                            child: Ink(
                              height: 48,
                              width: 48,

                              decoration: BoxDecoration(
                                borderRadius: .circular(90),
                                color: isDynamic ? color.withAlpha(128) : color,
                                border: isSelected
                                    ? .all(
                                        color: currentColorScheme.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                            ),
                          ),

                          Text(
                            label,
                            overflow: .ellipsis,
                            style: TextStyle(
                              fontWeight: .w600,
                              fontSize: 15,
                              color: isDynamic
                                  ? currentColorScheme.onSurface.withAlpha(128)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            TileWidgetData(
              title: Text(context.l10n.deviceTheme),
              subtitle: Text(context.l10n.deviceThemeDescription, maxLines: 3),

              onPressed: () async {
                await context.s.theme.setIsDynamic(!context.s.theme.isDynamic);
                if (context.mounted) setState(() {});
              },

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
        ),

        const SliverPadding(padding: .only(top: 12)),
      ],
    );
  }
}
