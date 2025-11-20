import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssLineHeight on FlutterStyleFromCss {
  double? parseLineHeight(String? cssLineHeight) {
    if (cssLineHeight == null) return null;
    cssLineHeight = cssLineHeight.replaceAll("!important", "");
    if (cssLineHeight.contains('em')) {
      double emValue = double.parse(cssLineHeight.replaceAll('em', '')) * em;
      return emValue / em;
    } else if (cssLineHeight.contains('px')) {
      double pxValue = double.parse(cssLineHeight.replaceAll('px', ''));
      return pxValue / em;
    } else if (cssLineHeight.contains('%')) {
      double percentage = double.parse(cssLineHeight.replaceAll('%', ''));
      return percentage / 100.0;
    } else {
      return double.parse(cssLineHeight);
    }
  }
}
