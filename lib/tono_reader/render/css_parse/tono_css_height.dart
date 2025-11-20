import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

//
// 检查到有未实现的css-height关键字
class UnimplementedHeightKeyWordError extends Error {
  UnimplementedHeightKeyWordError({required this.message});
  final String message;
}

///CssWidth
abstract class CssHeight {}

///
/// CssWidth关键词
/// 已实现 [auto] [fit-content]
enum CssHeightKeyWords {
  auto,
  fitContent,
}

///
/// CssWidth length values
class ValuedCssHeight extends CssHeight {
  ValuedCssHeight({required this.value});
  final double value;
  @override
  String toString() {
    return value.toString();
  }
}

///
/// CssKeyWordsWidth
class KeyWordCssHeight extends CssHeight {
  KeyWordCssHeight({required this.keyWord});
  final CssHeightKeyWords keyWord;
  @override
  String toString() {
    return keyWord.name;
  }
}

///
///css [height] css [max-height] 实现
extension TonoCssHeight on FlutterStyleFromCss {
  CssHeight? parseHeight(String? raw) {
    if (raw == null) {
      return null;
    }
    var heightValue = raw.toValue();

    if (heightValue == "auto" ||
        heightValue == "inherit" ||
        heightValue == "initial" ||
        heightValue == "unset") {
      return KeyWordCssHeight(keyWord: CssHeightKeyWords.auto);
    }
    if (heightValue == "fit-content") {
      return KeyWordCssHeight(keyWord: CssHeightKeyWords.fitContent);
    }

    /// 未实现关键字
    if (heightValue == "max-content" ||
        heightValue == "min-content" ||
        heightValue.contains("fit-content")) {
      throw UnimplementedHeightKeyWordError(message: "keyWord:$raw");
    }

    return ValuedCssHeight(
        value: parseUnit(heightValue, parentSize?.height, em));
  }
}
