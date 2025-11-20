import 'dart:ui';
import 'package:flutter/material.dart';

class DashedBoxBorder extends BoxBorder {
  @override
  final BorderSide top;

  @override
  final BorderSide bottom;
  final BorderSide left;
  final BorderSide right;
  final List<double> dashPattern;

  const DashedBoxBorder({
    this.top = BorderSide.none,
    this.bottom = BorderSide.none,
    this.left = BorderSide.none,
    this.right = BorderSide.none,
    this.dashPattern = const [3, 3],
  }) : assert(dashPattern.length == 2, 'dashPattern 需要两个参数（实线长度、空白长度）');

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.fromLTRB(
      left.width,
      top.width,
      right.width,
      bottom.width,
    );
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    if (shape == BoxShape.rectangle && borderRadius == null) {
      // 对于尖角矩形，分别绘制每条边
      if (top != BorderSide.none) {
        final Paint paint = Paint()
          ..color = top.color
          ..strokeWidth = top.width
          ..style = PaintingStyle.stroke;
        final Path path = Path()
          ..moveTo(rect.left, rect.top)
          ..lineTo(rect.right, rect.top);
        final Path dashedPath = _generateDashedPath(path,
            dashLength: dashPattern[0], gapLength: dashPattern[1]);
        canvas.drawPath(dashedPath, paint);
      }
      if (bottom != BorderSide.none) {
        final Paint paint = Paint()
          ..color = bottom.color
          ..strokeWidth = bottom.width
          ..style = PaintingStyle.stroke;
        final Path path = Path()
          ..moveTo(rect.left, rect.bottom)
          ..lineTo(rect.right, rect.bottom);
        final Path dashedPath = _generateDashedPath(path,
            dashLength: dashPattern[0], gapLength: dashPattern[1]);
        canvas.drawPath(dashedPath, paint);
      }
      if (left != BorderSide.none) {
        final Paint paint = Paint()
          ..color = left.color
          ..strokeWidth = left.width
          ..style = PaintingStyle.stroke;
        final Path path = Path()
          ..moveTo(rect.left, rect.top)
          ..lineTo(rect.left, rect.bottom);
        final Path dashedPath = _generateDashedPath(path,
            dashLength: dashPattern[0], gapLength: dashPattern[1]);
        canvas.drawPath(dashedPath, paint);
      }
      if (right != BorderSide.none) {
        final Paint paint = Paint()
          ..color = right.color
          ..strokeWidth = right.width
          ..style = PaintingStyle.stroke;
        final Path path = Path()
          ..moveTo(rect.right, rect.top)
          ..lineTo(rect.right, rect.bottom);
        final Path dashedPath = _generateDashedPath(path,
            dashLength: dashPattern[0], gapLength: dashPattern[1]);
        canvas.drawPath(dashedPath, paint);
      }
    } else {
      // 对于圆形或圆角矩形，绘制整个路径
      BorderSide side = top != BorderSide.none
          ? top
          : bottom != BorderSide.none
              ? bottom
              : left != BorderSide.none
                  ? left
                  : right != BorderSide.none
                      ? right
                      : BorderSide(color: Colors.black, width: 1.0);
      final Paint paint = Paint()
        ..color = side.color
        ..strokeWidth = side.width
        ..style = PaintingStyle.stroke;
      Path path;
      if (shape == BoxShape.circle) {
        path = Path()..addOval(rect);
      } else {
        path = Path()..addRRect(borderRadius!.toRRect(rect));
      }
      final Path dashedPath = _generateDashedPath(path,
          dashLength: dashPattern[0], gapLength: dashPattern[1]);
      canvas.drawPath(dashedPath, paint);
    }
  }

  Path _generateDashedPath(Path path,
      {required double dashLength, required double gapLength}) {
    final Path dashedPath = Path();
    final PathMetrics pathMetrics = path.computeMetrics();
    for (final PathMetric metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + dashLength),
          Offset.zero,
        );
        distance += dashLength + gapLength;
      }
    }
    return dashedPath;
  }

  @override
  bool get isUniform => top == bottom && bottom == left && left == right;

  @override
  DashedBoxBorder scale(double t) {
    return DashedBoxBorder(
      top: top.scale(t),
      bottom: bottom.scale(t),
      left: left.scale(t),
      right: right.scale(t),
      dashPattern: dashPattern,
    );
  }
}
