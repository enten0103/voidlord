import 'package:flutter/material.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssBoxShadow on FlutterStyleFromCss {
  BoxShadow? parseBoxShadow(String? raw) {
    var cssBoxShadow = raw?.toValue();
    if (cssBoxShadow == null) return null;
    var values = cssBoxShadow.split(" ");
    if (values.length == 4) {
      return BoxShadow(
          offset:
              Offset(parseUnit(values[0], 0, em), parseUnit(values[1], 0, em)),
          blurRadius: parseUnit(values[2], 0, em),
          color: parseColor(values[3]) ?? Colors.black);
    }
    return null;
  }
}
