import 'package:flutter/cupertino.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

///
/// css [padding] 转 flutter [EdgeInsets]
extension TonoCssPadding on FlutterStyleFromCss {
  EdgeInsets parsePadding(Map<String, String> css) {
    ///
    /// 单方向padding解析
    double parsePaddingSide(side) {
      var cssPadding = css['padding-$side'];
      if (cssPadding == null || globalKeyWords.contains(cssPadding)) {
        return 0;
      }
      var parent = (side == "left" || side == "right")
          ? parentSize?.width
          : parentSize?.height;
      var value = parseUnit(cssPadding, parent, em);
      return value > 0 ? value : 0;
    }

    var left = parsePaddingSide("left");
    var right = parsePaddingSide("right");
    var top = parsePaddingSide("top");
    var bottom = parsePaddingSide("bottom");
    return EdgeInsets.only(left: left, right: right, top: top, bottom: bottom);
  }

  ///
  /// padding关键词
  ///
  /// 若css pading值为keyword则不解析
  static List<String> globalKeyWords = [
    'inherit',
    'initial',
    "revert",
    "revert-layer",
    "unset"
  ];
}
