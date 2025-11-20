import 'package:flutter/rendering.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssTextAlign on FlutterStyleFromCss {
  TextAlign parseTextAlign(String? raw) {
    raw = raw?.toValue();
    if (raw == null) return TextAlign.justify;
    return switch (raw) {
      "center" => TextAlign.center,
      "left" => TextAlign.start,
      "right" => TextAlign.end,
      "justify" => TextAlign.justify,
      _ => TextAlign.justify,
    };
  }
}
