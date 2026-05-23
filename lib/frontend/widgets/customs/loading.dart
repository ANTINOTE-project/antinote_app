import "package:flutter/material.dart";

class LoadingWidget extends StatelessWidget {
  final double size;

  const LoadingWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: size / 7),
    );
  }
}
