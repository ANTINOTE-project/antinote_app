import "package:flutter/material.dart";

class LoadingWidget extends StatelessWidget {
  final double size;

  const LoadingWidget({super.key, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,

        child: CircularProgressIndicator(
          strokeWidth: size / 7,
          strokeCap: .round,
        ),
      ),
    );
  }
}
