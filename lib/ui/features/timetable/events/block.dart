import 'dart:math';

import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/features/timetable/events/class/widget.dart';
import 'package:antinote_app/ui/features/timetable/events/meal/widget.dart';
import 'package:antinote_app/ui/features/timetable/events/pause/widget.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../../../utils/utils.dart';

part 'class/event.dart';
part 'meal/event.dart';
part 'pause/event.dart';

typedef DayBlocks = List<Block>;

sealed class Event {
  DateTimeRange get range;

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
  ]..sort((a, b) => a.range.start.compareTo(b.range.start));
}

final class Block {
  final List<List<Event>> configurations;

  final DateTime startTime;
  final DateTime endTime;

  const new({
    required this.configurations,
    required this.startTime,
    required this.endTime,
  });

  factory Block.createConfigurations({
    required List<Event> events,
    required DateTimeRange range,
  }) {
    final remaining = <int, List<Event>>{};

    int biggest = 0;
    for (final remainingEvent in events) {
      if (remainingEvent.range.duration == .zero) {
        continue;
      }

      remaining
          .putIfAbsent(remainingEvent.priority, () => [])
          .add(remainingEvent);

      biggest = max(biggest, remainingEvent.priority);
    }

    for (final key in remaining.keys) {
      remaining[key]?.sort((a, b) => a.range.start.compareTo(b.range.start));
    }

    final configs = <List<Event>>[];
    final curConfig = <Event>[];

    while (remaining.values.any((element) => element.isNotEmpty)) {
      for (int i = 0; i <= biggest; i++) {
        if (!remaining.containsKey(i)) continue;
        final curCandidates = <Event>[];

        for (final candidate in remaining[i]!) {
          if ((curCandidates + curConfig).any(
            (element) => candidate.range.rangeOverlaps(element.range),
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
      startTime: range.start,
      endTime: range.end,
    );
  }
}

List<Block> blocksForDay(
  List<Event> events,
  SpecificInstanceParameters parameters,
) {
  if (events.isEmpty) return const [];

  final blocks = <Block>[];

  DateTime? blockStartTime;
  DateTime? blockEndTime;
  List<Event> curEvents = [];

  for (final event in events) {
    if (blockStartTime == null) {
      blockStartTime = event.range.start;
      blockEndTime = event.range.end;

      curEvents.add(event);

      continue;
    }

    if (event.range.start.isBefore(blockEndTime!)) {
      curEvents.add(event);
      if (event.range.end.isAfter(blockEndTime)) {
        blockEndTime = event.range.end;
      }
    } else {
      blocks.add(
        Block.createConfigurations(
          events: curEvents,
          range: DateTimeRange(start: blockStartTime, end: blockEndTime),
        ),
      );

      blockStartTime = event.range.start;
      blockEndTime = event.range.end;

      curEvents.clear();
      curEvents.add(event);
    }
  }

  if (curEvents.isNotEmpty) {
    blocks.add(
      Block.createConfigurations(
        events: curEvents,
        range: DateTimeRange(start: blockStartTime!, end: blockEndTime!),
      ),
    );
  }

  return blocks;
}

class BlockWidget extends StatefulWidget {
  const BlockWidget({super.key, required this.block});

  static const _radius = 22.0;
  static const _reducedRadius = 6.0;

  static const baseBorderRadius = BorderRadius.all(.circular(_radius));
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
  int blockIndex = 0;

  Widget _buildWidgetConfiguration(
    BuildContext context,
    List<Event> configuration,
  ) {
    configuration.sort((a, b) => a.range.start.compareTo(b.range.start));

    final display = <Widget>[];
    final borderRadius = widget.block.configurations.length > 1
        ? BlockWidget.connectedBorderRadius
        : BlockWidget.baseBorderRadius;

    var curTime = widget.block.startTime;
    for (final event in configuration) {
      final diff = event.range.start.difference(curTime);
      if (diff > Duration.zero) {
        display.add(
          Expanded(flex: diff.inMinutes, child: const SizedBox.expand()),
        );
      }

      final durationMinutes = event.range.end
          .difference(event.range.start)
          .inMinutes;

      if (durationMinutes > 0) {
        display.add(
          Expanded(
            flex: durationMinutes,
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
      }

      curTime = event.range.end;
    }

    final lastDiff = widget.block.endTime.difference(curTime);
    if (lastDiff > Duration.zero) {
      display.add(
        Expanded(flex: lastDiff.inMinutes, child: const SizedBox.expand()),
      );
    }

    return Column(key: ValueKey(blockIndex), children: display);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.configurations.length == 1) {
      return _buildWidgetConfiguration(
        context,
        widget.block.configurations.single,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const .all(.circular(20)),
        color: context.c.surfaceContainerLow,
      ),
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            flex: 89,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              reverseDuration: const Duration(milliseconds: 50),
              switchInCurve: Curves.fastOutSlowIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: IndexedStack(
                key: ValueKey(blockIndex),
                index: blockIndex,
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
                          if (i == blockIndex) return;

                          setState(() => blockIndex = i);
                        },
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: borderRadius,
                            color: i == blockIndex
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
      ),
    );
  }
}
