import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/screens/timetable/events/meal/modal.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:antinote_app/ui/widgets/stripes_painter.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class MealBlockWidget extends StatelessWidget {
  const MealBlockWidget({
    super.key,
    required this.block,
    this.borderRadius = BlockWidget.baseBorderRadius,
  });

  final MealEvent block;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      borderRadius: borderRadius,

      onPressed: () async {
        await showMealModal(context, block.startTime.toDay());
      },

      child: ClipRRect(
        borderRadius: borderRadius,

        child: CustomPaint(
          painter: StripesPainter(
            backgroundColor: context.c.primaryContainer,
            stripeColor: context.c.onPrimaryContainer.withValues(alpha: .08),
          ),

          child: Container(
            width: .infinity,
            height: .infinity,
            alignment: .center,

            child: Column(
              mainAxisAlignment: .center,
              spacing: 2,

              children: [
                Icon(
                  HugeIconsSolid.spoonAndKnife,
                  color: context.c.onPrimaryContainer,
                  size: 28,
                ),

                Text(
                  context.l10n.seeMeal,
                  style: context.tt.bodyMedium?.copyWith(
                    color: context.c.onPrimaryContainer,
                    fontWeight: .bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
