import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/timetable/events/meal/modal.dart';
import 'package:material_ui/material_ui.dart';

class const MenuWidgetSliver({super.key, required final Menu value})
    extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: MealContents(menu: value));
  }
}
