import "package:antinote/antinote.dart";
import "package:antinote_app/frontend/widgets/overflow_row.dart";
import "package:antinote_app/frontend/widgets/pressable.dart";
import "package:antinote_app/main.dart";
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

  List<ClassContent> listContents() {
    return clazz.contents
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
  }

  @override
  Widget build(BuildContext context) {
    final difference = clazz.endDate.difference(clazz.startDate);
    ColorScheme scheme = context.c;

    if (clazz is Lesson) {
      final accent = (clazz as Lesson).backgroundColor;

      if (accent != null) {
        scheme = Utils.buildColorScheme(context, accent);
      }
    }

    final duration = Formatters.formatDuration(difference);

    final statusBorder = BorderSide(
      color: clazz.canceled ? scheme.error : scheme.secondary,
    );

    const double radius = 20;
    const double reducedRadius = 6;

    final outerBorderRadius = connectRight
        ? const BorderRadius.only(
            topLeft: .circular(radius),
            bottomLeft: .circular(radius),
            topRight: .circular(reducedRadius),
            bottomRight: .circular(reducedRadius),
          )
        : BorderRadius.circular(radius);

    final headerBorderRadius = connectRight
        ? const BorderRadius.only(
            topLeft: .circular(radius),
            topRight: .circular(reducedRadius),
          )
        : const BorderRadius.vertical(top: .circular(radius));

    // War crime here
    final bodyBorderRadius = connectRight
        ? (clazz.status != null
              ? const BorderRadius.only(
                  bottomLeft: .circular(radius),
                  bottomRight: .circular(reducedRadius),
                )
              : const BorderRadius.only(
                  topLeft: .circular(radius),
                  bottomLeft: .circular(radius),
                  topRight: .circular(reducedRadius),
                  bottomRight: .circular(reducedRadius),
                ))
        : (clazz.status != null
              ? const BorderRadius.vertical(bottom: .circular(radius))
              : BorderRadius.circular(radius));

    final containerBorderRadius = connectRight
        ? const BorderRadius.only(
            topLeft: .circular(radius),
            bottomLeft: .circular(radius),
          )
        : BorderRadius.circular(radius);

    return Expanded(
      flex: clazz.endDate.difference(clazz.startDate).inMinutes,

      child: Container(
        decoration: BoxDecoration(
          color: context.c.surfaceContainerLow,
          borderRadius: containerBorderRadius,
        ),

        child: Pressable(
          borderRadius: outerBorderRadius,

          onPressed: () {
            talker.info("TODO: Create class details page");
          },

          child: Column(
            children: [
              if (clazz.status != null)
                Ink(
                  decoration: BoxDecoration(
                    borderRadius: headerBorderRadius,
                    border: .fromBorderSide(statusBorder),
                    color: clazz.canceled
                        ? scheme.errorContainer
                        : scheme.secondaryContainer,
                  ),

                  padding: const .symmetric(horizontal: 12, vertical: 4),
                  width: double.infinity,

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

                            color: clazz.canceled
                                ? scheme.error
                                : scheme.secondary,
                            size: 20,
                          ),

                          Expanded(
                            child: Text(
                              clazz.status ?? "",

                              overflow: .ellipsis,
                              maxLines: 1,

                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: .w900,
                                color: clazz.canceled
                                    ? context.c.error
                                    : scheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: Ink(
                  decoration: BoxDecoration(
                    color: clazz.canceled
                        ? scheme.surfaceContainerLow
                        : scheme.primaryContainer,
                    border: clazz.status != null
                        ? Border(
                            bottom: statusBorder,
                            left: statusBorder,
                            right: statusBorder,
                          )
                        : Border.all(color: scheme.inversePrimary),
                    borderRadius: bodyBorderRadius,
                  ),

                  padding: .symmetric(
                    horizontal: 10,
                    vertical: clazz.canceled ? 2 : 5,
                  ),
                  width: double.infinity,

                  child: Column(
                    spacing: clazz.canceled ? 0 : 2,
                    crossAxisAlignment: .start,

                    children: [
                      Text(
                        classTitle(context),

                        overflow: .ellipsis,
                        maxLines: 1,

                        style: TextStyle(
                          color: clazz.canceled
                              ? scheme.outline
                              : scheme.primary,
                          fontWeight: clazz.canceled ? .bold : .w800,
                          fontSize: clazz.canceled ? 20 : 22,
                        ),
                      ),

                      _ContentOverflowRow(
                        contents: listContents(),
                        color: clazz.canceled
                            ? scheme.outline
                            : scheme.onPrimaryContainer,
                        dividerColor: clazz.canceled
                            ? scheme.outline
                            : scheme.outline,
                      ),

                      if (!clazz.canceled)
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
                ),
              ),
            ],
          ),
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

      ClassroomContent(value: final v) => (v.label, HugeIconsSolid.school),

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
