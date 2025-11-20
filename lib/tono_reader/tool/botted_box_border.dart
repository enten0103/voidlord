import 'dart:ui';
import 'package:flutter/material.dart';

class DottedBoxBorder extends BoxBorder {
  // 四条边的样式
  @override
  final BorderSide top;

  @override
  final BorderSide bottom;
  final BorderSide left;
  final BorderSide right;
  // 点的半径和间距
  final double dotRadius;
  final double dotSpacing;

  // 构造函数
  const DottedBoxBorder({
    this.top = BorderSide.none,
    this.bottom = BorderSide.none,
    this.left = BorderSide.none,
    this.right = BorderSide.none,
    this.dotRadius = 1.0, // 默认点半径为 1.0
    this.dotSpacing = 3.0, // 默认点间距为 3.0
  });

  // 计算边框的内边距
  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.fromLTRB(
      left.width,
      top.width,
      right.width,
      bottom.width,
    );
  }

  // 绘制边框
  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    // 尖角矩形的情况
    if (shape == BoxShape.rectangle && borderRadius == null) {
      if (top != BorderSide.none) {
        _paintDottedLine(
            canvas, rect.left, rect.top, rect.right, rect.top, top);
      }
      if (bottom != BorderSide.none) {
        _paintDottedLine(
            canvas, rect.left, rect.bottom, rect.right, rect.bottom, bottom);
      }
      if (left != BorderSide.none) {
        _paintDottedLine(
            canvas, rect.left, rect.top, rect.left, rect.bottom, left);
      }
      if (right != BorderSide.none) {
        _paintDottedLine(
            canvas, rect.right, rect.top, rect.right, rect.bottom, right);
      }
    } else {
      // 圆形或圆角矩形的情况
      // 如果有多条边有样式，优先使用 top 的样式
      BorderSide side = top != BorderSide.none
          ? top
          : bottom != BorderSide.none
              ? bottom
              : left != BorderSide.none
                  ? left
                  : right != BorderSide.none
                      ? right
                      : BorderSide(color: Colors.black, width: 1.0);
      Path path;
      if (shape == BoxShape.circle) {
        path = Path()..addOval(rect);
      } else {
        path = Path()..addRRect(borderRadius!.toRRect(rect));
      }
      _paintDottedPath(canvas, path, side);
    }
  }

  // 绘制直线上的点状线条
  void _paintDottedLine(Canvas canvas, double x1, double y1, double x2,
      double y2, BorderSide side) {
    final Paint paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.fill;

    // 计算线段长度
    final double length = (x1 == x2) ? (y2 - y1).abs() : (x2 - x1).abs();
    final double step = dotSpacing + 2 * dotRadius; // 每段的总长度（点直径 + 间距）
    final int numDots = (length / step).floor(); // 计算点的数量

    for (int i = 0; i <= numDots; i++) {
      final double t = i / (numDots == 0 ? 1 : numDots); // 防止除以 0
      final double x = x1 + t * (x2 - x1);
      final double y = y1 + t * (y2 - y1);
      canvas.drawCircle(Offset(x, y), dotRadius, paint);
    }
  }

  // 绘制路径上的点状线条
  void _paintDottedPath(Canvas canvas, Path path, BorderSide side) {
    final Paint paint = Paint()
      ..color = side.color
      ..style = PaintingStyle.fill;

    final PathMetrics pathMetrics = path.computeMetrics();
    for (final PathMetric metric in pathMetrics) {
      final double length = metric.length;
      final double step = dotSpacing + 2 * dotRadius;
      final int numDots = (length / step).floor();

      for (int i = 0; i <= numDots; i++) {
        final double distance = (i / (numDots == 0 ? 1 : numDots)) * length;
        final Tangent? tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, dotRadius, paint);
        }
      }
    }
  }

  // 检查边框是否均匀
  @override
  bool get isUniform => top == bottom && bottom == left && left == right;

  // 缩放边框
  @override
  DottedBoxBorder scale(double t) {
    return DottedBoxBorder(
      top: top.scale(t),
      bottom: bottom.scale(t),
      left: left.scale(t),
      right: right.scale(t),
      dotRadius: dotRadius * t,
      dotSpacing: dotSpacing * t,
    );
  }
}
