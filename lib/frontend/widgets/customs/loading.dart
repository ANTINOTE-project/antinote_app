import "package:antinote_app/frontend/extensions/colors.dart";
import "package:flutter/material.dart";

class LoadingWidget extends StatelessWidget {
  final double size;

  const LoadingWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(color: context.c.primary, strokeWidth: size / 7),
    );
  }
}
