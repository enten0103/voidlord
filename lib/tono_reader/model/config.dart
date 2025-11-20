///翻页方式
/// [PageTurningMethod.slide] 滑动
/// [PageTurningMethod.turn] 翻页
enum PageTurningMethod { slide, turn }

///视口设置
class ViewPortConfig {
  ViewPortConfig({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
  });

  ///左边距
  final double left;

  ///右边距
  final double right;

  ///上边距
  final double top;

  ///下边距
  final double bottom;
}
