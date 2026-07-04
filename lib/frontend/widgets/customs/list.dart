import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";
import "package:skeletonizer/skeletonizer.dart";

class ListWidget<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T item, BorderRadius borderRadius)
  itemBuilder;
  final List<T> items;

  final bool isLoading;
  final bool isSliver;
  final bool isColumn;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  final bool gotBefore;
  final bool gotAfter;

  const ListWidget({
    super.key,

    required this.items,
    required this.itemBuilder,

    this.isLoading = false,
    this.isSliver = true,
    this.isColumn = false,
    this.shrinkWrap = false,
    this.physics,

    this.gotBefore = false,
    this.gotAfter = false,
  });

  static ListWidget<ItemWidgetData> list({
    required List<ItemWidgetData> items,
    bool isLoading = false,
    bool isSliver = true,
    bool isColumn = false,
    bool shrinkWrap = false,
    ScrollPhysics? physics,

    bool gotBefore = false,
    bool gotAfter = false,
  }) {
    return ListWidget<ItemWidgetData>(
      items: items,
      itemBuilder: (context, item, borderRadius) {
        return ItemWidget.fromData(data: item, borderRadius: borderRadius);
      },
      shrinkWrap: shrinkWrap,
      physics: physics,
      isSliver: isSliver,
      isColumn: isColumn,
      gotAfter: gotAfter,
      gotBefore: gotBefore,
      isLoading: isLoading,
    );
  }

  static const radius = Radius.circular(16);
  static const defaultRadius = Radius.circular(6);

  BorderRadius _getBorderRadius(int index, int length) {
    final isFirst = index == 0 && !gotBefore;
    final isLast = index == length - 1 && !gotAfter;

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
    if (isColumn) {
      final child = Skeletonizer(
        enabled: isLoading,
        child: Column(
          mainAxisSize: shrinkWrap ? .min : .max,
          children: [
            for (int i = 0; i < items.length; i++)
              Padding(
                padding: const .symmetric(vertical: 2),
                child: itemBuilder(
                  context,
                  items[i],
                  _getBorderRadius(i, items.length),
                ),
              ),
          ],
        ),
      );

      if (isSliver) {
        return SliverToBoxAdapter(child: child);
      }

      return child;
    }

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

@immutable
class ItemWidgetData {
  final Widget? title;
  final Widget? subtitle;

  final Widget? leading;
  final Widget? trailing;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;

  final Color? backgroundColor;

  const ItemWidgetData({
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPressed,
    this.backgroundColor,
  });
}

class ItemWidget extends StatelessWidget {
  final Widget? title;
  final int? titleMaxLines;
  final Widget? subtitle;
  final int? subtitleMaxLines;

  final Widget? leading;
  final Widget? trailing;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final BorderRadius borderRadius;
  final Color? backgroundColor;

  const ItemWidget({
    super.key,

    this.title,
    this.titleMaxLines = 1,
    this.subtitle,
    this.subtitleMaxLines = 1,

    this.leading,
    this.trailing,

    this.onPressed,
    this.onLongPress,

    this.backgroundColor,
    required this.borderRadius,
  });

  factory ItemWidget.fromData({
    required ItemWidgetData data,
    required BorderRadius borderRadius,
  }) {
    return ItemWidget(
      title: data.title,
      subtitle: data.subtitle,
      leading: data.leading,
      trailing: data.trailing,
      onPressed: data.onPressed,
      onLongPress: data.onLongPressed,
      backgroundColor: data.backgroundColor,
      borderRadius: borderRadius,
    );
  }

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
                  if (title != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: .w800,
                        fontFamily: "SNPro",

                        color: context.c.onSurface,
                      ),

                      overflow: .ellipsis,
                      maxLines: titleMaxLines,

                      child: title!,
                    ),

                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: .bold,
                        fontFamily: "SNPro",

                        color: context.c.outline,
                      ),

                      overflow: .ellipsis,
                      maxLines: subtitleMaxLines,

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
