import "package:flutter/material.dart";

enum AppState { classBreak, transfer, lunch, pause, clazz, defaultState }

typedef AppStateEntry = ({DateTimeRange range, AppState state});

// class AppStateScheduler {
//   static List<AppStateEntry> scheduleForDay(
//     Date day, {
//     required List<Event> blocks,
//     required SpecificInstanceParameters params,
//   }) {
//     final List<AppStateEntry> entries = [];
//
//     for (final block in blocks) {
//       entries.addAll(switch (block) {
//         ClassEvent() => _scheduleForClassBlock(block),
//         MealEvent() => throw UnimplementedError(),
//         PauseBlock() => throw UnimplementedError(),
//       });
//     }
//   }
//
//   static List<AppStateEntry> _scheduleForClassBlock(ClassEvent block) {}
// }
