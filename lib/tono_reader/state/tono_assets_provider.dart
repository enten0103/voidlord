import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';

class TonoAssetsProvider extends GetxController {
  final cache = <String, Uint8List>{}; // 静态缓存，提升至全局更佳
  late var tp = Get.find<TonoProvider>();
  Future<Uint8List> getAssetsById(String id) async {
    if (cache.containsKey(id)) {
      return cache[id]!;
    }
    var result = await tp.tono.widgetProvider.getAssetsById(id);
    cache[id] = result;
    return result;
  }
}
