import "dart:async";

import "package:antinote/antinote.dart" hide Tab;
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades/app_bar.dart";
import "package:antinote_app/frontend/screens/shell/screens/grades/body.dart";
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
  static const List<GradesTab> _tabs = [
    (widget: SizedBox.shrink(), category: "grades"),
    (widget: SizedBox.shrink(), category: "report"),
  ];

  late List<Period> _periods;
  Period? _selectedPeriod;

  late TabController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget buildLoaded(
    BuildContext context,
    RefreshIndicatorBuilder buildRefreshIndicator,
  ) {
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

              setSelectedPeriod: (newPeriod) {
                setState(() => _selectedPeriod = newPeriod);
              },
            ),

            GradesBody(controller: _controller, tabs: _tabs),
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
    return const Center(child: LoadingWidget(size: 30));
  }

  @override
  FutureOr<void> loadActiveDataFromSession(PronoteSession session) async {
    await session.ensurePage(198);

    _selectedPeriod ??= session.instance.defaultPeriod(DateTime.now());
    _periods = session.instance.periods;

    if (!mounted) {
      throw Exception(
        "By the time we ensured the correct page was set, the context got unmounted",
      );
    }

    // return session.access(
    //   LatestGradesPageAccessor(
    //     period: asdasd.getOrPutAndListenPeriod(context, session),
    //   ),
    // );
  }

  @override
  bool get wantKeepAlive => true;
}
