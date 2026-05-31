import "package:antinote/antinote.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class TimetableAppBar extends StatelessWidget {
  final void Function(DateTime day) animateToDay;
  final DateTime firstDate;
  final DateTime lastDate;
  final String label;

  const TimetableAppBar({
    super.key,
    required this.animateToDay,
    required this.label,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      title: TextButton.icon(
        label: Text(label),

        icon: const Icon(HugeIconsSolid.calendar03),
        iconAlignment: .end,

        onPressed: () async {
          final selected = await showDatePicker(
            context: context,
            firstDate: firstDate,
            lastDate: lastDate,
          );

          if (selected == null) return;

          animateToDay(selected.copyWith(isUtc: true).toDay());
        },
      ),
    );
  }
}
