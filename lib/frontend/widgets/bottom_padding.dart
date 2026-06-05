import "package:flutter/material.dart";

class BottomPadding extends StatelessWidget {
  final double padding;

  const BottomPadding({super.key, this.padding = 0});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom + padding,
      ),
    );
  }
}
