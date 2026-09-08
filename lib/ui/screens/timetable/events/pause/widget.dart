import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/stripes_painter.dart';
import 'package:material_ui/material_ui.dart';

class PauseBlockWidget extends StatelessWidget {
  const PauseBlockWidget({
    super.key,
    required this.block,
    this.borderRadius = BlockWidget.baseBorderRadius,
  });

  final PauseEvent block;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,

      child: CustomPaint(
        painter: StripesPainter(
          backgroundColor: context.c.surfaceContainerHighest,
          stripeColor: context.c.onSurfaceVariant.withValues(alpha: .08),
        ),

        child: Container(
          width: .infinity,
          height: .infinity,
          alignment: .center,

          child: Text(
            block.title,
            textAlign: .center,
            style: TextStyle(
              color: context.c.onSurfaceVariant,
              fontWeight: .w700,
            ),
          ),
        ),
      ),
    );
  }
}
