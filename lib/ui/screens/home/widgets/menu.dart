import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/home/widgets.dart';
import 'package:antinote_app/ui/screens/timetable/events/meal/modal.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class const MenuWidgetSliver({super.key, required final Menu value})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: HomeWidget(
        icon: const Icon(HugeIconsSolid.spoonAndKnife),
        label: Text(context.l10n.menu),
        content: MealContents(
          menu: value,
          addPadding: false,
          invertColor: true,
          padding: .zero,
        ),
        onShowMorePressed: null,
      ),
    );
  }
}
