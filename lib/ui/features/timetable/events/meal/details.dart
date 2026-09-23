import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/app_bar.dart';
import 'package:antinote_app/ui/widgets/list.dart';
import 'package:antinote_app/ui/widgets/loading.dart';
import 'package:antinote_app/ui/widgets/text_icon.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';

Future<void> showMealDetails(BuildContext context, DateTime date) async {
  final mealCallback = context.ar.runTask<Menu?>(
    context: context,
    callback: (session) async {
      return (await session.access(MenuPageAccessor(date: date))).menus
          .firstWhereOrNull((element) => element.time.isAtSameMomentAs(date));
    },
    debugLabel: 'Fetch detailed data about menu',
  );

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MealDetailsScreen(mealCallback: mealCallback),
    ),
  );
}

class MealDetailsScreen extends StatelessWidget {
  final Future<Menu?> mealCallback;

  const MealDetailsScreen({super.key, required this.mealCallback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: Text(context.l10n.menu)),

      body: FutureBuilder(
        future: mealCallback,

        builder: (context, snapshot) {
          final Widget child;

          if (snapshot.connectionState == .done) {
            if (snapshot.hasData && snapshot.requireData!.meals.isNotEmpty) {
              child = MealContents(menu: snapshot.requireData!);
            } else {
              // TODO: Create a normalized error display.
              child = Padding(
                padding: const .symmetric(vertical: 40),
                child: Center(child: Text(context.l10n.noMenuForToday)),
              );
            }
          } else {
            child = const Padding(
              padding: .symmetric(vertical: 40),
              child: Center(child: LoadingWidget(size: 22)),
            );
          }

          return SingleChildScrollView(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              alignment: .topCenter,
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class MealContents extends StatelessWidget {
  const MealContents({
    super.key,
    required this.menu,
    this.addPadding = true,
    this.invertColor = false,
    this.padding = const .symmetric(horizontal: 12),
  });

  final Menu menu;
  final bool addPadding;
  final bool invertColor;

  final EdgeInsetsGeometry? padding;

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
      padding: padding,

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
                      backgroundColor: invertColor
                          ? context.c.surfaceContainerLow
                          : null,

                      titleMaxLines: null,
                      title: Text.rich(
                        TextSpan(
                          children: [
                            for (final food in item.foods)
                              TextSpan(
                                children: [
                                  TextSpan(text: '- ${food.name.trim()}'),
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

          if (addPadding)
            const SafeArea(child: Padding(padding: .symmetric(vertical: 16))),
        ],
      ),
    );
  }
}
