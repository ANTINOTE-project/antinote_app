import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/screens/timetable/events/meal/modal.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class MealBlockWidget extends StatelessWidget {
  const MealBlockWidget({
    super.key,
    required this.block,
    this.borderRadius = BlockWidget.baseBorderRadius,
  });

  final MealEvent block;
  final BorderRadius borderRadius;

  static const double radius = 16;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: borderRadius,
      onPressed: () async {
        await showMealModal(context, block.startTime.toDay());
      },
      child: Ink(
        decoration: BoxDecoration(borderRadius: borderRadius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: context.c.outline),
          ),
          width: double.infinity,
          height: double.infinity,
          child: const Icon(HugeIconsSolid.spoonAndKnife),
        ),
      ),
    );
  }
}
