import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
import "package:antinote_app/frontend/screens/shell/screens/timetable/index.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

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

class TimetableBody extends StatefulWidget {
  final List<int> businessDays;
  final List<Holiday> holidays;
  final List<DateTime> days;
  final Classes classes;

  final int lunchStartSlot;
  final int lunchEndSlot;

  const TimetableBody({
    super.key,

    required this.businessDays,
    required this.holidays,
    required this.days,
    required this.classes,

    required this.lunchStartSlot,
    required this.lunchEndSlot,
  });

  @override
  State<TimetableBody> createState() => _TimetableBodyState();
}

class _TimetableBodyState extends State<TimetableBody> {
  static Holiday? _getHoliday(List<Holiday> holidays, DateTime day) {
    for (final holiday in holidays) {
      if (holiday.contains(day)) {
        return holiday;
      }
    }

    return null;
  }

  static Map<(DateTime, DateTime), List<Class>> _groupByTime(List<Class> classes) {
    final Map<(DateTime, DateTime), List<Class>> grouped = {};

    for (final c in classes) {
      final key = (c.startDate, c.endDate);
      grouped.putIfAbsent(key, () => []).add(c);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return SliverCrossAxisGroup(
      slivers: [
        for (final day in widget.days)
          ValueListenableBuilder(
            valueListenable: widget.classes[day]!,

            builder: (context, dayClasses, child) {
              final isBusinessDay = widget.businessDays.contains(day.weekday);
              final holiday = _getHoliday(widget.holidays, day);

              if (!isBusinessDay) {
                return _InfoTextIcon(icon: HugeIconsSolid.calendar04, label: context.l10n.weekend);
              }

              if (holiday != null) {
                return _InfoTextIcon(icon: HugeIconsSolid.beach, label: holiday.name);
              }

              if (dayClasses == null) {
                return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
              }

              if (dayClasses.isEmpty) {
                return _InfoTextIcon(
                  icon: HugeIconsSolid.course,
                  label: context.l10n.noCourseToday,
                );
              }

              final grouped = _groupByTime(dayClasses);

              for (final entry in grouped.values) {
                entry.sort((a, b) {
                  final aCancelled = a is Lesson && (a.canceled || a.exemptedLabel != null);
                  final bCancelled = b is Lesson && (b.canceled || b.exemptedLabel != null);

                  return aCancelled ? 1 : (bCancelled ? -1 : 0);
                });
              }

              final entries = grouped.entries.toList();

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),

                sliver: SliverList.builder(
                  itemCount: entries.length,

                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _TimeRow(start: entry.key.$1, end: entry.key.$2, classes: entry.value);
                  },
                ),
              );
            },
          ),
      ],
    );
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

    final (color, backgroundColor, borderColor) = Utils.adaptColorPair(info.accentColor, context.c);

    final difference = info.end.difference(info.start);
    final duration =
        "${difference.inHours > 0 ? "${difference.inHours}h " : ""}${difference.inMinutes % 60} min";

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
                      color: info.cancelled ? context.c.outline : context.c.onPrimary,
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
                          ),

                          SizedBox(
                            height: 20,

                            child: VerticalDivider(
                              color: info.cancelled
                                  ? context.c.outline
                                  : context.c.onSurfaceVariant,
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
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (!info.cancelled)
                    Text(
                      duration,
                      style: TextStyle(
                        color: context.c.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: .w900,
                      ),
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

  const _InfoWidget({required this.cancelled, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,

      children: [
        Icon(icon, size: 20, color: cancelled ? context.c.outline : context.c.onSurfaceVariant),

        Flexible(
          child: Text(
            label,

            maxLines: 1,
            overflow: .ellipsis,

            style: TextStyle(
              fontSize: 14,
              fontWeight: .w600,
              color: cancelled ? context.c.outline : context.c.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
