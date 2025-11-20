import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

enum BorderCustomStyle { solid, dashed, dotted }

class StyledBorderSide extends BorderSide {
  final BorderCustomStyle borderStyle;

  const StyledBorderSide({
    super.color,
    super.width = 1.0,
    this.borderStyle = BorderCustomStyle.solid,
  });

  @override
  StyledBorderSide scale(double t) => StyledBorderSide(
        color: color.withAlpha((color.a * t).clamp(0, 255).toInt()),
        width: math.max(0.0, width * t),
        borderStyle: borderStyle,
      );
}

class StyledBorder extends BoxBorder {
  @override
  final StyledBorderSide top;
  @override
  final StyledBorderSide bottom;
  final StyledBorderSide left;
  final StyledBorderSide right;
  final List<double> dashPattern;
  final double dotRadius;
  final double dotSpacing;

  const StyledBorder({
    this.top = const StyledBorderSide(width: 0),
    this.bottom = const StyledBorderSide(width: 0),
    this.left = const StyledBorderSide(width: 0),
    this.right = const StyledBorderSide(width: 0),
    this.dashPattern = const [3, 1],
    this.dotRadius = 1.0,
    this.dotSpacing = 3.0,
  })  : assert(dashPattern.length == 2, 'dashPattern requires two values'),
        assert(dotRadius >= 0, 'dotRadius must be non-negative'),
        assert(dotSpacing >= 0, 'dotSpacing must be non-negative');

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.fromLTRB(
        left.width,
        top.width,
        right.width,
        bottom.width,
      );

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (shape == BoxShape.rectangle) {
      if (borderRadius != null) {
        _paintBorderWithRadius(canvas, rect, borderRadius);
      } else {
        _paintRectangularBorder(canvas, rect);
      }
    } else {
      _paintCircularBorder(canvas, rect);
    }
  }

  void _paintBorderWithRadius(
      Canvas canvas, Rect rect, BorderRadius borderRadius) {
    final RRect rrect = borderRadius.toRRect(rect);
    _paintEdgeWithRRect(canvas, rrect, top, _EdgeSide.top);
    _paintEdgeWithRRect(canvas, rrect, right, _EdgeSide.right);
    _paintEdgeWithRRect(canvas, rrect, bottom, _EdgeSide.bottom);
    _paintEdgeWithRRect(canvas, rrect, left, _EdgeSide.left);
  }

  void _paintEdgeWithRRect(
    Canvas canvas,
    RRect rrect,
    StyledBorderSide side,
    _EdgeSide edge,
  ) {
    if (side.width == 0) return;

    final path = _getEdgePath(rrect, edge);
    _paintPathAccordingToStyle(canvas, path, side);
  }

  Path _getEdgePath(RRect rrect, _EdgeSide edge) {
    final path = Path();
    switch (edge) {
      case _EdgeSide.top:
        _addTopEdge(path, rrect);
        break;
      case _EdgeSide.right:
        _addRightEdge(path, rrect);
        break;
      case _EdgeSide.bottom:
        _addBottomEdge(path, rrect);
        break;
      case _EdgeSide.left:
        _addLeftEdge(path, rrect);
        break;
    }
    return path;
  }

  void _addTopEdge(Path path, RRect rrect) {
    final tlRadius = rrect.tlRadius;
    final trRadius = rrect.trRadius;

    path.moveTo(rrect.left + tlRadius.x, rrect.top);
    if (tlRadius != Radius.zero) {
      path.arcTo(
        Rect.fromLTWH(
          rrect.left,
          rrect.top,
          tlRadius.x * 2,
          tlRadius.y * 2,
        ),
        -math.pi,
        math.pi / 2,
        true,
      );
    }
    path.lineTo(rrect.right - trRadius.x, rrect.top);
    if (trRadius != Radius.zero) {
      path.arcTo(
        Rect.fromLTWH(
          rrect.right - trRadius.x * 2,
          rrect.top,
          trRadius.x * 2,
          trRadius.y * 2,
        ),
        3 * math.pi / 2,
        math.pi / 2,
        true,
      );
    }
  }

  void _addRightEdge(Path path, RRect rrect) {
    final trRadius = rrect.trRadius;
    final brRadius = rrect.brRadius;

    path.moveTo(rrect.right, rrect.top + trRadius.y);
    if (trRadius != Radius.zero) {
      path.arcTo(
        Rect.fromLTWH(
          rrect.right - trRadius.x * 2,
          rrect.top,
          trRadius.x * 2,
          trRadius.y * 2,
        ),
        3 * math.pi / 2,
        math.pi / 2,
        true,
      );
    }
    path.lineTo(rrect.right, rrect.bottom - brRadius.y);
    if (brRadius != Radius.zero) {
      path.arcTo(
        Rect.fromLTWH(
          rrect.right - brRadius.x * 2,
          rrect.bottom - brRadius.y * 2,
          brRadius.x * 2,
          brRadius.y * 2,
        ),
        0,
        math.pi / 2,
        true,
      );
    }
  }

  void _addBottomEdge(Path path, RRect rrect) {
    final brRadius = rrect.brRadius;
    final blRadius = rrect.blRadius;

    path.moveTo(rrect.right - brRadius.x, rrect.bottom);
    if (brRadius != Radius.zero) {
      path.arcTo(
        Rect.fromLTWH(
          rrect.right - brRadius.x * 2,
          rrect.bottom - brRadius.y * 2,
          brRadius.x * 2,
          brRadius.y * 2,
        ),
        0,
        math.pi / 2,
        true,
      );
    }
    path.lineTo(rrect.left + blRadius.x, rrect.bottom);
    if (blRadius != Radius.zero) {
      path.arcTo(
        Rect.fromLTWH(
          rrect.left,
          rrect.bottom - blRadius.y * 2,
          blRadius.x * 2,
          blRadius.y * 2,
        ),
        math.pi / 2,
        math.pi / 2,
        true,
      );
    }
  }

  void _addLeftEdge(Path path, RRect rrect) {
    final blRadius = rrect.blRadius;
    final tlRadius = rrect.tlRadius;

    path.moveTo(rrect.left, rrect.bottom - blRadius.y);
    if (blRadius != Radius.zero) {
      path.arcTo(
        Rect.fromLTWH(
          rrect.left,
          rrect.bottom - blRadius.y * 2,
          blRadius.x * 2,
          blRadius.y * 2,
        ),
        math.pi / 2,
        math.pi / 2,
        true,
      );
    }
    path.lineTo(rrect.left, rrect.top + tlRadius.y);
    if (tlRadius != Radius.zero) {
      path.arcTo(
        Rect.fromLTWH(
          rrect.left,
          rrect.top,
          tlRadius.x * 2,
          tlRadius.y * 2,
        ),
        math.pi,
        math.pi / 2,
        true,
      );
    }
  }

  void _paintPathAccordingToStyle(
    Canvas canvas,
    Path path,
    StyledBorderSide styledSide,
  ) {
    if (styledSide.width == 0) return;

    switch (styledSide.borderStyle) {
      case BorderCustomStyle.dashed:
        final Paint paint = Paint()
          ..color = styledSide.color
          ..strokeWidth = styledSide.width
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(_generateDashedPath(path, styledSide.width), paint);
        break;

      case BorderCustomStyle.dotted:
        final Paint paint = Paint()
          ..color = styledSide.color
          ..strokeWidth = styledSide.width;
        final PathMetrics metrics = path.computeMetrics();
        final double step = (dotRadius * 2) + dotSpacing;

        for (final PathMetric metric in metrics) {
          double distance = 0;
          while (distance < metric.length) {
            final Tangent? tangent = metric.getTangentForOffset(distance);
            if (tangent != null) {
              canvas.drawCircle(
                tangent.position,
                dotRadius,
                paint..strokeWidth = styledSide.width,
              );
            }
            distance += step;
          }
        }
        break;

      default: // solid
        final Paint paint = Paint()
          ..color = styledSide.color
          ..strokeWidth = styledSide.width
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, paint);
    }
  }

  Path _generateDashedPath(Path path, double strokeWidth) {
    final Path dashedPath = Path();
    final double dashLength = dashPattern[0];
    final double gapLength = dashPattern[1];

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double effectiveDashLength =
            math.max(dashLength, strokeWidth / 2);
        dashedPath.addPath(
          metric.extractPath(distance, distance + effectiveDashLength),
          Offset.zero,
        );
        distance += effectiveDashLength + gapLength;
      }
    }
    return dashedPath;
  }

  void _paintRectangularBorder(Canvas canvas, Rect rect) {
    _paintEdge(canvas, rect.topLeft, rect.topRight, top);
    _paintEdge(canvas, rect.bottomLeft, rect.bottomRight, bottom);
    _paintEdge(canvas, rect.topLeft, rect.bottomLeft, left);
    _paintEdge(canvas, rect.topRight, rect.bottomRight, right);
  }

  void _paintCircularBorder(Canvas canvas, Rect rect) {
    final path = Path()..addOval(rect);
    _paintPathAccordingToStyle(canvas, path, _selectDominantSide());
  }

  void _paintEdge(
    Canvas canvas,
    Offset start,
    Offset end,
    StyledBorderSide side,
  ) {
    if (side.width == 0) return;

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);

    _paintPathAccordingToStyle(canvas, path, side);
  }

  StyledBorderSide _selectDominantSide() {
    final sides = [top, right, bottom, left];
    return sides.firstWhere(
      (side) => side.width != 0,
      orElse: () => const StyledBorderSide(width: 0),
    );
  }

  @override
  bool get isUniform => top == right && right == bottom && bottom == left;

  @override
  StyledBorder scale(double t) => StyledBorder(
        top: top.scale(t),
        bottom: bottom.scale(t),
        left: left.scale(t),
        right: right.scale(t),
        dashPattern: [dashPattern[0] * t, dashPattern[1] * t],
        dotRadius: dotRadius * t,
        dotSpacing: dotSpacing * t,
      );
}

enum _EdgeSide { top, right, bottom, left }
