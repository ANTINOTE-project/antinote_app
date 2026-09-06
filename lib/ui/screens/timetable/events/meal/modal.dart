import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/customs/list.dart';
import 'package:antinote_app/ui/widgets/customs/loading.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

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
              child = MealContents(menu: snapshot.requireData!);
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
            child: SingleChildScrollView(child: child),
          );
        },
      );
    },
  );
}

class MealContents extends StatelessWidget {
  const MealContents({super.key, required this.menu});

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
    return Container(
      padding: const .symmetric(horizontal: 12),

      child: Column(
        spacing: 12,

        children: [
          for (final meal in menu.meals)
            Column(
              children: [
                TextIcon(label: mealTitle(context, meal).trim()),

                ListWidget(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  isSliver: false,
                  isColumn: true,
                  items: meal.dishes,

                  itemBuilder: (context, item, borderRadius) {
                    return TileWidget(
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

          const SafeArea(child: Padding(padding: .symmetric(vertical: 16))),
        ],
      ),
    );
  }
}
