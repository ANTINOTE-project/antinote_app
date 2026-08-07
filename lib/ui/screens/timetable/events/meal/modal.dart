import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

Future<void> showMealModal(BuildContext context, DateTime date) async {
  final mealCallback = context.ar.runTask<Menu?>(
    context: context,
    callback: (session) async {
      return (await session.access(MenuPageAccessor(date: date))).menus
          .firstWhereOrNull((element) => element.time.isAtSameMomentAs(date));
    },
    debugLabel: 'Fetch detailed data about menu',
  );

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return FutureBuilder(
        future: mealCallback,
        builder: (context, snapshot) {
          final Widget child;
          if (snapshot.connectionState == .done) {
            if (snapshot.hasData && snapshot.requireData!.meals.isNotEmpty) {
              child = SliverMealContents(menu: snapshot.requireData!);
            } else {
              // TODO: Create a normalized error display.
              child = Center(child: Text(context.l10n.noMenuForToday));
            }
          } else {
            child = const Center(child: LoadingWidget());
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.fastOutSlowIn,
            child: child,
          );
        },
      );
    },
  );
}

class SliverMealContents extends StatelessWidget {
  const SliverMealContents({super.key, required this.menu});

  final Menu menu;

  String mealTitle(BuildContext context, Meal meal) {
    if (meal.title != null) return meal.title!;

    if (meal.mealType == 0) {
      return context.l10n.lunchFor(menu.time);
    }

    return context.l10n.dinnerFor(menu.time);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        for (final meal in menu.meals)
          SliverPadding(
            padding: const .symmetric(horizontal: 12),
            sliver: SliverMainAxisGroup(
              slivers: [
                SliverTextIcon(label: mealTitle(context, meal)),
                ListWidget(
                  items: meal.dishes,
                  itemBuilder: (context, item, borderRadius) {
                    return ItemWidget(
                      borderRadius: borderRadius,
                      titleMaxLines: null,
                      title: Text.rich(
                        TextSpan(
                          children: [
                            for (final food in item.foods)
                              TextSpan(
                                children: [
                                  TextSpan(text: '- ${food.name}'),
                                  // TODO: Display allergens and labels here
                                  if (item.foods.last != food)
                                    const TextSpan(text: '\n'),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        const SliverSafeArea(
          sliver: SliverPadding(padding: .symmetric(vertical: 16)),
        ),
      ],
    );
  }
}
