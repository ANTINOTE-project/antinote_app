import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/data/src/home_page/manager.dart';
import 'package:antinote_app/data/src/home_page/widget/widget.dart';
import 'package:antinote_app/ui/screens/home/screen.dart';
import 'package:antinote_app/ui/screens/timetable/events/block.dart';
import 'package:antinote_app/ui/screens/timetable/screen.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class const TimetableDayWidgetSliver({
  super.key,
  required final HomePageWidgetState state,
  required final DayBlocks value,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: HomeWidget(
        icon: HugeIconsSolid.calendar01,
        title: Text(context.l10n.timetable),
        child: ConstrainedBox(
          constraints: .new(maxHeight: MediaQuery.heightOf(context) * .6),
          child: TimetableDisplay(
            baseDate: state.overrideArguments.get(TimetableDayArgument.day),
            normalPicker: false,
            transparent: true,

            updateBlocks: (session, days, businessDays) async {
              // TODO: Add check whether the day is already loaded inside value

              final manager = HomePageScope.of(context).manager;

              if (businessDays.isNotEmpty) {
                state.overrideArguments.set(
                  TimetableDayArgument.day,
                  businessDays.first.toDay(),
                );

                final newState = await manager.reloadWidget(
                  session,
                  state,
                  force: true,
                );

                return {businessDays.first: newState?.value ?? []};
              }

              return {businessDays.first: []};
            },
            configurations: const [.dayConfig],
          ),
        ),
      ),
    );
  }
}
