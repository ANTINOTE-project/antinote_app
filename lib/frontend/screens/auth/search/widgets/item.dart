import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";
import "package:flutter_shaders_ui/flutter_shaders_ui.dart";

class ListItemCard extends StatelessWidget {
  final VoidCallback? onPressed;

  final Widget? leading;
  final String? label;
  final String? subtitle;
  final Widget? trailing;

  final bool isLoading;
  final Color? color;

  const ListItemCard({
    super.key,
    required this.onPressed,

    this.leading,
    required this.label,
    this.subtitle,
    this.trailing,

    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      child: ShimmerEffect(
        enabled: isLoading,
        angle: .1,
        speed: 4,
        width: 2,
        color: context.c.surfaceContainerHigh,
        child: Card(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              spacing: 10,
              children: [
                ?leading,

                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: label?.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (subtitle != null)
                          TextSpan(
                            text: "\n$subtitle",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                      ],
                    ),

                    maxLines: subtitle == null ? 1 : 2,
                    overflow: .ellipsis,
                  ),
                ),

                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
