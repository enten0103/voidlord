import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// span data
class SpanCell {
  final Widget child;
  final int rowSpan;
  final int colSpan;

  SpanCell({
    required this.child,
    this.rowSpan = 1,
    this.colSpan = 1,
  });
}

class SpanTableParentData extends ContainerBoxParentData<RenderBox> {
  int row = 0; // 单元格所在行索引
  int column = 0; // 单元格所在列索引
  int rowSpan = 1; // 纵向合并的行数
  int colSpan = 1; // 横向合并的列数
}

class SpanTable extends MultiChildRenderObjectWidget {
  final List<List<SpanCell>> data;

  SpanTable({
    super.key,
    required this.data,
  }) : super(children: _flattenCells(data));

  static List<Widget> _flattenCells(List<List<SpanCell>> data) {
    return data.expand((row) => row.map((cell) => cell.child)).toList();
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSpanTable(data: data);
  }
}

class RenderSpanTable extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SpanTableParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SpanTableParentData> {
  RenderSpanTable({required this.data});
  final List<List<SpanCell>> data;

  /// table 宽度计算暂存,最大支持100x100
  final List<double> widths = List.filled(1000, 0);

  /// table 高度计算暂存
  final List<double> heights = List.filled(1000, 0);

  List<int> _genIndexList(int start, int span) {
    List<int> result = [];
    for (int i = 0; i < span; i++) {
      result.add(start + i);
    }
    return result;
  }

  double _genSize(List<int> indexs, List<double> sizes) {
    double sum = 0;
    for (var i = 0; i < indexs.length; i++) {
      sum += sizes[indexs[i]];
    }
    return sum;
  }

  /// 更新size
  void _updateTableSize(
      List<int> targetIndexs, List<double> currentSizes, double newSize) {
    double currentSize = 0;
    for (var i = 0; i < targetIndexs.length; i++) {
      var targetIndex = targetIndexs[i];
      currentSize += currentSizes[targetIndex];
    }

    /// 当前尺寸大于新尺寸
    if (currentSize > newSize) return;

    ///当前尺寸小于新尺寸
    var fixedSize = newSize - currentSize + currentSizes[targetIndexs.last];
    currentSizes[targetIndexs.last] = fixedSize;
  }

  int _genRowIndex(int currentRawIndex, int currentColIndex) {
    int sum = 0;
    for (var i = 0; i < currentRawIndex; i++) {
      try{
        sum += data[i][currentColIndex].colSpan;
      }catch(_){
        sum += 1;
      }
    }
    return sum;
  }

  int _genColIndex(int currentRowIndex, int currentColIndex) {
    int sum = 0;
    for (var i = 0; i < currentColIndex; i++) {
      sum += data[currentRowIndex][i].colSpan;
    }
    return sum;
  }

  double _genDx(int col) {
    double sum = 0;
    for (var i = 0; i < col; i++) {
      sum += widths[i];
    }
    return sum;
  }

  double _genDy(int row) {
    double sum = 0;
    for (var i = 0; i < row; i++) {
      sum += heights[i];
    }
    return sum;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SpanTableParentData) {
      child.parentData = SpanTableParentData();
    }
  }

  @override
  void performLayout() {
    int childIndex = 0;
    var children = getChildrenAsList();

    for (int row = 0; row < data.length; row++) {
      for (int col = 0; col < data[row].length; col++) {
        final cellData = data[row][col];

        final child = children[childIndex++];

        /// 最小宽度
        var width = child.getMaxIntrinsicWidth(double.infinity);

        /// 最小高度
        var height = child.getMaxIntrinsicHeight(double.infinity);

        var colSpan = cellData.colSpan;

        var rowSpan = cellData.rowSpan;
        var rowIndex = _genRowIndex(row, col);

        var colIndex = _genColIndex(row, col);

        var targetRowIndex = _genIndexList(rowIndex, rowSpan);
        var targetColIndex = _genIndexList(colIndex, colSpan);

        _updateTableSize(targetColIndex, widths, width);
        _updateTableSize(targetRowIndex, heights, height);

        // 设置位置信息
        final parentData = child.parentData as SpanTableParentData;

        parentData.column = colIndex;
        parentData.row = rowIndex;
        parentData.colSpan = colSpan;
        parentData.rowSpan = rowSpan;
      }
    }

    // 计算表格总尺寸
    final totalWidth = widths.takeWhile((w) => w > 0).reduce((a, b) => a + b);
    final totalHeight = heights.takeWhile((h) => h > 0).reduce((a, b) => a + b);

    // 设置表格自身尺寸
    size = constraints.constrain(Size(totalWidth, totalHeight));
    childIndex = 0;
    for (int row = 0; row < data.length; row++) {
      for (int col = 0; col < data[row].length; col++) {
        final child = children[childIndex++];
        final cellData = data[row][col];
        var colSpan = cellData.colSpan;
        var rowSpan = cellData.rowSpan;
        final parentData = child.parentData as SpanTableParentData;
        var dx = _genDx(parentData.column);
        var dy = _genDy(parentData.row);
        var rowIndex = _genRowIndex(row, col);
        var colIndex = _genColIndex(row, col);
        var targetRowIndex = _genIndexList(rowIndex, rowSpan);
        var targetColIndex = _genIndexList(colIndex, colSpan);
        var width = _genSize(targetColIndex, widths);
        var height = _genSize(targetRowIndex, heights);
        child.layout(BoxConstraints(maxHeight: height,maxWidth: width,minHeight: height,minWidth: width),
            parentUsesSize: true);
        parentData.offset = Offset(dx, dy);
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
