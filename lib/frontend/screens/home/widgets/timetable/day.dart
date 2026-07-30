import 'package:antinote_app/frontend/screens/timetable/events/block.dart';
import 'package:flutter/material.dart';

class const TimetableDayWidgetSliver({
  super.key,
  required final DayBlocks value,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(child: Text('Timetable day'));
  }
}
