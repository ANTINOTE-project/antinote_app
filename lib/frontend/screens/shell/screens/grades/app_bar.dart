import "package:antinote/antinote.dart" hide Tab;
import "package:flutter/material.dart";

class GradesAppBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabsName;

  final List<Period> periods;
  final double maxWidth;

  final void Function(Period period) setSelectedPeriod;
  final Period Function() getSelectedPeriod;

  const GradesAppBar({
    super.key,

    required this.controller,
    required this.tabsName,

    required this.periods,
    required this.maxWidth,

    required this.setSelectedPeriod,
    required this.getSelectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return SliverSafeArea(
      left: false,
      right: false,
      bottom: false,

      sliver: SliverAppBar(
        leadingWidth: maxWidth,
        primary: false,

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kTextTabBarHeight),

          child: TabBar(
            controller: controller,

            tabs: tabsName.mapL(
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
          itemCount: periods.length,

          scrollDirection: .horizontal,
          shrinkWrap: true,

          itemBuilder: (context, index) {
            final period = periods[index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),

              child: ChoiceChip(
                selected: period == getSelectedPeriod(),
                label: Text(period.name),

                onSelected: (value) async {
                  if (value) {
                    setSelectedPeriod(period);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
