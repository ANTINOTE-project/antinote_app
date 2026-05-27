import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/index.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class Slot {
  final List<Class> classes;
  final DateTime start;
  final DateTime end;
  final int index;
  final bool isPause;

  const Slot({
    required this.classes,
    required this.start,
    required this.end,
    required this.index,
    this.isPause = false,
  });
}

typedef ClassInfo = ({
  String baseTitle,
  String? status,
  String attendants,
  String? groups,
  String? location,
  DateTime start,
  DateTime end,
  int? accentColor,
  bool cancelled,
  bool isExam,
});

class TimetableBody extends StatelessWidget {
  final SpecificInstanceParameters data;

  final List<DateTime> days;
  final Classes classes;

  const TimetableBody({super.key, required this.data, required this.days, required this.classes});

  bool _isWeekend(DateTime day) {
    return !data.businessDays.contains(day.weekday);
  }

  Holiday? _getHolidayForDay(DateTime day) {
    for (final holiday in data.holidays) {
      if (holiday.contains(day)) return holiday;
    }

    return null;
  }

  Pause? _getPauseOrNull(Slot slot) {
    return data.pauses.firstWhereOrNull((p) => p.slot == slot.index + 1);
  }

  bool _isLunch(Slot slot) {
    return slot.index >= data.lunchStartSlot && slot.index <= data.lunchEndSlot;
  }

  List<Slot> _buildSlots(List<Class> classes, DateTime day) {
    final covered = <(DateTime, DateTime)>[];

    for (final clazz in classes) {
      covered.add((clazz.startDate, clazz.endDate));
    }

    final cleaned = <Slot>[];
    final slots = <Slot>[];

    for (final (index, timeSlot) in data.starts.indexed) {
      final slotClasses = classes.where((c) {
        return c.startDate.hour == timeSlot.timing.hour &&
            c.startDate.minute == timeSlot.timing.minute;
      }).toList();

      final start = day.copyWith(hour: timeSlot.timing.hour, minute: timeSlot.timing.minute);

      final isAlreadyCovered = covered.any((r) => start.isAfter(r.$1) && start.isBefore(r.$2));
      if (isAlreadyCovered) continue;

      if (index >= data.endings.length) continue;

      final end = day.copyWith(
        hour: slotClasses.firstOrNull?.endDate.hour ?? data.endings[index].timing.hour,
        minute: slotClasses.firstOrNull?.endDate.minute ?? data.endings[index].timing.minute,
      );

      final slot = Slot(index: index, start: start, end: end, classes: slotClasses);

      slots.add(slot);
    }

    for (final pause in data.pauses) {
      if (pause.slot >= data.starts.length) continue;

      final start = day.copyWith(
        hour: data.starts[pause.slot - 1].timing.hour,
        minute: data.starts[pause.slot - 1].timing.minute,
      );

      final end = day.copyWith(
        hour: data.starts[pause.slot].timing.hour,
        minute: data.starts[pause.slot].timing.minute,
      );

      final slot = Slot(index: pause.slot - 1, start: start, end: end, classes: [], isPause: true);

      slots.add(slot);
    }

    slots.sort((a, b) => a.index.compareTo(b.index));

    for (final slot in slots) {
      final isNaturalEmptyWithPauseAtSameIndex =
          !slot.isPause &&
          slot.classes.isEmpty &&
          slots.any((s) => s.isPause && s.index == slot.index);

      if (isNaturalEmptyWithPauseAtSameIndex) continue;

      if (slot.classes.isEmpty &&
          !slot.isPause &&
          cleaned.isNotEmpty &&
          cleaned.last.classes.isEmpty) {
        continue;
      }

      cleaned.add(slot);
    }

    slots
      ..clear()
      ..addAll(cleaned);

    // remove all courses in first if they have no classes
    while (slots.isNotEmpty && slots.first.classes.isEmpty) {
      slots.removeAt(0);
    }

    // remove all courses in last if they have no classes
    while (slots.isNotEmpty && slots.last.classes.isEmpty) {
      slots.removeLast();
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    return SliverCrossAxisGroup(
      slivers: [
        for (final day in days)
          ValueListenableBuilder(
            valueListenable: classes[day]!,

            builder: (context, dayClasses, child) {
              final holiday = _getHolidayForDay(day);
              final isWeekend = _isWeekend(day);
              final hasNotClasses = dayClasses == null;
              final isClassesEmpty = dayClasses?.isEmpty ?? true;

              if (isWeekend) {
                return _InfoTextIcon(icon: HugeIconsSolid.calendar04, label: context.l10n.weekend);
              }

              if (holiday != null) {
                return _InfoTextIcon(icon: HugeIconsSolid.beach, label: holiday.name);
              }

              if (hasNotClasses) {
                return const _Loading();
              }

              if (isClassesEmpty) {
                return _InfoTextIcon(
                  icon: HugeIconsSolid.course,
                  label: context.l10n.noCourseToday,
                );
              }

              final slots = _buildSlots(dayClasses, day);

              return SliverPadding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 10,

                  right: 12,
                  left: 12,
                ),

                sliver: SliverList.builder(
                  itemCount: slots.length,

                  itemBuilder: (context, index) {
                    final slot = slots[index];

                    if (slot.classes.isEmpty) {
                      final nextCourseSlot = slots
                          .sublist(index + 1)
                          .firstWhereOrNull((s) => s.classes.isNotEmpty);

                      if (nextCourseSlot == null) return const SizedBox.shrink();

                      final pausesBetween = slots
                          .sublist(index + 1)
                          .where((s) => s.isPause && s.start.isBefore(nextCourseSlot.start))
                          .fold(Duration.zero, (acc, s) => acc + s.end.difference(s.start));

                      final duration = slot.isPause
                          ? slot.end.difference(slot.start)
                          : nextCourseSlot.start.difference(slot.start) - pausesBetween;

                      final pause = _getPauseOrNull(slot);
                      final isLunch = _isLunch(slot);

                      final (type, label) = switch ((pause, isLunch)) {
                        (Pause p, _) => (_GapType.pause, p.label),
                        (_, true) => (_GapType.lunch, context.l10n.lunch),
                        _ => (_GapType.free, context.l10n.gap(Utils.formatDuration(duration))),
                      };

                      return _Gap(type: type, label: label, duration: duration);
                    }

                    return _TimeRow(start: slot.start, end: slot.end, classes: slot.classes);
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
  }
}

class _InfoTextIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoTextIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: .center,
          spacing: 6,

          children: [
            Icon(icon, size: 44, color: context.c.outline),

            Text(
              label,

              style: TextStyle(fontWeight: .bold, color: context.c.outline),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}

enum _GapType { lunch, pause, free }

class _Gap extends StatelessWidget {
  final Duration duration;
  final _GapType type;
  final String label;

  const _Gap({required this.type, required this.duration, required this.label});

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      _GapType.lunch => HugeIconsSolid.servingFood,
      _GapType.pause => HugeIconsSolid.pause,
      _GapType.free => HugeIconsSolid.clock01,
    };

    return Row(
      spacing: 10,

      children: [
        const SizedBox(width: 56),

        Expanded(
          child: Padding(
            padding: const .only(bottom: 12, top: 4),

            child: Container(
              decoration: BoxDecoration(
                color: context.c.surfaceContainerHigh,
                border: .all(color: context.c.outlineVariant),
                borderRadius: const .all(.circular(20)),
              ),

              padding: const .all(12),

              child: Row(
                spacing: 8,

                children: [
                  Icon(icon, color: context.c.onSurfaceVariant),

                  Expanded(
                    child: Text(
                      label,

                      style: TextStyle(
                        color: context.c.onSurfaceVariant,
                        fontWeight: .w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeRow extends StatefulWidget {
  final DateTime start;
  final DateTime end;
  final List<Class> classes;

  const _TimeRow({required this.start, required this.end, required this.classes});

  @override
  State<_TimeRow> createState() => _TimeRowState();
}

class _TimeRowState extends State<_TimeRow> {
  bool get _hasMultipleCourses => widget.classes.length > 1;

  Class get _currentClass => widget.classes[_classIndex];
  int _classIndex = 0;

  String _fmt(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,

          children: [
            SizedBox(
              width: 56,

              child: Column(
                mainAxisAlignment: .center,

                children: [
                  Text(_fmt(widget.start), style: const TextStyle(fontSize: 17, fontWeight: .w900)),

                  Text(
                    _fmt(widget.end),
                    style: TextStyle(fontSize: 15, fontWeight: .w600, color: context.c.outline),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _hasMultipleCourses
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),

                      switchInCurve: Curves.easeInOutCubic,
                      switchOutCurve: Curves.easeInOutCubic,

                      transitionBuilder: (child, animation) {
                        final offsetAnimation = Tween<Offset>(
                          begin: const Offset(0.2, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn));

                        return SlideTransition(
                          position: offsetAnimation,
                          child: FadeTransition(opacity: animation, child: child),
                        );
                      },

                      child: _ClassWidget(key: ValueKey(_currentClass.id), clazz: _currentClass),
                    )
                  : _ClassWidget(clazz: _currentClass),
            ),

            if (_hasMultipleCourses)
              Pressable(
                onPressed: () {
                  setState(() {
                    _classIndex = (_classIndex + 1) % widget.classes.length;
                  });
                },

                child: Container(
                  decoration: BoxDecoration(
                    color: context.c.surfaceContainerHigh,
                    borderRadius: const .all(.circular(20)),
                  ),

                  width: 30,

                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),

                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,

                    child: Icon(
                      key: ValueKey(_classIndex),
                      _classIndex == widget.classes.length - 1
                          ? HugeIconsSolid.arrowLeft01
                          : HugeIconsSolid.arrowRight01,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassWidget extends StatelessWidget {
  final Class clazz;

  const _ClassWidget({super.key, required this.clazz});

  @override
  Widget build(BuildContext context) {
    late final info = Utils.getInfoForClass(context, clazz);

    final (color, backgroundColor, borderColor, titleColor) = Utils.adaptColorPair(
      info.accentColor,
      context.c,
    );

    final difference = info.end.difference(info.start);
    final duration = Utils.formatDuration(difference);

    final cancelledBorder = BorderSide(color: context.c.error.withAlpha(125));
    final cancelledPadding = EdgeInsets.only(
      left: cancelledBorder.width,
      right: cancelledBorder.width,
      bottom: cancelledBorder.width,
    );

    final double bannerHeight = info.cancelled ? 30 : 0;
    final double cardHeight = 95 - bannerHeight;

    return Pressable(
      child: Stack(
        alignment: .bottomCenter,
        clipBehavior: .none,

        children: [
          if (info.cancelled)
            Container(
              decoration: BoxDecoration(
                borderRadius: const .all(.circular(20)),
                border: .fromBorderSide(cancelledBorder),
                color: context.c.errorContainer,
              ),

              padding: const .symmetric(horizontal: 12, vertical: 4),

              height: cardHeight + bannerHeight,
              width: .infinity,

              child: Column(
                mainAxisSize: .min,

                children: [
                  Row(
                    mainAxisSize: .min,
                    spacing: 8,

                    children: [
                      Icon(HugeIconsSolid.informationCircle, size: 18, color: context.c.error),

                      Expanded(
                        child: Text(
                          info.status ?? "",

                          overflow: .ellipsis,
                          maxLines: 1,

                          style: TextStyle(fontSize: 15, fontWeight: .w900, color: context.c.error),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: cardHeight - cancelledBorder.width),
                ],
              ),
            ),

          Padding(
            padding: info.cancelled ? cancelledPadding : .zero,

            child: Container(
              decoration: BoxDecoration(
                color: info.cancelled ? context.c.outlineVariant : backgroundColor,
                border: info.cancelled ? null : .all(color: borderColor),
                borderRadius: const .all(.circular(20)),
              ),

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              height: cardHeight,

              child: Column(
                crossAxisAlignment: .start,
                spacing: 4,

                children: [
                  Text(
                    info.baseTitle,

                    overflow: .ellipsis,
                    maxLines: 1,

                    style: TextStyle(
                      color: info.cancelled ? context.c.outline : titleColor,
                      fontSize: 18,
                      fontWeight: .w800,
                    ),
                  ),

                  Expanded(
                    child: Row(
                      spacing: 6,

                      children: [
                        if (info.location != null) ...[
                          _InfoWidget(
                            cancelled: info.cancelled,
                            icon: HugeIconsSolid.location01,
                            label: info.location ?? "",
                            color: color,
                          ),

                          SizedBox(
                            height: 16,

                            child: VerticalDivider(
                              color: info.cancelled ? context.c.outline : color,
                              radius: .circular(999),
                              thickness: 2,
                              width: 4,
                            ),
                          ),
                        ],

                        Expanded(
                          child: _InfoWidget(
                            cancelled: info.cancelled,
                            icon: HugeIconsSolid.teacher,
                            label: info.attendants,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!info.cancelled)
                    Text(
                      duration,
                      style: TextStyle(color: color, fontSize: 14, fontWeight: .w900),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoWidget extends StatelessWidget {
  final bool cancelled;
  final IconData icon;
  final String label;
  final Color color;

  const _InfoWidget({
    required this.cancelled,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,

      children: [
        Icon(icon, size: 20, color: cancelled ? context.c.outline : color),

        Flexible(
          child: Text(
            label,

            maxLines: 1,
            overflow: .ellipsis,

            style: TextStyle(
              fontSize: 14,
              fontWeight: .w600,
              color: cancelled ? context.c.outline : color,
            ),
          ),
        ),
      ],
    );
  }
}
