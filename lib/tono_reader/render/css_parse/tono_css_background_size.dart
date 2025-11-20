import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';
import 'package:voidlord/tono_reader/tool/box_decoration.dart';

extension TonoCssBackgroundSize on FlutterStyleFromCss {
  BackgroundSize? parseBackgroundSize(String? raw) {
    var cssBackgroundSize = raw?.toValue();
    if (cssBackgroundSize == null) return null;
    if (cssBackgroundSize.contains(",")) {
      return null;
    }

    if (cssBackgroundSize.contains("cover")) {
      return BackgroundSize(
        widthMode: BackgroundSizeMode.cover,
        heightMode: BackgroundSizeMode.cover,
      );
    }
    if (cssBackgroundSize.contains("contain")) {
      return BackgroundSize(
        widthMode: BackgroundSizeMode.contain,
        heightMode: BackgroundSizeMode.contain,
      );
    }
    var cbgsSplited = cssBackgroundSize.split(" ");
    if (cbgsSplited.length == 1) {
      var value = cbgsSplited[0];
      if (value.contains("%")) {
        var pv = double.parse(value.replaceAll("%", "")) / 100;
        return BackgroundSize.percentage(pv, pv);
      } else if (value.contains("auto")) {
        return BackgroundSize(
          heightMode: BackgroundSizeMode.auto,
          widthMode: BackgroundSizeMode.auto,
        );
      } else {
        var uv = parseUnit(value, 0, em);
        return BackgroundSize.fixed(uv, uv);
      }
    } else if (cbgsSplited.length == 2) {
      var widthValue = cbgsSplited[0];
      var heightValue = cbgsSplited[1];
      BackgroundSizeMode wm = BackgroundSizeMode.fixed;
      BackgroundSizeMode hm = BackgroundSizeMode.fixed;
      double wv = 0;
      double hv = 0;
      if (widthValue.contains("%")) {
        wv = double.parse(widthValue.replaceAll("%", "")) / 100;
        wm = BackgroundSizeMode.percentage;
      } else if (widthValue.contains("auto")) {
        wm = BackgroundSizeMode.auto;
      } else {
        wv = parseUnit(widthValue, 0, em);
      }
      if (heightValue.contains("%")) {
        hv = double.parse(heightValue.replaceAll("%", "")) / 100;
        hm = BackgroundSizeMode.percentage;
      } else if (heightValue.contains("auto")) {
        hm = BackgroundSizeMode.auto;
      } else {
        hv = parseUnit(widthValue, 0, em);
      }
      return BackgroundSize(
          widthMode: wm, heightMode: hm, widthValue: wv, heightValue: hv);
    }

    return null;
  }
}
