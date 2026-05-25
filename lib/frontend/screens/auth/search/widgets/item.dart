import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";

class ListItemCard extends StatelessWidget {
  final VoidCallback? onPressed;

  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  final bool isLoading;
  final Color? color;
  final bool emphaseTitle;

  const ListItemCard({
    super.key,
    required this.onPressed,

    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,

    this.isLoading = false,
    this.color,
    this.emphaseTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      hasFeedback: !isLoading,
      onPressed: onPressed,

      child: Card(
        color: color,

        child: ListTile(
          leading: leading,
          trailing: trailing,

          title: title != null
              ? Text(
                  title!,
                  maxLines: 1,
                  overflow: .ellipsis,
                  style: TextStyle(fontWeight: emphaseTitle ? .bold : null),
                )
              : null,
          subtitle: subtitle != null
              ? Text(subtitle!, maxLines: 1, overflow: .ellipsis)
              : null,
        ),
      ),
    );
  }
}
