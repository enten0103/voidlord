import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

abstract class CssMargin {}

class ValuedCssMargin implements CssMargin {
  const ValuedCssMargin({required this.value});
  final double value;
}

class KeyWordCssMargin implements CssMargin {}

extension TonoCssMargin on FlutterStyleFromCss {
  CssMargin parseMargin(String? raw) {
    var marginRaw = raw?.toValue();
    if (marginRaw == null) return ValuedCssMargin(value: 0);
    if (marginRaw == "auto") {
      return KeyWordCssMargin();
    }
    if (marginRaw.contains("left") || marginRaw.contains("right")) {
      return ValuedCssMargin(
          value: parseUnit(marginRaw, parentSize?.width, em));
    } else {
      return ValuedCssMargin(
          value: parseUnit(marginRaw, parentSize?.height, em));
    }
  }
}
