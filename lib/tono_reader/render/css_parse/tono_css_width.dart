import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

//
// 检查到有未实现的css-width关键字
class UnimplementedWidthKeyWordError extends Error {
  UnimplementedWidthKeyWordError({required this.message});
  final String message;
}

///CssWidth
abstract class CssWidth {}

///
/// CssWidth关键词
/// 已实现 [auto] [fit-content]
enum CssWidthKeyWords {
  auto,
  fitContent,
}

///
/// CssWidth length values
class ValuedCssWidth extends CssWidth {
  ValuedCssWidth({required this.value});
  final double value;
  @override
  String toString() {
    return value.toString();
  }
}

///
/// CssKeyWordsWidth
class KeyWordCssWidth extends CssWidth {
  KeyWordCssWidth({required this.keyWord});
  final CssWidthKeyWords keyWord;
  @override
  String toString() {
    return keyWord.name;
  }
}

///
/// css [width] [max-width] 实现
extension TonoCssWidth on FlutterStyleFromCss {
  CssWidth? parseWidth(String? raw) {
    if (raw == null) {
      return null;
    }

    var widthValue = raw.toValue();
    if (widthValue == "auto" ||
        widthValue == "inherit" ||
        widthValue == "initial" ||
        widthValue == "unset") {
      return KeyWordCssWidth(keyWord: CssWidthKeyWords.auto);
    }
    if (widthValue == "fit-content") {
      return KeyWordCssWidth(keyWord: CssWidthKeyWords.fitContent);
    }

    /// 未实现关键字
    if (widthValue == "max-content" ||
        widthValue == "min-content" ||
        widthValue.contains("fit-content")) {
      throw UnimplementedWidthKeyWordError(message: "keyWord:$raw");
    }

    var result =
        ValuedCssWidth(value: parseUnit(widthValue, parentSize?.width, em));
    if (result.value <= 0) {
      result = ValuedCssWidth(value: 0);
    }
    return result;
  }
}
