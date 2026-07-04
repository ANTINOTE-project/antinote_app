import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class MealBlockWidget extends StatelessWidget {
  const MealBlockWidget({super.key, required this.block});

  final MealBlock block;

  static const double radius = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(radius),
        border: Border.all(color: context.c.outline)
      ),
      width: double.infinity,
      height: double.infinity,
      child: const Icon(HugeIconsSolid.spoonAndKnife),
    );
  }
}
