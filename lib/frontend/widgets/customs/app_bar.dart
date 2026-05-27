import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool backButton;
  final List<Widget> actions;

  const AppBarWidget({
    super.key,
    required this.title,
    this.backButton = true,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final leading = backButton && !(ModalRoute.isFirstOf(context) ?? false)
        ? Pressable(
            onPressed: context.pop,
            child: const Icon(HugeIconsSolid.arrowLeft01),
          )
        : null;

    return AppBar(
      automaticallyImplyLeading: false,

      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,

      leading: leading,
      actions: actions,
    );
  }
}
