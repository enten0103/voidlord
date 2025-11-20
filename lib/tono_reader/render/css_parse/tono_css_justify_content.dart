import 'package:flutter/widgets.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

///
/// css justifyContent value
extension TonoCssJustifyContent on FlutterStyleFromCss {
  MainAxisAlignment parseJustifyContent(String? raw) {
    raw = raw?.toValue();
    if (raw == null) return MainAxisAlignment.start;
    return switch (raw) {
      "flex-start" => MainAxisAlignment.start,
      "flex-end" => MainAxisAlignment.end,
      "center" => MainAxisAlignment.center,
      "space-between" => MainAxisAlignment.spaceBetween,
      "space-around" => MainAxisAlignment.spaceAround,
      "space-evenly" => MainAxisAlignment.spaceEvenly,
      _ => MainAxisAlignment.start,
    };
  }
}
