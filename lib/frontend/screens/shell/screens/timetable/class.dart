import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/extensions/colors.dart";
import "package:antinote_app/frontend/extensions/l10n.dart";
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
    final ColorScheme? accentColorScheme;
    if (clazz is Lesson) {
      final accent = (clazz as Lesson).backgroundColor;
      if (accent != null) {
        accentColorScheme = ColorScheme.fromSeed(
          seedColor: Color(accent),
          dynamicSchemeVariant: .vibrant,
          brightness: context.c.brightness,
        );
      } else {
        accentColorScheme = null;
      }
    } else {
      accentColorScheme = null;
    }

    final duration = Utils.formatDuration(difference);

    final cancelledBorder = BorderSide(
      color: (accentColorScheme?.error ?? context.c.error).withAlpha(128),
    );

    return Pressable(
      child: Column(
        children: [
          if (clazz.canceled)
            Container(
              decoration: BoxDecoration(
                borderRadius: connectRight
                    ? const .only(
                        topLeft: .circular(20),
                        bottomLeft: .zero,
                        bottomRight: .zero,
                        topRight: .zero,
                      )
                    : const .vertical(top: .circular(20), bottom: .zero),
                border: .fromBorderSide(cancelledBorder),
                color: context.c.errorContainer,
              ),
              padding: const .symmetric(horizontal: 12, vertical: 4),
              width: .infinity,
              child: Column(
                mainAxisAlignment: .center,
                mainAxisSize: .min,
                children: [
                  Row(
                    mainAxisSize: .min,
                    spacing: 6,
                    children: [
                      Icon(
                        HugeIconsSolid.informationCircle,
                        size: 20,
                        color: context.c.error,
                      ),
                      Expanded(
                        child: Text(
                          clazz.status ?? "",

                          overflow: .ellipsis,
                          maxLines: 1,

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: .w800,
                            color: context.c.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: clazz.canceled
                  ? accentColorScheme?.surfaceContainerLow
                  : accentColorScheme?.primaryContainer,
              border: clazz.canceled
                  ? .fromLTRB(
                      bottom: cancelledBorder,
                      left: cancelledBorder,
                      right: cancelledBorder,
                    )
                  : .all(
                      color: accentColorScheme?.outline ?? context.c.outline,
                    ),
              borderRadius: connectRight
                  ? (clazz.canceled
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
                  : (clazz.canceled
                        ? const .vertical(top: .zero, bottom: .circular(20))
                        : const .all(.circular(20))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            width: .infinity,
            child: Column(
              spacing: 4,
              crossAxisAlignment: .start,
              children: [
                Text(
                  classTitle(context),
                  overflow: .ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: clazz.canceled
                        ? accentColorScheme?.onSurface
                        : accentColorScheme?.onPrimaryContainer,
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
                      TimetableClassContent(
                        color: clazz.canceled
                            ? (accentColorScheme ?? context.c).onSurface
                            : (accentColorScheme ?? context.c)
                                  .onPrimaryContainer,
                        content: content,
                        weight: clazz.canceled ? .w300 : .w600,
                      ),
                  ],
                ),
                if (!clazz.canceled)
                  Text(
                    duration,
                    style: TextStyle(
                      color: accentColorScheme?.onSurface.withAlpha(128),
                      fontSize: 14,
                      fontWeight: .w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimetableClassContent extends StatelessWidget {
  const TimetableClassContent({
    super.key,
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
