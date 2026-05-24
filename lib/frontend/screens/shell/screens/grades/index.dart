import "dart:async";

import "package:antinote/antinote.dart" hide Tab;
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades/app_bar.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades/body.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades/grades.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
import "package:flutter/material.dart";

typedef GradesTab = ({Widget widget, String category});

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen>
    with
        TickerProviderStateMixin<GradesScreen>,
        AutomaticKeepAliveClientMixin<GradesScreen>,
        ScreenMixin<GradesScreen> {
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
    final List<GradesTab> tabs = [
      (widget: GradesList(period: _selectedPeriod), category: "grades"),
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

            GradesBody(controller: _controller, tabs: tabs),
          ],
        );
      },
    );
  }

  @override
  Widget buildLoading(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
    return buildRefreshIndicator(
      child: const Center(child: LoadingWidget(size: 30)),
    );
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(198);

    _selectedPeriod = session.instance.defaultPeriod(DateTime.now());
    _periods = session.instance.periods;
  }

  @override
  bool get wantKeepAlive => true;
}
