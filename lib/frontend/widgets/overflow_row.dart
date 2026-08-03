import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class OverflowRow extends MultiChildRenderObjectWidget {
  final double spacing;
  final TextStyle badgeStyle;
  final BoxDecoration? badgeDecoration;
  final EdgeInsets badgePadding;

  const OverflowRow({
    super.key,
    required super.children,
    this.spacing = 8.0,
    this.badgeStyle = const TextStyle(color: Colors.white, fontSize: 12),
    this.badgeDecoration,
    this.badgePadding = const EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 4.0,
    ),
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderOverflowRow(
      spacing: spacing,
      badgeStyle: badgeStyle,
      badgeDecoration:
          badgeDecoration ??
          BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
      badgePadding: badgePadding,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderOverflowRow renderObject,
  ) {
    renderObject
      ..spacing = spacing
      ..badgeStyle = badgeStyle
      ..badgeDecoration =
          badgeDecoration ??
          BoxDecoration(
            color: Colors.grey.shade700,
            borderRadius: BorderRadius.circular(12),
          )
      ..badgePadding = badgePadding
      ..textDirection = Directionality.of(context);
  }
}

class RenderOverflowRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderOverflowRow({
    required this._spacing,
    required this._badgeStyle,
    required this._badgeDecoration,
    required this._badgePadding,
    required this._textDirection,
  });

  double _spacing;
  set spacing(double value) {
    if (_spacing == value) return;
    _spacing = value;
    markNeedsLayout();
  }

  TextStyle _badgeStyle;
  set badgeStyle(TextStyle value) {
    if (_badgeStyle == value) return;
    _badgeStyle = value;
    markNeedsLayout();
  }

  BoxDecoration _badgeDecoration;
  BoxPainter? _badgeBoxPainter;
  set badgeDecoration(BoxDecoration value) {
    if (_badgeDecoration == value) return;
    _badgeDecoration = value;
    _badgeBoxPainter?.dispose();
    _badgeBoxPainter = null;
    markNeedsPaint();
  }

  EdgeInsets _badgePadding;
  set badgePadding(EdgeInsets value) {
    if (_badgePadding == value) return;
    _badgePadding = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  int _visibleCount = 0;
  TextPainter? _badgePainter;
  Offset _badgeOffset = Offset.zero;
  Size _badgeSize = Size.zero;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  double _getBadgeIntrinsicHeight() {
    final badgePainter = TextPainter(
      text: TextSpan(text: '+99', style: _badgeStyle),
      textDirection: _textDirection,
    )..layout();
    return badgePainter.height + _badgePadding.vertical;
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (childCount == 0) return 0.0;
    return firstChild!.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (childCount == 0) return 0.0;
    double totalWidth = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      totalWidth += child.getMaxIntrinsicWidth(height);
      if (child != lastChild) totalWidth += _spacing;
      child = childAfter(child);
    }
    return totalWidth;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (childCount == 0) return 0.0;
    double maxHeight = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      maxHeight = math.max(maxHeight, child.getMinIntrinsicHeight(width));
      child = childAfter(child);
    }
    return math.max(maxHeight, _getBadgeIntrinsicHeight());
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (childCount == 0) return 0.0;
    double maxHeight = 0.0;
    RenderBox? child = firstChild;
    while (child != null) {
      maxHeight = math.max(maxHeight, child.getMaxIntrinsicHeight(width));
      child = childAfter(child);
    }
    return math.max(maxHeight, _getBadgeIntrinsicHeight());
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    if (childCount == 0) return constraints.smallest;

    final childConstraints = BoxConstraints(
      maxWidth: constraints.maxWidth,
      maxHeight: constraints.maxHeight,
    );

    double currentWidth = 0.0;
    double maxHeight = 0.0;
    int measuredCount = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final Size childSize = child.getDryLayout(childConstraints);
      double addedWidth =
          childSize.width + (measuredCount > 0 ? _spacing : 0.0);

      if (currentWidth + addedWidth > constraints.maxWidth) break;
      currentWidth += addedWidth;
      maxHeight = math.max(maxHeight, childSize.height);
      measuredCount++;
      child = childAfter(child);
    }

    if (measuredCount < childCount) {
      int visibleCount = measuredCount;
      while (visibleCount >= 0) {
        int hiddenCount = childCount - visibleCount;
        final badgePainter = TextPainter(
          text: TextSpan(text: '+$hiddenCount', style: _badgeStyle),
          textDirection: _textDirection,
        )..layout();

        final Size badgeSize = Size(
          badgePainter.width + _badgePadding.horizontal,
          badgePainter.height + _badgePadding.vertical,
        );

        double visibleWidth = 0.0;
        RenderBox? c = firstChild;
        for (int i = 0; i < visibleCount; i++) {
          visibleWidth += c!.getDryLayout(childConstraints).width;
          if (i < visibleCount - 1) visibleWidth += _spacing;
          c = childAfter(c);
        }

        double requiredSpacing = (visibleCount > 0) ? _spacing : 0.0;
        if (visibleWidth + requiredSpacing + badgeSize.width <=
                constraints.maxWidth ||
            visibleCount == 0) {
          maxHeight = math.max(maxHeight, badgeSize.height);
          currentWidth = visibleWidth + requiredSpacing + badgeSize.width;
          break;
        } else {
          visibleCount--;
        }
      }
    }
    return constraints.constrain(Size(currentWidth, maxHeight));
  }

  @override
  void performLayout() {
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    final BoxConstraints childConstraints = BoxConstraints(
      maxWidth: constraints.maxWidth,
      maxHeight: constraints.maxHeight,
    );

    int measuredCount = 0;
    double currentWidth = 0.0;
    double maxHeight = 0.0;

    RenderBox? child = firstChild;

    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      double addedWidth =
          child.size.width + (measuredCount > 0 ? _spacing : 0.0);

      if (currentWidth + addedWidth > constraints.maxWidth) {
        break;
      }
      currentWidth += addedWidth;
      maxHeight = math.max(maxHeight, child.size.height);
      measuredCount++;
      child = childAfter(child);
    }

    int visibleCount = measuredCount;
    bool needsBadge = visibleCount < childCount;

    _badgePainter = null;
    _badgeSize = Size.zero;

    if (needsBadge) {
      while (visibleCount >= 0) {
        int hiddenCount = childCount - visibleCount;

        _badgePainter = TextPainter(
          text: TextSpan(text: '+$hiddenCount', style: _badgeStyle),
          textDirection: _textDirection,
        )..layout();

        _badgeSize = Size(
          _badgePainter!.width + _badgePadding.horizontal,
          _badgePainter!.height + _badgePadding.vertical,
        );

        double visibleWidth = 0.0;
        RenderBox? c = firstChild;
        for (int i = 0; i < visibleCount; i++) {
          visibleWidth += c!.size.width;
          if (i < visibleCount - 1) visibleWidth += _spacing;
          c = childAfter(c);
        }

        double requiredSpacing = (visibleCount > 0) ? _spacing : 0.0;

        if (visibleWidth + requiredSpacing + _badgeSize.width <=
                constraints.maxWidth ||
            visibleCount == 0) {
          maxHeight = math.max(maxHeight, _badgeSize.height);
          break;
        } else {
          visibleCount--;
        }
      }
    }

    child = firstChild;
    for (int i = 0; i < childCount; i++) {
      if (i >= measuredCount) {
        child!.layout(
          const BoxConstraints.tightFor(width: 0, height: 0),
          parentUsesSize: true,
        );
      }
      child = childAfter(child!);
    }

    double x = 0.0;
    child = firstChild;
    for (int i = 0; i < childCount; i++) {
      final MultiChildLayoutParentData childParentData =
          child!.parentData as MultiChildLayoutParentData;
      if (i < visibleCount) {
        double y = (maxHeight - child.size.height) / 2.0;
        childParentData.offset = Offset(x, y);
        x += child.size.width + _spacing;
      } else {
        childParentData.offset = Offset.zero;
      }
      child = childAfter(child);
    }

    if (needsBadge) {
      double badgeY = (maxHeight - _badgeSize.height) / 2.0;
      _badgeOffset = Offset(x, badgeY);
      x += _badgeSize.width;
    } else {
      if (visibleCount > 0) x -= _spacing;
    }

    _visibleCount = visibleCount;
    size = constraints.constrain(Size(x, maxHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    for (int i = 0; i < childCount; i++) {
      if (i < _visibleCount) {
        final MultiChildLayoutParentData childParentData =
            child!.parentData as MultiChildLayoutParentData;
        context.paintChild(child, childParentData.offset + offset);
      }
      child = childAfter(child!);
    }

    if (_visibleCount < childCount && _badgePainter != null) {
      final Rect badgeRect = _badgeOffset + offset & _badgeSize;

      _badgeBoxPainter ??= _badgeDecoration.createBoxPainter(markNeedsPaint);
      _badgeBoxPainter!.paint(
        context.canvas,
        badgeRect.topLeft,
        ImageConfiguration(size: _badgeSize, textDirection: _textDirection),
      );

      final Offset textOffset = badgeRect.topLeft + _badgePadding.topLeft;
      _badgePainter!.paint(context.canvas, textOffset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild;
    int i = childCount - 1;
    while (child != null) {
      if (i < _visibleCount) {
        final MultiChildLayoutParentData childParentData =
            child.parentData as MultiChildLayoutParentData;
        final bool isHit = result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            return child!.hitTest(result, position: transformed);
          },
        );
        if (isHit) return true;
      }
      child = childBefore(child);
      i--;
    }
    return false;
  }

  @override
  void dispose() {
    _badgeBoxPainter?.dispose();
    super.dispose();
  }
}
