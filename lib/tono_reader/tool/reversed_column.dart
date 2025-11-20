import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ReversedColumn extends MultiChildRenderObjectWidget {
  const ReversedColumn({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    super.children = const <Widget>[],
  });

  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderReversedFlex(
      direction: Axis.vertical,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection ?? Directionality.of(context),
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderReversedFlex renderObject,
  ) {
    renderObject
      ..direction = Axis.vertical
      ..mainAxisAlignment = mainAxisAlignment
      ..mainAxisSize = mainAxisSize
      ..crossAxisAlignment = crossAxisAlignment
      ..textDirection = textDirection ?? Directionality.of(context)
      ..verticalDirection = verticalDirection
      ..textBaseline = textBaseline;
  }
}

class RenderReversedFlex extends RenderFlex {
  RenderReversedFlex({
    required super.direction,
    required super.mainAxisAlignment,
    required super.mainAxisSize,
    required super.crossAxisAlignment,
    required super.textDirection,
    required super.verticalDirection,
    super.textBaseline,
  });
  @override
  void paint(PaintingContext context, Offset offset) {
    // 获取子组件列表并反转
    final reversedChildren = _getChildrenInReverseOrder();
    for (final child in reversedChildren) {
      final parentData = child.parentData as FlexParentData;
      context.paintChild(child, parentData.offset + offset);
    }
  }

  List<RenderBox> _getChildrenInReverseOrder() {
    final List<RenderBox> children = [];
    RenderBox? child = firstChild;
    while (child != null) {
      children.add(child);
      final parentData = child.parentData as FlexParentData;
      child = parentData.nextSibling;
    }
    return children.reversed.toList();
  }
}
