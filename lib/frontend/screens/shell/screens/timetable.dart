import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/backend.dart";
import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:antinote_app/main.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with AutomaticKeepAliveClientMixin<TimetableScreen>, ScreenMixin<TimetableScreen> {
  late SpecificInstanceParameters scheduleDisplayData;
  final Map<DateTime, ValueNotifier<List<Class>?>> _classes = {};
  late List<DateRange> currentGroups;

  @override
  bool get wantKeepAlive => true;

  PageController? pageController;
  ScrollController scrollController = TrackingScrollController();

  @override
  Widget buildLoaded(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    final days = DateRange(
      start: scheduleDisplayData.firstDate,
      end: scheduleDisplayData.lastDate,
    ).listDays();

    final daysConfiguration = WeekMappedViewConfiguration.defaultConfigs.pickConfig(context);
    currentGroups = daysConfiguration.daysToRangeList(days, scheduleDisplayData);

    return buildRefreshIndicator(
      child: PageView.builder(
        itemBuilder: (context, index) {
          final dayGroup = currentGroups[index];
          final days = dayGroup.listDays();

          return RefreshIndicator(
            onRefresh: () => reload(fromRefreshIndicator: true),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(title: Text(dayGroup.pprint(context)), pinned: true),
                SliverFillRemaining(
                  child: Flex(
                    direction: .horizontal,
                    children: [
                      for (final day in days)
                        ValueListenableBuilder(
                          valueListenable: _classes[day]!,
                          builder: (context, classes, child) {
                            if (classes != null) {
                              return Flexible(
                                child: ListView.builder(
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    final clazz = classes[index];
                                    return ListItemCard(onPressed: null, title: clazz.id);
                                  },
                                  itemCount: classes.length,
                                ),
                              );
                            } else {
                              return const Expanded(
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        controller: pageController,
        itemCount: currentGroups.length,
      ),
    );
  }

  @override
  Widget buildLoading(BuildContext context, RefreshIndicatorBuilder buildRefreshIndicator) {
    return buildRefreshIndicator(child: const Center(child: LoadingWidget(size: 30)));
  }

  Future<void> updateClasses(DateRange days, {PronoteSession? session}) async {
    talker.info("Fetching days ${days.pprint(context)}");
    Future<void> update(PronoteSession session) async {
      final loadedDays = {for (final day in days.listDays()) day: <Class>[]};

      await session.ensurePage(16);

      for (final clazz in (await session.access(
        TimetableAccessor.forRange(resource: session.userResource, from: days.start, to: days.end),
      )).classes) {
        loadedDays[clazz.startDate.toDay()]!.add(clazz);
      }

      for (final loadedDay in loadedDays.entries) {
        _classes[loadedDay.key]!.value = loadedDay.value;
      }
    }

    if (session != null) {
      await update(session);
    } else {
      await SessionManager.execute(context: context, callback: update);
    }
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    scheduleDisplayData = session.instance;

    final days = DateRange(
      start: scheduleDisplayData.firstDate,
      end: scheduleDisplayData.lastDate,
    ).listDays();

    final daysConfiguration = WeekMappedViewConfiguration.defaultConfigs.pickConfig(context);
    currentGroups = daysConfiguration.daysToRangeList(days, scheduleDisplayData);

    final int currentGroupIndex;

    if (pageController == null || !pageController!.hasClients || pageController?.page == null) {
      currentGroupIndex = currentGroups.indexWhere(
        (element) => element.contains(scheduleDisplayData.nextBusinessDay),
      );
    } else {
      currentGroupIndex = pageController!.page!.round();
    }

    if (pageController == null) {
      for (final day in days) {
        _classes[day] = ValueNotifier(null);
      }

      pageController = PageController(initialPage: currentGroupIndex);
    }

    await updateClasses(currentGroups[currentGroupIndex], session: session);
  }
}
