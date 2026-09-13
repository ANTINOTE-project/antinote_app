import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/data/src/home_page/widget/widget.dart';
import 'package:antinote_app/ui/screens/home/screen.dart';
import 'package:antinote_app/ui/screens/home/widgets.dart';
import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/screens/timetable/screen.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

class const TimetableDayWidgetSliver({
  super.key,
  required final HomePageWidgetState state,
  required final DayBlocks value,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: HomeWidget(
        icon: const Icon(HugeIconsSolid.calendar01),
        label: Text(context.l10n.timetable),

        onShowMorePressed: () {
          context.sc.goToTab(.timetable);
        },

        content: ConstrainedBox(
          constraints: .new(maxHeight: MediaQuery.heightOf(context) * .6),

          child: TimetableDisplay(
            baseDate: state.reloadArguments.get(TimetableDayArgument.day),
            normalPicker: false,
            transparent: true,

            updateBlocks: (session, days, businessDays, forceReload) async {
              final manager = HomePageScope.of(context).manager;

              final day = businessDays.firstOrNull;
              if (day == null) {
                return {};
              }

              if (!forceReload && manager.cache.hasDayBaseSchedules(day)) {
                return {day: manager.cache.dayBlocks(day)};
              }

              state.overrideArguments.set(TimetableDayArgument.day, day);

              final newState = await manager.reloadWidget(
                session,
                state,
                force: true,
              );

              return {day: newState?.value ?? []};
            },
            configurations: const [.dayConfig],
          ),
        ),
      ),
    );
  }
}
