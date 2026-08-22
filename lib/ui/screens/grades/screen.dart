import 'dart:async';

import 'package:antinote_api/antinote_api.dart' hide Tab;
import 'package:antinote_app/ui/screens/grades/grades_tab.dart';
import 'package:antinote_app/ui/screens/grades/report_tab.dart';
import 'package:antinote_app/ui/screens/shell/tab.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with
        TickerProviderStateMixin<GradesScreen>,
        AutomaticKeepAliveClientMixin<GradesScreen>,
        PageMixin<GradesScreen>,
        TabMixin<GradesScreen> {
  late List<Period> _periods;
  late Period _selectedPeriod;

  late TabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TabController(length: 3, vsync: this);
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
    bool partial,
  ) {
    final List<Widget> tabs = [
      GradesTab(periodId: _selectedPeriod.visualId),
      ReportTab(periodId: _selectedPeriod.visualId, classReport: true),
      ReportTab(periodId: _selectedPeriod.visualId, classReport: false),
    ];

    return SafeArea(
      bottom: false,
      right: false,
      left: false,

      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),

            slivers: [
              SliverAppBar(
                leadingWidth: constraints.maxWidth,
                primary: false,

                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(kTextTabBarHeight),

                  child: TabBar(
                    controller: _controller,

                    tabs:
                        [
                          context.l10n.grades,
                          context.l10n.classGradesReport,
                          context.l10n.gradesReport,
                        ].mapL(
                          (name) => Tab(
                            child: Text(
                              name,
                              textAlign: .center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
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

              SliverFillRemaining(
                child: TabBarView(controller: _controller, children: tabs),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Future<void> load(RemoteSession session) async {
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
