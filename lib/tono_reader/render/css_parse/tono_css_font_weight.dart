import 'dart:ui';

import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssFontWeight on FlutterStyleFromCss {
  FontWeight? parseFontWeight(String? cssFontWeight) {
    if (cssFontWeight == null) return null;
    switch (cssFontWeight.toLowerCase()) {
      case '100':
        return FontWeight.w100;
      case '200':
        return FontWeight.w200;
      case '300':
        return FontWeight.w300;
      case '400':
      case 'normal':
        return FontWeight.w400;
      case '500':
        return FontWeight.w500;
      case '600':
        return FontWeight.w600;
      case '700':
      case 'bold':
        return FontWeight.w700;
      case '800':
        return FontWeight.w800;
      case '900':
        return FontWeight.w900;
      default:
        return FontWeight.w400; // 默认值，处理未知情况
    }
  }
}
