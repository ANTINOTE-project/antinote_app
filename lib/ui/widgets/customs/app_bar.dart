import 'package:antinote_app/ui/utils/utils.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final TextAlign? titleAlign;
  final Widget? subtitle;

  final bool backButton;
  final Widget? leading;
  final Widget? trailing;

  const AppBarWidget({
    super.key,
    this.title,
    this.titleAlign,
    this.subtitle,
    this.backButton = true,
    this.leading,
    this.trailing,
  });

  @override
  Size get preferredSize {
    return Size.fromHeight(
      kToolbarHeight + 4 + (subtitle != null ? 16 : 0),
    ); // 56 + 4 (+ 16 if subtitle)
  }

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
        padding: const .symmetric(horizontal: 8),
        height: preferredSize.height,

        child: Row(
          spacing: 8,

          children: [
            ?leadingWidget,

            Expanded(
              child: title != null
                  ? Column(
                      mainAxisAlignment: .center,
                      crossAxisAlignment: titleAlign == .center
                          ? .center
                          : .start,

                      children: [
                        DefaultTextStyle(
                          overflow: .ellipsis,
                          textAlign: titleAlign,
                          maxLines: 1,
                          style: context.tt.titleLarge!.copyWith(
                            fontWeight: .bold,
                          ),
                          child: title!,
                        ),

                        if (subtitle != null)
                          DefaultTextStyle(
                            overflow: .ellipsis,
                            textAlign: titleAlign,
                            maxLines: 1,
                            style: context.tt.bodyMedium!.copyWith(
                              color: context.c.outline,
                              fontWeight: .w500,
                            ),
                            child: subtitle!,
                          ),
                      ],
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
