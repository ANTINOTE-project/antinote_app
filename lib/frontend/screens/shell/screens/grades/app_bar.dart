import "package:antinote/antinote.dart";
import "package:flutter/material.dart";

class GradesAppBar extends StatelessWidget {
  final List<Period> periods;
  final double maxWidth;

  final void Function(Period newPeriod) setSelectedPeriod;
  final Period? Function() getSelectedPeriod;

  const GradesAppBar({
    super.key,
    required this.maxWidth,

    required this.periods,

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
