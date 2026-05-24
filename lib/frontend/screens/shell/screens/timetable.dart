import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with
        AutomaticKeepAliveClientMixin<TimetableScreen>,
        ScreenMixin<TimetableScreen> {
  late SpecificInstanceParameters scheduleDisplayData;
  final Map<DateTime, List<Class>> _classes = {};

  @override
  bool get wantKeepAlive => true;

  PageController? controller;

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    super.build(context);

    final days = DateRange(
      start: scheduleDisplayData.firstDate,
      end: scheduleDisplayData.lastDate,
    ).listDays();

    // PageView.builder(itemBuilder: (context, index) {}, itemCount: days.length);

    // return buildRefreshIndicator(
    //   child: ListView.builder(
    //     itemCount: _classes!.length,
    //     itemBuilder: (context, index) {
    //       final clazz = _classes![index];
    //
    //       return Card(
    //         child: ListTile(
    //           title: Text(clazz.id),
    //           subtitle: Text("${clazz.startDate} → ${clazz.endDate}"),
    //         ),
    //       );
    //     },
    //   ),
    // );
    return Container();
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    super.build(context);

    return const Center(child: LoadingWidget(size: 30));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    scheduleDisplayData = session.instance;

    await session.ensurePage(16);

    controller ??= PageController();

    final result = await session.access(
      TimetableAccessor.forRange(
        resource: session.userResource,
        from: DateTime.now()
            .add(const Duration(days: 4))
            .copyWith(isUtc: true)
            .toDay(),
        to: null,
      ),
    );

    // _classes = result.classes;
  }
}
