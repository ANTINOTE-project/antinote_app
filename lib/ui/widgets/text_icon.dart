import 'package:antinote_app/ui/utils/utils.dart';
import 'package:flutter/material.dart';

class SliverTextIcon extends StatelessWidget {
  final IconData? icon;
  final String label;

  const SliverTextIcon({super.key, this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const .only(left: 6, top: 16, bottom: 4),
      sliver: SliverToBoxAdapter(
        child: Row(
          spacing: 8,

          children: [
            if (icon != null) Icon(icon, color: context.c.outline, size: 22),

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
      ),
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
      padding: const .only(left: 6, top: 16, bottom: 4),
      child: Row(
        spacing: 8,

        children: [
          if (icon != null) Icon(icon, color: context.c.outline, size: 22),

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
