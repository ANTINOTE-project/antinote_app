import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:antinote_app/frontend/screens/timetable/events/meal/modal.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class MealBlockWidget extends StatelessWidget {
  const MealBlockWidget({super.key, required this.block});

  final MealBlock block;

  static const double radius = 16;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      borderRadius: .circular(radius),
      border: Border.all(color: context.c.outline),
    );

    return Pressable(
      onPressed: () async {
        await showMealModal(context, block.startTime.toDay());
      },
      child: Ink(
        decoration: decoration,
        child: Container(
          decoration: decoration,
          width: double.infinity,
          height: double.infinity,
          child: const Icon(HugeIconsSolid.spoonAndKnife),
        ),
      ),
    );
  }
}
