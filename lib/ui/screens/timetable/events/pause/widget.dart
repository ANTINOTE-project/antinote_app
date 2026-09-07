import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/utils/utils.dart';
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.c.outlineVariant),
        borderRadius: borderRadius,
      ),

      width: .infinity,
      height: .infinity,
      alignment: .center,

      child: Text(
        block.title,
        textAlign: .center,
        style: TextStyle(color: context.c.outlineVariant, fontWeight: .w700),
      ),
    );
  }
}
