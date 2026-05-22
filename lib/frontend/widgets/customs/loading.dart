import "package:antinote_app/frontend/theme/app.dart";
import "package:flutter/material.dart";

class LoadingWidget extends StatelessWidget {
  final double size;

  const LoadingWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(color: AppTheme.onSurface, strokeWidth: size / 7),
    );
  }
}
