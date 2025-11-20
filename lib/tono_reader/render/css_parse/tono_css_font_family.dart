import 'package:get/get.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';

extension TonoCssFontFamily on FlutterStyleFromCss {
  List<String> parseFontFamily(String? cssFontFamily) {
    if (cssFontFamily == null) return [];
    var tp = Get.find<TonoProvider>();
    var raw = cssFontFamily.replaceAll("!important", "").replaceAll(" ", "");
    return raw.split(",").map((e) {
      return tp.bookHash + e;
    }).toList();
  }
}
