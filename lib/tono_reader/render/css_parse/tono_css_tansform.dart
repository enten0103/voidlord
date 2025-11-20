import 'package:flutter/widgets.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

///
/// transform valued
extension TonoCssTansform on FlutterStyleFromCss {
  /// css [transform] -> flutter [Matrix4]
  Matrix4? parseTransform(String? raw) {
    raw = raw?.toValue();
    if (raw == null) return null;
    final regex = RegExp(
        r'matrix\(([^,]+),\s*([^,]+),\s*([^,]+),\s*([^,]+),\s*([^,]+),\s*([^,]+)\)');
    final match = regex.firstMatch(raw);
    if (match == null) return null;

    try {
      final matrixValues = match
          .groups([1, 2, 3, 4, 5, 6])
          .map((e) => double.parse(e!))
          .toList();
      return Matrix4(
        matrixValues[0], matrixValues[1], 0, 0, // a, c, 0, e
        matrixValues[2], matrixValues[3], 0, 0, // b, d, 0, f
        0, 0, 1, 0, // 保持 Z 轴不变
        matrixValues[4], matrixValues[5], 0, 1, // 保持齐次坐标
      );
    } catch (e) {
      return null; // 解析失败返回 null
    }
  }
}
