import "dart:async";

import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/screen.dart";
import "package:antinote_app/frontend/widgets/customs/loading.dart";
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
        ScreenMixin<GradesScreen> {
  late List<Period> _periods;
  Period? _selectedPeriod;

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
            SliverSafeArea(
              left: false,
              right: false,
              bottom: false,

              sliver: SliverAppBar(
                leadingWidth: constraints.maxWidth,
                primary: false,

                leading: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _periods.length,

                  scrollDirection: .horizontal,
                  shrinkWrap: true,

                  itemBuilder: (context, index) {
                    final period = _periods[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),

                      child: ChoiceChip(
                        selected: period == _selectedPeriod,
                        label: Text(period.name),

                        onSelected: (value) async {
                          if (value) {
                            setState(() {
                              _selectedPeriod = period;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
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

    _periods = session.instance.periods;
    _selectedPeriod ??= session.instance.defaultPeriod(DateTime.now());

    if (!context.mounted) {
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
