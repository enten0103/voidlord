import 'package:flutter/widgets.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssBorderRadius on FlutterStyleFromCss {
  BorderRadius? parseBorderRadius(String? raw) {
    var cssBorderRadius = raw?.toValue();
    if (cssBorderRadius == null) return null;
    return BorderRadius.circular(
        parseUnit(cssBorderRadius, parentSize?.width, em));
  }
}
