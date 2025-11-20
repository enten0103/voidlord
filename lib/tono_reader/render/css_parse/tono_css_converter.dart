import 'package:flutter/widgets.dart';
import 'package:get/get_core/get_core.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_align_item.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_background_color.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_background_image.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_background_position.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_background_size.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_border.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_border_radius.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_box_shadow.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_display.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_font_family.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_font_weight.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_height.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_image_repet.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_justify_content.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_line_height.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_margin.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_padding.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_tansform.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_text_align.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_text_indent.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_text_shadow.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_transform_origin.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_width.dart';
import 'package:voidlord/tono_reader/render/state/tono_container_provider.dart';
import 'package:voidlord/tono_reader/tool/box_decoration.dart';
import 'package:voidlord/tono_reader/tool/color_tool.dart';
import 'package:voidlord/tono_reader/tool/css_tool.dart';
import 'package:voidlord/tono_reader/tool/styled_border.dart';

mixin FlutterCssMixin {
  late final Map<String, dynamic> flutterStyleMap;

  /// css [align-items] => flutter [CrossAxisAlignment]
  CrossAxisAlignment get alignItems =>
      flutterStyleMap["align-items"] ?? CrossAxisAlignment.start;

  Color? get backgroundColor => flutterStyleMap["background-color"];

  String? get backgroundImage => flutterStyleMap["background-image"];

  AlignmentGeometry? get backgroundPosition =>
      flutterStyleMap["background-position"];

  BackgroundSize? get backgroundSize => flutterStyleMap["background-size"];

  BorderRadius? get borderRadius => flutterStyleMap["border-radius"];

  StyledBorder? get border => flutterStyleMap["border"];

  BoxShadow? get boxShadow => flutterStyleMap["box-shadow"];

  Color? get color => flutterStyleMap["color"];

  FontWeight? get fontWeight => flutterStyleMap["font-weight"];

  /// css [display] -> flutter [ CssDisplay ]
  CssDisplay get display => flutterStyleMap["display"] ?? CssDisplay.block;

  ///
  /// css [height] -> [CssHeight]
  CssHeight? get height => flutterStyleMap["height"];

  ///
  /// css[max-height] -> [CssHeight]
  CssHeight? get maxHeight => flutterStyleMap["max-height"];

  ImageRepeat get backgroundRepet =>
      flutterStyleMap["background-repeat"] ?? ImageRepeat.noRepeat;

  double get fontSize => flutterStyleMap["font-size"];

  List<String> get fontFamily => flutterStyleMap["font-family"];

  MainAxisAlignment get justifyContent =>
      flutterStyleMap["justify-content"] ?? MainAxisAlignment.start;

  double get lineHeight => flutterStyleMap["line-height"] ?? 1;

  CssMargin? get marginLeft => flutterStyleMap["margin-left"];

  CssMargin? get marginRight => flutterStyleMap["margin-right"];

  CssMargin? get marginTop => flutterStyleMap["margin-top"];

  CssMargin? get marginBottom => flutterStyleMap["margin-bottom"];

  EdgeInsets? get padding => flutterStyleMap["padding"];

  Matrix4? get transform => flutterStyleMap["transform"];

  TextAlign get textAlign => flutterStyleMap["text-align"] ?? TextAlign.start;

  int? get textIndent => flutterStyleMap['text-indent'];

  Shadow? get textShadow => flutterStyleMap['text-shadow'];

  Alignment get transformOrigin =>
      flutterStyleMap["transform-origin"] ?? Alignment.center;

  /// css [width] -> [CssWidth]
  CssWidth? get width => flutterStyleMap['width'];

  String? get pDisplay => flutterStyleMap['pdisplay'];

  /// css [max-width] -> [CssWidth]
  CssWidth? get maxWidth => flutterStyleMap['max-width'];
}

///
/// css到flutter组件映像
///
class FlutterStyleFromCss {
  /// 字体大小
  late final double em;

  /// 存储 map
  final Map<String, dynamic> flutterStyleMap = {};

  /// 父容器大小
  final PredictSize? parentSize;

  /// container display
  late final String? tdisplay;

  /// parent display
  late final String? pdisplay;

  FlutterStyleFromCss(
    List<TonoStyle> styleList, {
    this.tdisplay,
    this.parentSize,
    required this.pdisplay,
  }) {
    _initFontSize(styleList);
    _initAllStyle(styleList);
  }
  _initFontSize(List<TonoStyle> styleList) {
    var config = Get.find<TonoReaderConfig>();
    var width = Get.mediaQuery.size.width;
    var emStyle = styleList.where((e) {
      return e.property == "font-size";
    }).first;
    em = parseUnit(emStyle.value, width, config.fontSize);
    flutterStyleMap["font-size"] = em;
  }

  _initAllStyle(List<TonoStyle> styleList) {
    Map<String, String> cssMap = styleList.toMap();
    flutterStyleMap['align-items'] = parseAlignItem(cssMap['align-items']);
    flutterStyleMap['background-color'] =
        parseBackgroundColor(cssMap['background-color']);
    flutterStyleMap['background-image'] =
        parseBackgroundImage(cssMap['background-image']);
    flutterStyleMap['background-position'] =
        parseBackgorundPosition(cssMap['background-position']);
    flutterStyleMap['background-repeat'] =
        parseBackgroundRepet(cssMap['background-repeat']);
    flutterStyleMap['border-radius'] =
        parseBorderRadius(cssMap['border-radius']);
    flutterStyleMap['background-size'] =
        parseBackgroundSize(cssMap['background-size']);
    flutterStyleMap['box-shadow'] = parseBoxShadow(cssMap['box-shadow']);
    flutterStyleMap['color'] = parseColor(cssMap['color']);
    flutterStyleMap['font-weight'] = parseFontWeight(cssMap['font-weight']);
    flutterStyleMap['font-family'] = parseFontFamily(cssMap['font-family']);
    flutterStyleMap['display'] = parseDisplay(cssMap['display']);
    flutterStyleMap['height'] = parseHeight(cssMap['height']);
    flutterStyleMap['max-height'] = parseHeight(cssMap['max-height']);
    flutterStyleMap['justify-content'] =
        parseJustifyContent(cssMap['justify-content']);
    flutterStyleMap['line-height'] = parseLineHeight(cssMap['line-height']);
    flutterStyleMap['margin-left'] = parseMargin(cssMap['margin-left']);
    flutterStyleMap['margin-right'] = parseMargin(cssMap['margin-right']);
    flutterStyleMap['margin-top'] = parseMargin(cssMap['margin-top']);
    flutterStyleMap['margin-bottom'] = parseMargin(cssMap['margin-bottom']);
    flutterStyleMap['transform'] = parseTransform(cssMap['transform']);
    flutterStyleMap['text-align'] = parseTextAlign(cssMap['text-align']);
    flutterStyleMap['text-indent'] = parseTextIndent(cssMap['text-indent']);
    flutterStyleMap['text-shadow'] = parseTextShadow(cssMap['text-shadow']);
    flutterStyleMap['transform-origin'] =
        parseTransformOrigin(cssMap['transform-origin']);
    flutterStyleMap['width'] = parseWidth(cssMap['width']);
    flutterStyleMap['max-width'] = parseWidth(cssMap['max-width']);
    flutterStyleMap['padding'] = parsePadding(cssMap);
    flutterStyleMap['border'] = parseBorder(cssMap);
    flutterStyleMap['dispaly'] = parseDisplay(cssMap['display']);
    flutterStyleMap['pdisplay'] = pdisplay;
  }

  ///
  /// [cssUnit] 原css文本 [parent] 父容器尺寸 [em] 当前字体大小
  ///
  /// css 单位转 flutter px
  ///
  /// [em] [px] [%] [vh] [vw] -> px
  ///
  /// parent 应根据方向自取
  /// 默认应为width,少数情况下为height
  ///
  double parseUnit(
    String cssUnit,
    double? parent,
    double em,
  ) {
    /// em
    if (cssUnit.contains('em')) {
      double emValue = double.parse(cssUnit.replaceAll('em', '')) * em;
      return emValue;

      /// px
    } else if (cssUnit.contains('px')) {
      double pxValue = double.parse(cssUnit.replaceAll('px', ''));
      return pxValue;

      /// %
    } else if (cssUnit.contains('%')) {
      if (parent == null) throw NeedParentSizeException();
      double percentage = double.parse(cssUnit.replaceAll('%', ''));
      return parent * percentage / 100.0;

      /// vh
    } else if (cssUnit.contains('vh')) {
      double vhValue = double.parse(cssUnit.replaceAll('vh', ''));
      return Get.mediaQuery.size.height * vhValue / 100;

      /// vw
    } else if (cssUnit.contains("vw")) {
      double vwValue = double.parse(cssUnit.replaceAll('vw', ''));
      return Get.mediaQuery.size.height * vwValue / 100;
    } else {
      /// px
      return double.parse(cssUnit);
    }
  }

  Color? parseColor(String? colorStr) {
    return parseRawColor(colorStr)?.applyLightness();
  }

  Color? parseRawColor(String? colorStr) {
    if (colorStr == null) return null;
    final normalized = colorStr.toValue().toLowerCase();

    // 处理颜色名称
    if (_colorNameToHex.containsKey(normalized)) {
      return _parseHex('FF${_colorNameToHex[normalized]}');
    }

    // 处理RGB/RGBA
    if (normalized.startsWith('rgb')) {
      return _parseRgb(normalized);
    }

    // 处理十六进制
    return _parseHex(normalized);
  }

  Color? _parseHex(String hex) {
    hex = hex.toUpperCase();
    if (hex.startsWith("#")) {
      hex = hex.replaceFirst("#", "");
    }
    if (hex.length == 3) {
      hex = hex.split('').map((c) => c + c).join();
      hex = 'FF$hex';
    } else if (hex.length == 6) {
      hex = 'FF$hex';
    }
    if (hex.length != 8) return null;

    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  Color? _parseRgb(String rgbStr) {
    final params =
        rgbStr.replaceAll(RegExp(r'^rgba?\(|\)$', caseSensitive: false), '');
    final parts = params.split(',').map((s) => s.trim()).toList();

    if (parts.length != 3 && parts.length != 4) return null;

    final r = _parseColorValue(parts[0]);
    final g = _parseColorValue(parts[1]);
    final b = _parseColorValue(parts[2]);
    if (r == null || g == null || b == null) return null;

    double a = 1.0;
    if (parts.length == 4) {
      final parsedA = _parseAlphaValue(parts[3]);
      if (parsedA == null) return null;
      a = parsedA;
    }

    final alphaHex = (a * 255).round().toRadixString(16).padLeft(2, '0');
    final hex = alphaHex +
        r.toRadixString(16).padLeft(2, '0') +
        g.toRadixString(16).padLeft(2, '0') +
        b.toRadixString(16).padLeft(2, '0');

    return _parseHex(hex);
  }

  int? _parseColorValue(String part) {
    try {
      if (part.endsWith('%')) {
        final percent = double.parse(part.substring(0, part.length - 1));
        return (percent / 100 * 255).round().clamp(0, 255);
      }
      return int.parse(part).clamp(0, 255);
    } catch (e) {
      return null;
    }
  }

  double? _parseAlphaValue(String part) {
    try {
      if (part.endsWith('%')) {
        return double.parse(part.substring(0, part.length - 1)) / 100;
      }
      return double.parse(part).clamp(0.0, 1.0);
    } catch (e) {
      return null;
    }
  }

  static const _colorNameToHex = {
    'black': '000000',
    'white': 'ffffff',
    'red': 'ff0000',
    'lime': '00ff00',
    'blue': '0000ff',
    'yellow': 'ffff00',
    'cyan': '00ffff',
    'magenta': 'ff00ff',
    'silver': 'c0c0c0',
    'gray': '808080',
    'maroon': '800000',
    'olive': '808000',
    'green': '008000',
    'purple': '800080',
    'teal': '008080',
    'navy': '000080',
    'orange': 'ffa500',
  };
}

///
/// 依赖父容器大小
/// 捕获此异常时应提供父容器大小
class NeedParentSizeException extends Error {}

extension ToRawStr on String {
  /// 处理 !important声明&&trim
  String toValue() => replaceAll("!important", "").trim();
}
