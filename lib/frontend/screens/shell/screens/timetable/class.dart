import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/utils.dart";
import "package:collection/collection.dart";
import "package:flutter/material.dart";
import "package:hugeicons_pro/hugeicons.dart";

class ClassWidget extends StatelessWidget {
  final Class clazz;
  final bool connectRight;

  const ClassWidget({
    super.key,
    required this.clazz,
    required this.connectRight,
  });

  String classTitle(BuildContext context) =>
      clazz.contents
          .where(
            (element) => element is TitleContent || element is SubjectContent,
          )
          .map(
            (e) =>
                e is TitleContent ? e.value : (e as SubjectContent).value.name,
          )
          .firstOrNull ??
      context.l10n.noSubject;

  static const _contentPriorities = [
    ClassroomContent,
    TeacherContent,
    UnknownContent,
    ClassGroupContent,
    PersonalContent,
    VirtualClassroomContent,
  ];

  List<ClassContent> listContents() =>
      clazz.contents
          .where(
            (element) => element is! TitleContent && element is! SubjectContent,
          )
          .toList(growable: false)
        ..sortByCompare(
          (element) => element.runtimeType,
          (a, b) => _contentPriorities
              .indexOf(a)
              .compareTo(_contentPriorities.indexOf(b)),
        );

  @override
  Widget build(BuildContext context) {
    final difference = clazz.endDate.difference(clazz.startDate);
    final ColorScheme? scheme;

    if (clazz is Lesson) {
      final accent = (clazz as Lesson).backgroundColor;

      if (accent != null) {
        scheme = Utils.buildColorScheme(context, accent);

        // accent is null
      } else {
        scheme = null;
      }

      // is not lesson
    } else {
      scheme = null;
    }

    final duration = Utils.formatDuration(difference);

    final statusBorder = BorderSide(
      color:
          (clazz.canceled
                  ? (scheme?.error ?? context.c.error)
                  : (scheme?.secondary ?? context.c.secondary))
              .withAlpha(128),
    );

    // TODO: fix pressable position
    return Expanded(
      flex: clazz.endDate.difference(clazz.startDate).inMinutes,

      child: Pressable(
        borderRadius: connectRight
            ? const .horizontal(left: .circular(20))
            : const .all(.circular(20)),

        child: Column(
          children: [
            if (clazz.status != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: connectRight
                      ? const .only(topLeft: .circular(20))
                      : const .vertical(top: .circular(20)),
                  border: .fromBorderSide(statusBorder),
                  color: clazz.canceled
                      ? context.c.errorContainer
                      : (scheme?.inversePrimary ?? context.c.inversePrimary),
                ),

                padding: const .symmetric(horizontal: 12, vertical: 4),
                width: .infinity,

                child: Column(
                  mainAxisAlignment: .center,

                  children: [
                    Row(
                      mainAxisSize: .min,
                      spacing: 6,

                      children: [
                        Icon(
                          clazz.canceled
                              ? HugeIconsSolid.alertCircle
                              : HugeIconsSolid.informationCircle,
                          size: 20,
                          color: clazz.canceled
                              ? context.c.error
                              : (scheme?.primary ?? context.c.primary),
                        ),

                        Expanded(
                          child: Text(
                            clazz.status ?? "",

                            overflow: .ellipsis,
                            maxLines: 1,

                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: .w800,
                              color: clazz.canceled
                                  ? context.c.error
                                  : (scheme?.primary ?? context.c.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            Expanded(
              child: Container(
                clipBehavior: .antiAlias,

                decoration: BoxDecoration(
                  color: clazz.canceled
                      ? scheme?.surfaceContainerLow
                      : scheme?.primaryContainer,

                  border: clazz.status != null
                      ? .fromLTRB(
                          bottom: statusBorder,
                          left: statusBorder,
                          right: statusBorder,
                        )
                      : .all(color: scheme?.outline ?? context.c.outline),

                  borderRadius: connectRight
                      ? (clazz.status != null
                            ? const .only(
                                bottomLeft: .circular(20),
                                topRight: .zero,
                                bottomRight: .zero,
                                topLeft: .zero,
                              )
                            : const .only(
                                bottomLeft: .circular(20),
                                topLeft: .circular(20),
                                bottomRight: .zero,
                                topRight: .zero,
                              ))
                      : (clazz.status != null
                            ? const .vertical(top: .zero, bottom: .circular(20))
                            : const .all(.circular(20))),
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                width: .infinity,

                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,

                  children: [
                    Text(
                      classTitle(context),

                      overflow: .ellipsis,
                      maxLines: 1,

                      style: TextStyle(
                        color: clazz.canceled
                            ? scheme?.onSurface
                            : scheme?.onPrimaryContainer,
                        fontWeight: clazz.canceled
                            ? FontWeight.normal
                            : const .new(750),
                        fontSize: 18,
                      ),
                    ),

                    Wrap(
                      spacing: 6,

                      children: [
                        for (final content in listContents())
                          _TimetableClassContent(
                            color: clazz.canceled
                                ? (scheme ?? context.c).onSurface
                                : (scheme ?? context.c).onPrimaryContainer,
                            content: content,
                            weight: clazz.canceled ? .w300 : .w600,
                          ),
                      ],
                    ),

                    if (!clazz.canceled)
                      Text(
                        duration,

                        style: TextStyle(
                          color: scheme?.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: .w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimetableClassContent extends StatelessWidget {
  const _TimetableClassContent({
    required this.color,
    required this.content,
    this.weight = .w600,
  });

  final ClassContent content;

  // TODO: Make this nullable.
  final Color color;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final (data: data, icon: icon) =
        switch (content) {
              TitleContent() => (data: null, icon: null),
              SubjectContent() => (data: null, icon: null),
              TeacherContent(value: final value) => (
                data: value.name,
                icon: HugeIconsSolid.teacher,
              ),
              PersonalContent(value: final value) => (
                data: value.name,
                icon: HugeIconsSolid.more, // TODO: find better icon
              ),
              ClassroomContent(value: final value) => (
                data: value.label,
                icon: HugeIconsSolid.school,
              ),
              VirtualClassroomContent(value: final value) => (
                data: context.l10n.virtualClassroom,
                icon: HugeIconsSolid.computerVideoCall,
              ),
              ClassGroupContent(value: final value) => (
                data: value.label,
                icon: HugeIconsSolid.group01,
              ),
              UnknownContent(value: final value) => (
                data: value.get("L"),
                icon: HugeIconsSolid.fileUnknown,
              ),
            }
            as ({String? data, IconData? icon});

    return Row(
      mainAxisSize: .min,

      children: [
        Icon(icon, color: color, fontWeight: FontWeight(weight.value - 250)),

        if (data != null)
          Text(
            data,
            style: TextStyle(color: color, fontWeight: weight),
          ),
      ],
    );
  }
}
