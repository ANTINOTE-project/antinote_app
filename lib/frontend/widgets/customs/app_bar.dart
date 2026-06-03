import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool backButton;
  final List<Widget> actions;

  const AppBarWidget({
    super.key,
    this.title,
    this.backButton = true,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final leading = backButton && !(ModalRoute.isFirstOf(context) ?? false)
        ? IconButton(
            onPressed: context.pop,
            icon: const Icon(HugeIconsSolid.arrowLeft01, size: 22),
          )
        : null;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,

      title: title != null
          ? Text(title!, style: const TextStyle(fontWeight: FontWeight.bold))
          : null,

      leading: leading,
      actions: actions,
    );
  }
}
