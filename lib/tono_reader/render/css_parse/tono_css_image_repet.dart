import 'package:flutter/material.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssImageRepet on FlutterStyleFromCss {
  ImageRepeat parseBackgroundRepet(String? raw) {
    var cssRepet = raw?.toValue();
    if (cssRepet == null) return ImageRepeat.noRepeat;
    if (cssRepet == "repeat") {
      return ImageRepeat.repeat;
    }
    return ImageRepeat.noRepeat;
  }
}
