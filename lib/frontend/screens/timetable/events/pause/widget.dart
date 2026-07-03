import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:flutter/material.dart";

class PauseBlockWidget extends StatelessWidget {
  const PauseBlockWidget({super.key, required this.block});

  final PauseBlock block;

  static const double radius = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.c.outlineVariant),
        borderRadius: .circular(radius),
      ),
      width: double.infinity,
      height: double.infinity,
      alignment: .center,
      child: Text(
        block.title,
        textAlign: .center,
        style: TextStyle(
          color: context.c.onSurface.withAlpha(128),
          fontWeight: .w700,
        ),
      ),
    );
  }
}
