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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4); // 56 + 4

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
          alignment: .center,

          children: [
            Positioned.fill(
              left: 48,
              right: 48,

              child: Center(
                child: title != null
                    ? Text(
                        title!,
                        textAlign: .center,
                        overflow: .ellipsis,
                        style: const TextStyle(fontWeight: .bold, fontSize: 18),
                      )
                    : const SizedBox.shrink(),
              ),
            ),

            Row(
              mainAxisAlignment: .spaceBetween,

              children: [
                leadingWidget ?? const SizedBox.shrink(),

                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Row(mainAxisSize: .min, children: actions),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
