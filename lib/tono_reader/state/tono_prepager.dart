import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_flager.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';
import 'package:voidlord/tono_reader/tool/pager.dart';

class TonoPrepager extends GetxController {
  var total = 0;
  void paging() {
    var flager = Get.find<TonoFlager>();
    var provider = Get.find<TonoProvider>();
    var progresser = Get.find<TonoProgresser>();
    progresser.pageSequence.addAll(provider.widgets.map((e) {
      return e.paging();
    }));
    flager.paging.value = false;
  }
}
