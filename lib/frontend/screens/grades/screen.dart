import "dart:async";

import "package:antinote/antinote.dart" hide Tab;
import "package:antinote_app/frontend/screens/grades/grades_tab.dart";
import "package:antinote_app/frontend/screens/grades/report_tab.dart";
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:antinote_app/utils/utils.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with
        TickerProviderStateMixin<GradesScreen>,
        AutomaticKeepAliveClientMixin<GradesScreen>,
        TabMixin<GradesScreen> {
  late List<Period> _periods;
  late Period _selectedPeriod;

  late TabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    final List<Widget> tabs = [
      GradesTab(periodId: _selectedPeriod.visualId),
      const ReportTab(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),

          slivers: [
            SliverSafeArea(
              left: false,
              right: false,
              bottom: false,

              sliver: SliverAppBar(
                leadingWidth: constraints.maxWidth,
                primary: false,

                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kTextTabBarHeight),

                  child: TabBar(
                    controller: _controller,

                    tabs: [context.l10n.grades, context.l10n.report].mapL(
                      (name) => Tab(
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),

                leading: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _periods.length,

                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,

                  itemBuilder: (context, index) {
                    final period = _periods[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),

                      child: ChoiceChip(
                        selected: period == _selectedPeriod,
                        label: Text(
                          period.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),

                        onSelected: (value) async {
                          if (value) {
                            setState(() => _selectedPeriod = period);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            SliverFillRemaining(
              child: TabBarView(controller: _controller, children: tabs),
            ),
          ],
        );
      },
    );
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(198);

    final periodData = session.userResource.tabsForPeriods.firstWhereOrNull(
      (element) => element.location == 198,
    );

    _selectedPeriod = session.instance.periods.firstWhere(
      (element) => element.id == periodData?.defaultPeriod?.id,
      orElse: () => session.instance.defaultPeriod(DateTime.now()),
    );

    _periods = session.instance.periods
        .where(
          (p) =>
              periodData?.periods?.any((element) => element.id == p.id) ?? true,
        )
        .toList();
  }

  @override
  bool get wantKeepAlive => true;
}
