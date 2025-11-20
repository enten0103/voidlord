import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

///
/// 可解析的display属性
enum CssDisplay {
  inline,
  block,
  flex,
}

///
///  css [display] 实现
extension TonoCssDisplay on FlutterStyleFromCss {
  CssDisplay parseDisplay(String? raw) {
    return tdisplay == "flex"
        ? CssDisplay.flex
        : tdisplay == "inline"
            ? CssDisplay.inline
            : CssDisplay.block;
  }
}
