import 'dart:ui';

import 'package:get/instance_manager.dart';
import 'package:path/path.dart' as p;
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/model/base/tono.dart';
import 'package:voidlord/tono_reader/render/state/tono_parent_size_cache.dart';
import 'package:voidlord/tono_reader/state/tono_assets_provider.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_flager.dart';
import 'package:voidlord/tono_reader/state/tono_left_drawer_controller.dart';
import 'package:voidlord/tono_reader/state/tono_prepager.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';
import 'package:voidlord/tono_reader/state/tono_text_setting_controller.dart';
import 'package:voidlord/tono_reader/state/tono_user_data_provider.dart';

class TonoInitializer {
  static load(Tono tono) async {
    await _loadFont(tono);
    await _initData(tono);
    await _initUserData();
  }

  static init() {
    _loadState();
    _loadConfig();
  }

  static Future<void> _loadFont(Tono tono) async {
    var fonts = await tono.widgetProvider.getAllFont();
    for (var font in fonts.entries) {
      var fontName = p.basenameWithoutExtension(font.key);
      await loadFontFromList(font.value, fontFamily: tono.hash + fontName);
    }
  }

  static _loadState() {
    Get.put(TonoAssetsProvider());
    Get.put(TonoProgresser());
    Get.put(TonoProvider());
    Get.put(TonoFlager());
    Get.put(TonoParentSizeCache());
    Get.put(TonoLeftDrawerController());
    Get.put(TonoPrepager());
    Get.put(TonoTextSettingController());
  }

  static _loadConfig() {
    Get.put(TonoReaderConfig());
  }

  static _initData(Tono tono) async {
    await Get.find<TonoProvider>().init(tono);
  }

  static _initUserData() async {
    var userData = TonoUserDataProvider();
    Get.put(userData);
  }
}
