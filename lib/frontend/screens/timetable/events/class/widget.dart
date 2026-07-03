import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/screens/timetable/events/block.dart";
import "package:antinote_app/frontend/screens/timetable/modal.dart";
import "package:antinote_app/frontend/utils/utils.dart";
import "package:antinote_app/frontend/widgets/overflow_row.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class ClassBlockWidget extends StatefulWidget {
  final SpecificInstanceParameters displayParameters;
  final DateTime day;
  final ClassBlock block;

  const ClassBlockWidget({
    super.key,
    required this.displayParameters,
    required this.day,
    required this.block,
  });

  @override
  State<ClassBlockWidget> createState() => _ClassBlockWidgetState();
}

class _ClassBlockWidgetState extends State<ClassBlockWidget> {
  int configurationIndex = 0;

  Widget _buildWidgetConfiguration(
    BuildContext context,
    List<Class> configuration,
  ) {
    configuration.sort((a, b) => a.startDate.compareTo(b.startDate));

    final display = <Widget>[];

    var curTime = widget.block.startTime;
    for (final clazz in configuration) {
      final diff = clazz.startDate.difference(curTime);
      if (diff > Duration.zero) {
        display.add(
          Expanded(flex: diff.inMinutes, child: const SizedBox.expand()),
        );
      }

      display.add(
        Expanded(
          flex: clazz.endDate.difference(clazz.startDate).inMinutes,
          child: ClassWidget(
            clazz: clazz,
            connectRight: widget.block.configurations.length > 1,
          ),
        ),
      );

      curTime = clazz.endDate;
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

class ClassWidget extends StatelessWidget {
  final Class clazz;
  final bool connectRight;

  const ClassWidget({
    super.key,
    required this.clazz,
    required this.connectRight,
  });

  static const double radius = 16;
  static const double reducedRadius = 6;

  @override
  Widget build(BuildContext context) {
    final difference = clazz.endDate.difference(clazz.startDate);
    ColorScheme scheme = context.c;

    if (clazz is Lesson) {
      final accent = (clazz as Lesson).accentColor;
      scheme = Utils.buildColorScheme(context, accent);
    }

    final duration = Formatters.formatDuration(difference);

    final outerBorderRadius = connectRight
        ? const BorderRadius.only(
            topLeft: .circular(radius),
            bottomLeft: .circular(radius),
            topRight: .circular(reducedRadius),
            bottomRight: .circular(reducedRadius),
          )
        : BorderRadius.circular(radius);

    final contentBorderRadius = connectRight
        ? const BorderRadius.only(
            topLeft: .circular(radius),
            bottomLeft: .circular(radius),
            topRight: .circular(reducedRadius),
            bottomRight: .circular(reducedRadius),
          )
        : BorderRadius.circular(radius);

    final isCanceled = clazz.canceled;
    final hasStatus = clazz.status != null;

    return Pressable(
      borderRadius: outerBorderRadius,

      onPressed: () async {
        await showClassModal(context, clazz);
      },

      child: Ink(
        decoration: BoxDecoration(
          color: isCanceled
              ? scheme.surfaceContainerLow
              : scheme.primaryContainer,
          border: Border.all(
            color: hasStatus
                ? isCanceled
                      ? scheme.error
                      : scheme.secondary
                : scheme.inversePrimary,
          ),
          borderRadius: contentBorderRadius,
        ),

        padding: const .symmetric(horizontal: 10, vertical: 5),
        width: double.infinity,

        child: Column(
          crossAxisAlignment: .start,
          spacing: 2,

          children: [
            if (hasStatus)
              Ink(
                decoration: BoxDecoration(
                  borderRadius: .circular(8),
                  color: isCanceled
                      ? scheme.errorContainer
                      : scheme.surfaceContainer,
                ),

                padding: const .symmetric(horizontal: 8, vertical: 4),

                child: Row(
                  mainAxisSize: .min,
                  spacing: 6,

                  children: [
                    Icon(
                      isCanceled
                          ? HugeIconsSolid.alertCircle
                          : HugeIconsSolid.informationCircle,
                      color: isCanceled ? scheme.error : scheme.secondary,
                      size: 18,
                    ),

                    Flexible(
                      child: Text(
                        clazz.status ?? "",

                        overflow: .ellipsis,
                        maxLines: 1,

                        style: TextStyle(
                          color: isCanceled ? scheme.error : scheme.secondary,
                          fontWeight: .w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Column(
              crossAxisAlignment: .start,
              spacing: isCanceled ? 0 : 2,

              children: [
                Text(
                  clazz.classTitle(context),

                  overflow: .ellipsis,
                  maxLines: 1,

                  style: TextStyle(
                    color: isCanceled ? scheme.outline : scheme.primary,
                    fontWeight: isCanceled ? .bold : .w800,
                    fontSize: isCanceled ? 21 : 22,
                  ),
                ),

                _ContentOverflowRow(
                  contents: clazz.listContents(),
                  color: isCanceled
                      ? scheme.outline
                      : scheme.onPrimaryContainer,
                  dividerColor: scheme.outline,
                ),

                if (!isCanceled)
                  Text(
                    duration,

                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontWeight: .w800,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentOverflowRow extends StatelessWidget {
  final List<ClassContent> contents;
  final Color color;
  final Color dividerColor;

  const _ContentOverflowRow({
    required this.contents,
    required this.color,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowRow(
      spacing: 6,
      badgeStyle: TextStyle(color: color, fontWeight: .w800, fontSize: 12),
      badgeDecoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: .circular(999),
      ),
      children: [
        for (int i = 0; i < contents.length; i++)
          Row(
            mainAxisSize: .min,
            spacing: 6,
            children: [
              if (i > 0) _Divider(color: dividerColor),
              _ClassContent(color: color, content: contents[i]),
            ],
          ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;

  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: .circular(999), color: color),
      margin: const .symmetric(vertical: 4),

      height: 18,
      width: 2,
    );
  }
}

class _ClassContent extends StatelessWidget {
  final ClassContent content;
  final Color color;

  const _ClassContent({required this.content, required this.color});

  @override
  Widget build(BuildContext context) {
    final (String? data, IconData? icon) = switch (content) {
      TeacherContent(value: final v) => (v.name, HugeIconsSolid.teacher),

      // TODO: find better icon
      PersonalContent(value: final v) => (v.name, HugeIconsSolid.more),

      ClassroomContent(value: final v) => (v.label, HugeIconsSolid.meetingRoom),

      VirtualClassroomContent() => (
        context.l10n.virtualClassroom,
        HugeIconsSolid.computerVideoCall,
      ),

      ClassGroupContent(value: final v) => (v.label, HugeIconsSolid.userGroup),

      UnknownContent(value: final v) => (
        v.get("L"),
        HugeIconsSolid.fileUnknown,
      ),
      _ => (null, null),
    };

    return Row(
      mainAxisSize: .min,
      spacing: 4,

      children: [
        if (icon != null) Icon(icon, color: color, size: 19),

        if (data != null)
          Text(
            data,
            style: TextStyle(color: color, fontWeight: .bold),
          ),
      ],
    );
  }
}
