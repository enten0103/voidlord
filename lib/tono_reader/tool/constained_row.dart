import 'package:flutter/material.dart';

class ConstrainedRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment; // 主轴对齐方式
  final CrossAxisAlignment crossAxisAlignment; // 交叉轴对齐方式
  final MainAxisSize mainAxisSize; // 主轴尺寸
  final TextDirection? textDirection; // 文本方向
  final VerticalDirection verticalDirection; // 垂直方向
  final TextBaseline? textBaseline; // 文本基线

  const ConstrainedRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start, // 默认值与 Row 一致
    this.crossAxisAlignment = CrossAxisAlignment.center, // 默认值与 Row 一致
    this.mainAxisSize = MainAxisSize.max, // 默认值与 Row 一致
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
  });

  @override
  Widget build(BuildContext context) {
    // 创建新的子组件列表，用于存储处理后的子组件
    List<Widget> modifiedChildren = [];

    // 遍历子组件，处理带有 minWidth: double.infinity 的 Container
    for (var child in children) {
      if (child is Container) {
        var container = child;
        if (container.constraints != null &&
            container.constraints!.minWidth == double.infinity) {
          // 将符合条件的 Container 包裹在 Expanded 中
          modifiedChildren.add(Expanded(child: container));
        } else {
          // 不符合条件的子组件保持不变
          modifiedChildren.add(child);
        }
      } else {
        // 非 Container 子组件保持不变
        modifiedChildren.add(child);
      }
    }

    // 使用 Row 布局，并传递所有属性
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: modifiedChildren,
    );
  }
}
