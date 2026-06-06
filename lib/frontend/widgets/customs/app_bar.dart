import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:hugeicons_pro/hugeicons.dart";

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool backButton;
  final List<Widget> actions;
  final Widget? leading;

  const AppBarWidget({
    super.key,
    this.title,
    this.backButton = true,
    this.actions = const [],
    this.leading,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isFirstRoute = ModalRoute.isFirstOf(context) ?? false;
    final bool shouldShowBackButton = backButton && !isFirstRoute;

    final Widget? defaultBackButton = shouldShowBackButton
        ? IconButton(
            onPressed: context.pop,
            icon: const Icon(HugeIconsSolid.arrowLeft01, size: 22),
          )
        : null;

    final Widget? leadingWidget = leading ?? defaultBackButton;

    return SafeArea(
      bottom: false,

      child: Container(
        padding: const .symmetric(horizontal: 8),
        height: preferredSize.height,

        child: Stack(
          children: [
            if (leadingWidget != null)
              Align(alignment: .centerLeft, child: leadingWidget),

            if (title != null)
              Align(
                child: Text(
                  title!,
                  textAlign: .center,
                  style: const TextStyle(fontWeight: .bold, fontSize: 18),
                ),
              ),

            if (actions.isNotEmpty)
              Align(
                alignment: .centerRight,

                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Row(mainAxisSize: .min, children: actions),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
