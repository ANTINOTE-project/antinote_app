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

    final duration = Utils.formatDuration(difference);

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
                        : Border.all(color: scheme.outline),

                    borderRadius: bodyBorderRadius,
                  ),

                  padding: .symmetric(
                    horizontal: 10,
                    vertical: clazz.canceled ? 2 : 5,
                  ),
                  width: double.infinity,

                  child: Column(
                    mainAxisAlignment: .spaceBetween,
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
    return _OverflowMeasureRow(
      color: color,
      dividerColor: dividerColor,
      contents: contents,
    );
  }
}

class _OverflowMeasureRow extends StatefulWidget {
  final List<ClassContent> contents;
  final Color color;
  final Color dividerColor;

  const _OverflowMeasureRow({
    required this.contents,
    required this.color,
    required this.dividerColor,
  });

  @override
  State<_OverflowMeasureRow> createState() => _OverflowMeasureRowState();
}

class _OverflowMeasureRowState extends State<_OverflowMeasureRow> {
  final List<GlobalKey> _keys = [];
  int? _visibleCount;

  @override
  void initState() {
    super.initState();

    _resetKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(_OverflowMeasureRow old) {
    super.didUpdateWidget(old);

    if (old.contents != widget.contents) {
      setState(() {
        _visibleCount = null;
        _resetKeys();
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _resetKeys() {
    _keys.clear();

    for (var i = 0; i < widget.contents.length; i++) {
      _keys.add(GlobalKey());
    }
  }

  void _measure() {
    if (!mounted) return;

    final rowBox = context.findRenderObject() as RenderBox?;
    if (rowBox == null) return;

    final maxWidth = rowBox.size.width;

    const overflowBadgeWidth = 32.0;
    const dividerWidth = 2.0 + 12.0;

    double usedWidth = 0;
    int visible = 0;

    for (int i = 0; i < _keys.length; i++) {
      final key = _keys[i];
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null) continue;

      final itemWidth = box.size.width;
      final divider = i > 0 ? dividerWidth : 0;
      final remaining = widget.contents.length - i - 1;
      final needsBadge = remaining > 0;
      final reservedBadge = needsBadge ? overflowBadgeWidth : 0;

      if (usedWidth + divider + itemWidth + reservedBadge <= maxWidth) {
        usedWidth += divider + itemWidth;
        visible++;
      } else {
        break;
      }
    }

    if (visible != _visibleCount) {
      setState(() => _visibleCount = visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _visibleCount ?? widget.contents.length;
    final hidden = widget.contents.length - count;

    if (_visibleCount == null) {
      return Opacity(
        opacity: 0,

        child: Row(
          spacing: 6,

          children: [
            for (final (i, content) in widget.contents.indexed) ...[
              if (i > 0) _Divider(color: widget.dividerColor),

              _ClassContent(
                key: _keys[i],
                color: widget.color,
                content: content,
              ),
            ],
          ],
        ),
      );
    }

    return Row(
      spacing: 6,

      children: [
        for (int i = 0; i < count; i++) ...[
          if (i > 0) _Divider(color: widget.dividerColor),
          _ClassContent(color: widget.color, content: widget.contents[i]),
        ],

        if (hidden > 0)
          Container(
            padding: const .symmetric(horizontal: 7, vertical: 2),

            decoration: BoxDecoration(
              color: widget.color.withAlpha(30),
              borderRadius: .circular(999),
            ),

            child: Text(
              "+$hidden",

              style: TextStyle(
                color: widget.color,
                fontWeight: .w800,
                fontSize: 12,
              ),
            ),
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

  const _ClassContent({super.key, required this.content, required this.color});

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
