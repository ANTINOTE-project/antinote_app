import "dart:async";

import "package:antinote/antinote.dart" hide Tab;
import "package:antinote_app/frontend/screens/shell/tab.dart";
import "package:antinote_app/frontend/screens/shell/tabs/grades/app_bar.dart";
import "package:antinote_app/frontend/screens/shell/tabs/grades/tabs/grades.dart";
import "package:antinote_app/utils.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";

typedef GradesScreenTab = ({Widget widget, String category});

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
    final List<GradesScreenTab> tabs = [
      (
        widget: GradesTab(periodId: _selectedPeriod.visualId),
        category: "grades",
      ),
      (widget: const SizedBox.shrink(), category: "report"),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),

          slivers: [
            GradesAppBar(
              maxWidth: constraints.maxWidth,

              tabsName: [context.l10n.grades, context.l10n.report],
              controller: _controller,

              getSelectedPeriod: () => _selectedPeriod,
              periods: _periods,

              setSelectedPeriod: (period) {
                setState(() => _selectedPeriod = period);
              },
            ),

            SliverFillRemaining(
              child: TabBarView(
                controller: _controller,
                children: tabs.mapL((e) => e.widget),
              ),
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
