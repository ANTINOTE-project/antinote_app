import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  static ListWidget<TileWidgetData> list({
    required List<TileWidgetData> items,
    bool isLoading = false,
    bool isSliver = true,
    bool isColumn = false,
    bool shrinkWrap = false,
    ScrollPhysics? physics,

    bool gotBefore = false,
    bool gotAfter = false,
  }) {
    return ListWidget<TileWidgetData>(
      items: items,
      itemBuilder: (context, item, borderRadius) {
        return TileWidget.fromData(data: item, borderRadius: borderRadius);
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
  static const defaultRadius = Radius.circular(4);
  static const gap = 2.0;

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
                padding: i == 0 ? .zero : const .only(top: gap),
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
              padding: index == 0 ? .zero : const .only(top: gap),
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
            padding: index == 0 ? .zero : const .only(top: gap),
            child: itemBuilder(context, item, borderRadius),
          );
        },
      ),
    );
  }
}

@immutable
class TileWidgetData {
  final Widget? title;
  final Widget? subtitle;

  final Widget? leading;
  final Widget? trailing;

  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;

  final Color? backgroundColor;

  const TileWidgetData({
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onLongPressed,
    this.backgroundColor,
  });
}

class TileWidget extends StatelessWidget {
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

  const TileWidget({
    super.key,

    this.title,
    this.titleMaxLines = 1,
    this.subtitle,
    this.subtitleMaxLines,

    this.leading,
    this.trailing,

    this.onPressed,
    this.onLongPress,

    this.backgroundColor,
    required this.borderRadius,
  });

  factory TileWidget.fromData({
    required TileWidgetData data,
    required BorderRadius borderRadius,
  }) {
    return TileWidget(
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

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

        child: Row(
          spacing: 12,

          children: [
            ?leading,

            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  if (title != null)
                    DefaultTextStyle.merge(
                      style: TextTheme.of(context).bodyLarge?.copyWith(
                        color: context.c.onSurface,
                        fontWeight: .w800, // TODO: Edit bodyLarge directly with the custom font weights
                      ),

                      overflow: titleMaxLines == null ? null : .ellipsis,
                      maxLines: titleMaxLines,

                      child: title!,
                    ),

                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: TextTheme.of(context).bodyMedium?.copyWith(
                        fontWeight: .w500,
                        color: context.c.onSurfaceVariant,
                      ),

                      overflow: subtitleMaxLines == null ? null : .ellipsis,
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
