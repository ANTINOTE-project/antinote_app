import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class HomeWidget extends StatelessWidget {
  final String label;
  final Widget content;
  final VoidCallback onShowMorePressed;

  const HomeWidget({
    super.key,
    required this.label,
    required this.content,
    required this.onShowMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 10, vertical: 8),
      width: double.infinity,

      decoration: BoxDecoration(
        border: .all(color: context.c.outlineVariant),
        color: context.c.surfaceContainer,
        borderRadius: .circular(20),
      ),

      child: Column(
        spacing: 8,

        children: [
          Padding(
            padding: const .only(left: 4),

            child: Row(
              mainAxisAlignment: .spaceBetween,
              spacing: 6,

              children: [
                Expanded(
                  child: Text(
                    label,

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: const TextStyle(fontWeight: .w800, fontSize: 19),
                  ),
                ),

                Pressable(
                  borderRadius: .circular(999),
                  onPressed: onShowMorePressed,

                  child: Ink(
                    decoration: BoxDecoration(
                      color: context.c.surfaceContainerLow,
                      borderRadius: .circular(999),
                    ),

                    padding: const .symmetric(horizontal: 12, vertical: 8),

                    child: Row(
                      spacing: 6,

                      children: [
                        Text(
                          context.l10n.homeShowMore,

                          style: TextStyle(
                            color: context.c.outline,
                            fontWeight: .bold,
                            fontSize: 14,
                          ),
                        ),

                        Icon(
                          HugeIconsSolid.arrowUpRight02,
                          color: context.c.outline,
                          size: 21,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          content,
        ],
      ),
    );
  }
}
