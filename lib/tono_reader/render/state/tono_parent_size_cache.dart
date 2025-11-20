import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:voidlord/tono_reader/render/state/tono_container_provider.dart';

class TonoParentSizeCache extends GetxController {
  final Map<int, PredictSize> _cache = {};

  PredictSize? getSize(int key) {
    return _cache[key];
  }

  void setSize(int key, PredictSize size) {
    _cache[key] = size;
  }

  void clear() {
    _cache.clear();
  }
}
