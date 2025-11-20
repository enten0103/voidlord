import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/state_manager.dart';
import 'package:voidlord/tono_reader/model/base/tono.dart';
import 'package:voidlord/tono_reader/model/base/tono_book_info.dart';
import 'package:voidlord/tono_reader/model/base/tono_location.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';
import 'package:voidlord/tono_reader/tool/tono_container_tool.dart';

class TonoProvider extends GetxController {
  late Tono tono;
  String bookHash = "";
  String title = "";
  int deepth = 0;
  List<TonoNavItem> navList = [];
  List<TonoWidget> widgets = [];
  List<String> xhtmls = [];

  String convertIndexToTitle(int index) {
    var xhtmlIndex = index.toLocation().xhtmlIndex;
    var xhtml = xhtmls[xhtmlIndex];
    var title = "";
    while (xhtmlIndex >= 0) {
      var nav = navList.firstWhereOrNull((e) => e.path == xhtml);
      if (nav != null) {
        title = nav.title;
        break;
      }
      xhtmlIndex--;
      xhtml = xhtmls[xhtmlIndex];
    }
    return title;
  }

  void initSliderProgressor() {
    var progressor = Get.find<TonoProgresser>();
    int sum = 0;
    for (int i = 0; i < widgets.length; i++) {
      var w = widgets[i];
      if (w is TonoContainer) {
        var elementCount = w.getScrollableWidgets(deepth).length;
        progressor.elementSequence.add(elementCount);
        sum += elementCount;
      }
    }
    progressor.totalElementCount = sum;
  }

  bool isLast(int count) {
    var progressor = Get.find<TonoProgresser>();
    int index = 0;
    while (count - progressor.elementSequence[index] >= 0 &&
        index < progressor.elementSequence.length) {
      count -= progressor.elementSequence[index];
      index++;
    }
    return widgets[index].getScrollableWidgets(deepth).length == count + 1;
  }

  TonoWidget getWidgetByElementCount(int count) {
    var progressor = Get.find<TonoProgresser>();
    int index = 0;
    while (count - progressor.elementSequence[index] >= 0 &&
        index < progressor.elementSequence.length) {
      count -= progressor.elementSequence[index];
      index++;
    }
    return widgets[index].getScrollableWidgets(deepth)[count];
  }

  Future init(Tono tono) async {
    this.tono = tono;
    bookHash = tono.hash;
    title = tono.bookInfo.title;
    deepth = tono.deepth;
    navList.addAll(List.from(tono.navItems));
    xhtmls.addAll(List.from(tono.xhtmls));
    for (var i = 0; i < xhtmls.length; i++) {
      var id = xhtmls[i];
      widgets.add(await getWidgetById(id));
    }
  }

  Future<TonoWidget> getWidgetById(String id) async {
    return tono.widgetProvider.getWidgetsById(id);
  }
}
