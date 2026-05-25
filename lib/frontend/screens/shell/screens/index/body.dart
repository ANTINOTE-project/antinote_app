import "package:antinote_app/frontend/screens/auth/search/widgets/item.dart";
import "package:antinote_app/frontend/screens/shell/screens/index/timetable.dart";
import "package:flutter/material.dart";

class TimetableBody extends StatelessWidget {
  final List<DateTime> days;
  final Classes classes;

  const TimetableBody({super.key, required this.days, required this.classes});

  @override
  Widget build(BuildContext context) {
    return SliverCrossAxisGroup(
      slivers: [
        for (final day in days)
          ValueListenableBuilder(
            valueListenable: classes[day]!,

            builder: (context, classes, child) {
              if (classes != null) {
                return SliverList.builder(
                  itemCount: classes.length,

                  itemBuilder: (context, index) {
                    final clazz = classes[index];
                    return ListItemCard(onPressed: null, title: clazz.id);
                  },
                );

                // if loading
              } else {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }
            },
          ),
      ],
    );
  }
}
