import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";

class ListWidget<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T item, BorderRadius borderRadius) itemBuilder;
  final List<T> items;

  const ListWidget({super.key, required this.items, required this.itemBuilder});

  static const radius = Radius.circular(16);
  static const defaultRadius = Radius.circular(6);

  static BorderRadius _getBorderRadius(int index, int length) {
    final isFirst = index == 0;
    final isLast = index == length - 1;

    return switch ((isFirst, isLast)) {
      (true, true) => const BorderRadius.all(radius),

      (true, _) => const BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: defaultRadius,
        bottomRight: defaultRadius,
      ),

      (_, true) => const BorderRadius.only(
        topLeft: defaultRadius,
        topRight: defaultRadius,
        bottomLeft: radius,
        bottomRight: radius,
      ),

      _ => const BorderRadius.all(defaultRadius),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: items.length,

      itemBuilder: (context, index) {
        final item = items[index];

        final borderRadius = _getBorderRadius(index, items.length);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: itemBuilder(context, item, borderRadius),
        );
      },
    );
  }
}

class ItemWidget extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  final VoidCallback? onPressed;

  final BorderRadius borderRadius;
  final Color? backgroundColor;

  const ItemWidget({
    super.key,

    required this.title,
    this.subtitle,
    this.trailing,

    this.onPressed,

    this.backgroundColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,

      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? context.c.surfaceContainer,
          borderRadius: borderRadius,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        child: Row(
          spacing: 16,

          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,

                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: .w900,
                      color: backgroundColor == null ? context.c.onPrimaryContainer : null,
                    ),
                    maxLines: 1,
                    overflow: .ellipsis,
                    child: title,
                  ),

                  if (subtitle != null)
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: .w800,
                        color: backgroundColor == null ? context.c.onPrimaryContainer : null,
                      ),
                      child: subtitle!,
                    ),
                ],
              ),
            ),

            ?trailing,
          ],
        ),
      ),
    );
  }
}
