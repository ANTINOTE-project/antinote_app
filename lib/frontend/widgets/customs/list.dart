import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:skeletonizer/skeletonizer.dart";

class ListWidget<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T item, BorderRadius borderRadius)
  itemBuilder;
  final List<T> items;

  final bool isLoading;
  final bool isSliver;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ListWidget({
    super.key,

    required this.items,
    required this.itemBuilder,

    this.isLoading = false,
    this.isSliver = true,
    this.shrinkWrap = false,
    this.physics,
  });

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
    if (isSliver) {
      return Skeletonizer.sliver(
        enabled: isLoading,

        child: SliverList.builder(
          itemCount: items.length,

          itemBuilder: (context, index) {
            final item = items[index];
            final borderRadius = _getBorderRadius(index, items.length);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: itemBuilder(context, item, borderRadius),
            );
          },
        ),
      );
    }

    return Skeletonizer(
      enabled: isLoading,

      child: ListView.builder(
        itemCount: items.length,
        shrinkWrap: shrinkWrap,
        physics: physics,

        itemBuilder: (context, index) {
          final item = items[index];
          final borderRadius = _getBorderRadius(index, items.length);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: itemBuilder(context, item, borderRadius),
          );
        },
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;

  final Widget? leading;
  final Widget? trailing;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final BorderRadius borderRadius;
  final Color? backgroundColor;

  const ItemWidget({
    super.key,

    required this.title,
    this.subtitle,

    this.leading,
    this.trailing,

    this.onPressed,
    this.onLongPress,

    this.backgroundColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: borderRadius,

      onPressed: onPressed,
      onLongPress: onLongPress,

      child: Ink(
        decoration: BoxDecoration(
          color: backgroundColor ?? context.c.surfaceContainer,
          borderRadius: borderRadius,
        ),

        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

        child: Row(
          spacing: 12,

          children: [
            ?leading,

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,

                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: .w800,
                      fontFamily: "SNPro",

                      color: context.c.onSurface,
                    ),

                    overflow: .ellipsis,
                    maxLines: 1,

                    child: title,
                  ),

                  if (subtitle != null)
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: .bold,
                        fontFamily: "SNPro",

                        color: context.c.outline,
                      ),

                      overflow: .ellipsis,
                      maxLines: 1,

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
