import "dart:math";

import "package:antinote/antinote.dart";
import "package:antinote_app/backend/src/state.dart";
import "package:antinote_app/frontend/screens/timetable/events/class/widget.dart";
import "package:antinote_app/frontend/screens/timetable/events/meal/widget.dart";
import "package:antinote_app/frontend/screens/timetable/events/pause/widget.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:collection/collection.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "../../../utils/utils.dart";

part "class/event.dart";
part "meal/event.dart";
part "pause/event.dart";

typedef DayBlocks = List<Block>;

sealed class Event {
  int get startSlot;
  DateTime get startTime;
  int get endSlot;
  DateTime get endTime;

  int get priority;

  const Event();
}

List<Event> eventsForDay(
  List<Class> classes,
  SpecificInstanceParameters parameters,
) {
  return [
    ...classEventsForDay(classes, parameters),
    ...pauseEventsForDay(classes, parameters),
    ...mealEventsForDay(classes, parameters),
  ]..sort((a, b) => a.startTime.compareTo(b.startTime));
}

final class Block {
  final List<List<Event>> configurations;

  final int startSlot;
  final DateTime startTime;

  final int endSlot;
  final DateTime endTime;

  const new({
    required this.configurations,
    required this.startSlot,
    required this.startTime,
    required this.endSlot,
    required this.endTime,
  });

  factory Block.createConfigurations({
    required List<Event> events,
    required int startSlot,
    required DateTime startTime,
    required int endSlot,
    required DateTime endTime,
  }) {
    final remaining = <int, List<Event>>{};

    int biggest = 0;
    for (final remainingEvent in events) {
      remaining
          .putIfAbsent(remainingEvent.priority, () => [])
          .add(remainingEvent);

      biggest = max(biggest, remainingEvent.priority);
    }

    for (final key in remaining.keys) {
      remaining[key]?.sort((a, b) => a.startTime.compareTo(b.startTime));
    }

    final configs = <List<Event>>[];
    final curConfig = <Event>[];

    while (remaining.values.any((element) => element.isNotEmpty)) {
      for (int i = 0; i <= biggest; i++) {
        if (!remaining.containsKey(i)) continue;
        final curCandidates = <Event>[];

        for (final candidate in remaining[i]!) {
          if (curConfig.any(
            (element) =>
                (!candidate.startTime.isBefore(element.startTime) &&
                    candidate.startTime.isBefore(element.endTime)) ||
                (!element.startTime.isBefore(candidate.startTime) &&
                    element.startTime.isBefore(candidate.endTime)),
          )) {
            continue;
          }

          curCandidates.add(candidate);
        }

        curConfig.addAll(curCandidates);
        remaining[i]!.removeWhere((element) => curCandidates.contains(element));
      }

      configs.add(curConfig.toList(growable: false));
      curConfig.clear();
    }

    return Block(
      configurations: configs,
      startSlot: startSlot,
      startTime: startTime,
      endSlot: endSlot,
      endTime: endTime,
    );
  }
}

List<Block> blocksForDay(
  List<Event> events,
  SpecificInstanceParameters parameters,
) {
  if (events.isEmpty) return const [];

  AppStateScheduler.scheduleForDay(
    events.first.startTime.toDay(),
    events: events,
    params: parameters,
  );

  final blocks = <Block>[];

  int? blockStart;
  DateTime? blockStartTime;
  int? blockEnd;
  DateTime? blockEndTime;
  List<Event> curEvents = [];

  for (final event in events) {
    if (blockStart == null) {
      blockStart = event.startSlot;
      blockStartTime = event.startTime;
      blockEnd = event.endSlot;
      blockEndTime = event.endTime;

      curEvents.add(event);

      continue;
    }

    if (event.startTime.isBefore(blockEndTime!)) {
      curEvents.add(event);
      if (event.endTime.isAfter(blockEndTime)) {
        blockEnd = event.endSlot;
        blockEndTime = event.endTime;
      }
    } else {
      blocks.add(
        Block.createConfigurations(
          events: curEvents,
          startSlot: blockStart,
          startTime: blockStartTime!,
          endSlot: blockEnd!,
          endTime: blockEndTime,
        ),
      );

      blockStart = event.startSlot;
      blockStartTime = event.startTime;
      blockEnd = event.endSlot;
      blockEndTime = event.endTime;

      curEvents.clear();
      curEvents.add(event);
    }
  }

  if (curEvents.isNotEmpty) {
    blocks.add(
      Block.createConfigurations(
        events: curEvents,
        startSlot: blockStart!,
        startTime: blockStartTime!,
        endSlot: blockEnd!,
        endTime: blockEndTime!,
      ),
    );
  }

  return blocks;
}

class BlockWidget extends StatefulWidget {
  const BlockWidget({super.key, required this.block});

  static const _radius = 16.0;
  static const _reducedRadius = 6.0;

  static const baseBorderRadius = BorderRadius.all(Radius.circular(_radius));
  static const connectedBorderRadius = BorderRadius.only(
    topLeft: .circular(_radius),
    bottomLeft: .circular(_radius),
    topRight: .circular(_reducedRadius),
    bottomRight: .circular(_reducedRadius),
  );

  final Block block;

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget> {
  int configurationIndex = 0;

  Widget _buildWidgetConfiguration(
    BuildContext context,
    List<Event> configuration,
  ) {
    configuration.sort((a, b) => a.startTime.compareTo(b.startTime));

    final display = <Widget>[];
    final borderRadius = widget.block.configurations.length > 1
        ? BlockWidget.connectedBorderRadius
        : BlockWidget.baseBorderRadius;

    var curTime = widget.block.startTime;
    for (final event in configuration) {
      final diff = event.startTime.difference(curTime);
      if (diff > Duration.zero) {
        display.add(
          Expanded(flex: diff.inMinutes, child: const SizedBox.expand()),
        );
      }

      display.add(
        Expanded(
          flex: event.endTime.difference(event.startTime).inMinutes,
          child: switch (event) {
            ClassEvent() => ClassWidget(
              clazz: event.value,
              borderRadius: borderRadius,
            ),
            MealEvent() => MealBlockWidget(
              block: event,
              borderRadius: borderRadius,
            ),
            PauseEvent() => PauseBlockWidget(
              block: event,
              borderRadius: borderRadius,
            ),
          },
        ),
      );

      curTime = event.endTime;
    }

    final lastDiff = widget.block.endTime.difference(curTime);
    if (lastDiff > Duration.zero) {
      display.add(
        Expanded(flex: lastDiff.inMinutes, child: const SizedBox.expand()),
      );
    }

    return Column(key: ValueKey(configurationIndex), children: display);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.configurations.length == 1) {
      return _buildWidgetConfiguration(
        context,
        widget.block.configurations.single,
      );
    }

    return Row(
      crossAxisAlignment: .stretch,
      children: [
        Expanded(
          flex: 89,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 50),
            switchInCurve: Curves.fastOutSlowIn,
            switchOutCurve: const ReversedCurve(Curves.fastOutSlowIn),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: IndexedStack(
              key: ValueKey(configurationIndex),
              index: configurationIndex,
              children: [
                for (final configuration in widget.block.configurations)
                  _buildWidgetConfiguration(context, configuration),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 11,
          child: Container(
            padding: const .only(left: 4),
            decoration: BoxDecoration(
              borderRadius: .horizontal(right: const .circular(20)),
              color: context.c.surfaceContainerLow,
            ),
            clipBehavior: .antiAlias,
            child: Column(
              children: [
                ...widget.block.configurations.mapIndexed((i, _) {
                  final borderRadius = BorderRadius.only(
                    bottomRight: i == 0 ? .zero : const .circular(16),
                    topLeft: i == 0 ? const .circular(4) : .zero,
                    topRight: i == widget.block.configurations.length - 1
                        ? .zero
                        : const .circular(16),
                    bottomLeft: i == widget.block.configurations.length - 1
                        ? const .circular(4)
                        : .zero,
                  );

                  return Expanded(
                    child: Pressable(
                      borderRadius: borderRadius,
                      onPressed: () {
                        if (i == configurationIndex) return;

                        setState(() => configurationIndex = i);
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          color: i == configurationIndex
                              ? context.c.secondaryContainer
                              : null,
                        ),
                        child: Container(
                          alignment: .center,
                          child: Text(
                            (i + 1).toString(),
                            style: const TextStyle(fontWeight: .w800),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
