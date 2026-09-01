import 'package:antinote_app/ui/utils/utils.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final TextAlign? titleAlign;

  final bool backButton;
  final Widget? leading;
  final Widget? trailing;

  const AppBarWidget({
    super.key,
    this.title,
    this.titleAlign,
    this.backButton = true,
    this.leading,
    this.trailing,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4); // 56 + 4

  @override
  Widget build(BuildContext context) {
    final bool isFirstRoute = ModalRoute.isFirstOf(context) ?? false;
    final bool shouldShowBackButton = backButton && !isFirstRoute;

    final Widget? defaultBackButton = shouldShowBackButton
        ? IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(HugeIconsSolid.arrowLeft01, size: 22),
          )
        : null;

    final Widget? leadingWidget = leading ?? defaultBackButton;

    return SafeArea(
      bottom: false,

      child: Container(
        padding: const .symmetric(horizontal: 12),
        height: preferredSize.height,

        child: Row(
          spacing: 12,

          children: [
            ?leadingWidget,

            Expanded(
              child: title != null
                  ? DefaultTextStyle(
                      overflow: .ellipsis,
                      textAlign: titleAlign,
                      maxLines: 1,
                      style: context.tt.titleLarge!.copyWith(fontWeight: .bold),
                      child: title!,
                    )
                  : const SizedBox.shrink(),
            ),

            ?trailing,
          ],
        ),
      ),
    );
  }
}
