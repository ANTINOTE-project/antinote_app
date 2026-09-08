import 'package:antinote_api/antinote_api.dart';
import 'package:antinote_app/ui/screens/timetable/events/class/modal.dart';
import 'package:antinote_app/ui/utils/utils.dart';
import 'package:antinote_app/ui/widgets/overflow_row.dart';
import 'package:antinote_app/ui/widgets/pressable.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:material_ui/material_ui.dart';

import '../block.dart';

class ClassWidget extends StatelessWidget {
  final Class clazz;
  final BorderRadius borderRadius;
  final bool showTiming;

  const ClassWidget({
    super.key,
    required this.clazz,
    this.borderRadius = BlockWidget.baseBorderRadius,
    this.showTiming = false,
  });

  @override
  Widget build(BuildContext context) {
    final difference = clazz.endDate.difference(clazz.startDate);
    final canceled = clazz.canceled;
    ColorScheme scheme = context.c;

    if (clazz is Lesson) {
      final accent = (clazz as Lesson).accentColor;
      scheme = Utils.buildColorScheme(context, accent);
    }

    final timing = Formatters.formatDuration(difference);
    final timingMessage = switch (showTiming) {
      true when canceled => context.l10n.classTiming(
        clazz.startDate,
        clazz.endDate,
      ),
      true when !canceled => context.l10n.classTimingDuration(
        clazz.startDate,
        clazz.endDate,
        timing,
      ),
      false when canceled => null,
      false when !canceled => timing,
      _ => throw UnimplementedError(),
    };

    final hasStatus = clazz.status != null;

    return Pressable(
      borderRadius: borderRadius,

      onPressed: () async {
        await showClassModal(context, clazz);
      },

      child: Ink(
        decoration: BoxDecoration(
          color: canceled
              ? scheme.surfaceContainerLow
              : scheme.primaryContainer,

          borderRadius: borderRadius,
        ),

        padding: .symmetric(horizontal: 10, vertical: canceled ? 8 : 6),
        width: double.infinity,

        child: Column(
          crossAxisAlignment: .start,
          mainAxisAlignment: .center,

          children: [
            if (hasStatus)
              Ink(
                decoration: BoxDecoration(
                  borderRadius: .circular(8),
                  color: canceled
                      ? scheme.errorContainer
                      : scheme.surfaceContainer,
                ),

                padding: const .symmetric(horizontal: 6, vertical: 3),

                child: Row(
                  mainAxisSize: .min,
                  spacing: 6,

                  children: [
                    Icon(
                      canceled
                          ? HugeIconsSolid.alertCircle
                          : HugeIconsSolid.informationCircle,
                      color: canceled ? scheme.error : scheme.secondary,
                      size: 18,
                    ),

                    Flexible(
                      child: Text(
                        clazz.status ?? '',

                        overflow: .ellipsis,
                        maxLines: 1,

                        style: TextStyle(
                          color: canceled ? scheme.error : scheme.secondary,
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
              spacing: canceled ? 0 : 2,

              children: [
                Text(
                  clazz.classTitle(context),

                  overflow: .ellipsis,
                  maxLines: 1,

                  style: TextStyle(
                    color: canceled ? scheme.outline : scheme.primary,
                    fontWeight: canceled ? .bold : .w800,
                    fontSize: canceled ? 21 : 22,
                    height: canceled ? 1 : 1.2,
                  ),
                ),

                _ContentOverflowRow(
                  contents: clazz.listContents(),
                  color: canceled ? scheme.outline : scheme.onPrimaryContainer,
                  dividerColor: canceled
                      ? scheme.outline
                      : scheme.onPrimaryContainer,
                ),

                if (timingMessage != null)
                  Text(
                    timingMessage,

                    style: TextStyle(
                      color: scheme.secondary,
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
    if (contents.isEmpty) return const SizedBox.shrink();

    return OverflowRow(
      spacing: 6,
      badgeStyle: TextStyle(color: color, fontWeight: .w800, fontSize: 12),
      badgeDecoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: .circular(90),
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
      decoration: BoxDecoration(borderRadius: .circular(90), color: color),
      margin: const .symmetric(vertical: 4),

      height: 16,
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
        v.get('L'),
        HugeIconsSolid.fileUnknown,
      ),
      _ => (null, null),
    };

    return Row(
      mainAxisSize: .min,
      spacing: 4,

      children: [
        if (icon != null) Icon(icon, color: color, size: 18),

        if (data != null)
          Text(
            data,
            style: TextStyle(color: color, fontWeight: .bold),
          ),
      ],
    );
  }
}
