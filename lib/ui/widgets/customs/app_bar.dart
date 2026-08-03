import 'package:antinote_app/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final AlignmentGeometry titleAlign;
  final Widget? title;
  final bool backButton;
  final List<Widget> actions;
  final Widget? leading;

  const AppBarWidget({
    super.key,
    this.title,
    this.titleAlign = .center,
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
            Container(
              alignment: titleAlign,
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: title != null
                  ? DefaultTextStyle(
                      overflow: .ellipsis,
                      textAlign: .center,
                      style: context.tt.titleLarge!.copyWith(
                        fontWeight: .bold,
                        fontFamily: 'SNPro',
                      ),
                      child: title!,
                    )
                  : const SizedBox.shrink(),
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
