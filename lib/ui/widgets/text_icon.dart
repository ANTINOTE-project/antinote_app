import 'package:antinote_app/ui/utils/utils.dart';
import 'package:material_ui/material_ui.dart';

class SliverTextIcon extends StatelessWidget {
  final IconData? icon;
  final String label;

  const SliverTextIcon({super.key, this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: TextIcon(label: label, icon: icon),
    );
  }
}

class TextIcon extends StatelessWidget {
  final IconData? icon;
  final String label;

  const TextIcon({super.key, this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(left: 6, top: 0, bottom: 6),

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
