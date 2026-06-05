import "package:antinote_app/frontend/widgets/customs/app_bar.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/l10n/app_localizations.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

enum _AppColor {
  coral(Color(0xff904a40)),
  indigo(Color(0xff3F51B5)),
  green(Color(0xff2E7D32)),
  teal(Color(0xff00695C)),
  purple(Color(0xff6A1B9A)),
  pink(Color(0xffAD1457)),
  blue(Color(0xff1565C0));

  const _AppColor(this.color);
  final Color color;

  String label(AppLocalizations l10n) => switch (this) {
    _AppColor.coral => l10n.themeCoral,
    _AppColor.indigo => l10n.themeIndigo,
    _AppColor.green => l10n.themeGreen,
    _AppColor.teal => l10n.themeTeal,
    _AppColor.purple => l10n.themePurple,
    _AppColor.pink => l10n.themePink,
    _AppColor.blue => l10n.themeBlue,
  };
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(),
      body: SingleChildScrollView(child: Column(children: [_ColorPicker()])),
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
    return SizedBox(
      height: 100,

      child: ListView.builder(
        itemCount: _AppColor.values.length,
        scrollDirection: Axis.horizontal,

        padding: const .symmetric(horizontal: 12),

        itemBuilder: (context, index) {
          final appColor = _AppColor.values[index];

          final label = appColor.label(context.l10n);
          final color = appColor.color;

          final isSelected = color == _activeColor;

          return Padding(
            padding: const .only(right: 12),

            child: Column(
              spacing: 4,

              children: [
                Pressable(
                  borderRadius: .circular(999),

                  onPressed: () {
                    setState(() {
                      _activeColor = color;
                    });

                    context.tn.setSeedColor(color);
                  },

                  child: Ink(
                    height: 56,
                    width: 56,

                    decoration: BoxDecoration(
                      border: isSelected
                          ? .all(color: context.c.primary, width: 2)
                          : null,
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                ),

                Text(
                  label,
                  style: const TextStyle(fontWeight: .w800, fontSize: 15),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
