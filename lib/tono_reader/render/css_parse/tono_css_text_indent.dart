import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssTextIndent on FlutterStyleFromCss {
  int? parseTextIndent(String? cssTextIntent) {
    if (cssTextIntent == null) return null;
    if (cssTextIntent.endsWith("px")) {
      var pxValue = double.parse(cssTextIntent.replaceAll("px", ""));
      return (pxValue / em).round();
    } else if (cssTextIntent.endsWith("em")) {
      var emValue = double.parse(cssTextIntent.replaceAll("em", ""));
      return emValue.round();
    }
    return null;
  }
}
