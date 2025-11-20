import 'package:flutter/widgets.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssBackgroundColor on FlutterStyleFromCss {
  Color? parseBackgroundColor(String? raw) {
    var cssBackgroundColor = raw?.toValue();
    if (cssBackgroundColor == null) return null;
    return parseColor(cssBackgroundColor);
  }
}
