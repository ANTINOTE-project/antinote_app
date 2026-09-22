import 'package:antinote_app/ui/utils/utils.dart';
import 'package:material_ui/material_ui.dart';

class TextIcon extends StatelessWidget {
  final IconData? icon;
  final String label;
  final EdgeInsetsGeometry padding;

  const TextIcon({
    super.key,
    this.icon,
    required this.label,
    this.padding = const .only(left: 6, bottom: 6),
  });

  factory TextIcon.sliver({
    Key? key,
    IconData? icon,
    required String label,
    EdgeInsetsGeometry padding = const .only(left: 6, bottom: 6),
  }) {
    return _SliverTextIcon(
      key: key,
      icon: icon,
      label: label,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,

      child: Row(
        spacing: 6,

        children: [
          if (icon != null) Icon(icon, color: context.c.outline, size: 19),

          Text(
            label,
            style: TextStyle(
              color: context.c.outline,
              fontWeight: .bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverTextIcon extends TextIcon {
  const _SliverTextIcon({
    super.key,
    super.icon,
    required super.label,
    required super.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: super.build(context));
  }
}
