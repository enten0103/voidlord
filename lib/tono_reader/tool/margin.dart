import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/render/state/tono_container_provider.dart';
import 'package:voidlord/tono_reader/tool/css_tool.dart';

// Margin 组件
class Margin extends SingleChildRenderObjectWidget {
  final EdgeInsets margin;

  const Margin({
    super.key,
    required this.margin,
    required Widget child,
  }) : super(child: child);

  @override
  RenderMargin createRenderObject(BuildContext context) {
    return RenderMargin(edgeInsets: margin);
  }

  @override
  void updateRenderObject(BuildContext context, RenderMargin renderObject) {
    renderObject.edgeInsets = margin;
  }
}

// 渲染对象
class RenderMargin extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  EdgeInsets _edgeInsets;

  RenderMargin({
    required EdgeInsets edgeInsets,
  }) : _edgeInsets = edgeInsets;

  set edgeInsets(EdgeInsets value) {
    if (_edgeInsets != value) {
      _edgeInsets = value;
      markNeedsLayout(); // 参数变化时触发重新布局
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    if (child == null) return null;

    final childDistance = child!.getDistanceToActualBaseline(baseline);
    if (childDistance == null) return null;

    // 计算时要考虑垂直方向的偏移
    return childDistance + _edgeInsets.top;
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest; // 无子组件时尺寸为最小
      return;
    }

    // 让子组件根据父约束布局
    child!.layout(constraints, parentUsesSize: true);
    final childSize = child!.size;

    // 计算 Margin 组件的尺寸
    final width = (childSize.width + _edgeInsets.left + _edgeInsets.right)
        .clamp(0.0, double.infinity);
    final height = (childSize.height + _edgeInsets.top + _edgeInsets.bottom)
        .clamp(0.0, double.infinity);
    size = Size(width, height);

    // 设置子组件偏移量（支持负值）
    final childOffset = Offset(_edgeInsets.left, _edgeInsets.top);
    final parentData = child!.parentData! as BoxParentData;
    parentData.offset = childOffset;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final parentData = child!.parentData! as BoxParentData;
      context.paintChild(child!, offset + parentData.offset);
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child != null) {
      final parentData = child!.parentData! as BoxParentData;
      return result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          return child!.hitTest(result, position: transformed);
        },
      );
    }
    return false;
  }
}

class AdaptiveMargin extends StatelessWidget {
  final EdgeInsets margin;
  final Widget child;

  const AdaptiveMargin({
    super.key,
    required this.margin,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    var container = context.tonoWidget;
    var parent = container.parent;
    var mt = margin.top;
    if (parent != null) {
      double? cmb = parent.extra['child-margin-bottom'];
      //   double? cmr = parent.extra['child-margin-right'];
      if (parent.className == "tr" ||
          (parent is TonoContainer &&
              parent.css.toMap()['display'] == "flex")) {
        ///横向
      } else {
        ///纵向
        if (cmb != null) {
          if (cmb > 0 && margin.top < 0) {
            mt = cmb + margin.top;
          } else if (cmb > margin.top) {
            mt = cmb;
          }
        }
      }
      parent.extra['child-margin-bottom'] = margin.bottom;
    }
    // 检查是否有负 margin
    bool hasNegativeMargin =
        mt < 0 || margin.bottom < 0 || margin.left < 0 || margin.right < 0;
    if (hasNegativeMargin) {
      return Margin(
          key: Key("padding:$mt@$hashCode"), margin: margin, child: child);
    } else {
      // 使用默认的 Padding 组件
      return Container(
          key: Key("padding:$mt@$hashCode"),
          margin: EdgeInsets.only(
              left: margin.left,
              right: margin.right,
              bottom: container.extra['last'] == true ? margin.bottom : 0,
              top: mt),
          child: child);
    }
  }
}
