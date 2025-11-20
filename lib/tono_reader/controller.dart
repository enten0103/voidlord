import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/model/base/tono.dart';
import 'package:voidlord/tono_reader/model/base/tono_location.dart';
import 'package:voidlord/tono_reader/model/base/tono_type.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/render/widget/tono_container_widget.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_flager.dart';
import 'package:voidlord/tono_reader/state/tono_initializer.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';
import 'package:voidlord/tono_reader/state/tono_user_data_provider.dart';
import 'package:voidlord/tono_reader/tool/nav_darwer.dart';
import 'package:voidlord/tono_reader/tool/scroll/src/item_positions_listener.dart';
import 'package:voidlord/tono_reader/tool/scroll/src/scrollable_positioned_list.dart';
import 'package:voidlord/tono_reader/tool/tono_serializer.dart';
import 'package:voidlord/tono_reader/tool/type.dart';

class TonoReaderController extends GetxController {
  TonoReaderController({
    required this.id,
    required this.tonoType,
  });

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  final String id;
  final TonoType tonoType;

  late TonoFlager tonoFlager = Get.find<TonoFlager>();
  late TonoProgresser tonoProgresser = Get.find<TonoProgresser>();
  late TonoProvider tonoDataProvider = Get.find<TonoProvider>();
  late TonoUserDataProvider tonoUserDataProvider =
      Get.find<TonoUserDataProvider>();

  void changeLocation(TonoLocation location) {
    itemScrollController.jumpTo(
      index: location.toIndex(),
    );
  }

  void changeChapter(String id) async {
    var index = tonoDataProvider.xhtmls.indexOf(id);
    var resultIndex = 0;
    for (var i = 0; i < index; i++) {
      resultIndex += tonoProgresser.elementSequence[i];
    }
    itemScrollController.jumpTo(
      index: resultIndex,
    );
  }

  void onBodyClick() {
    tonoFlager.isStateVisible.value =
        !tonoFlager.isStateVisible.value; // 点击切换状态
  }

  void openNavDrawer() {
    NavDarwer.openNavDrawer();
  }

  Future<Widget> getWidgetByIndex(int index) async {
    index++;
    var tonoProgresser = Get.find<TonoProgresser>();
    var pageSequence = tonoProgresser.pageSequence;
    var xhtmlIndex = 0;
    while (index > pageSequence[xhtmlIndex]) {
      index -= pageSequence[xhtmlIndex];
      xhtmlIndex++;
    }
    var xhtmlId = tonoDataProvider.xhtmls[xhtmlIndex];
    return TonoContainerWidget(
        tonoContainer:
            await tonoDataProvider.getWidgetById(xhtmlId) as TonoContainer);
  }

  Future init() async {
    TonoInitializer.init();
    if (tonoType == TonoType.local) {
      var tono = await _initFromDisk();
      await TonoInitializer.load(tono);
      tonoFlager.state.value = LoadingState.success;
    }
    if (tonoType == TonoType.net) {
      _initFromNet();
      throw UnimplementedError();
    }
  }

  @override
  void onInit() {
    TonoReaderConfig.init();
    init();
    super.onInit();
  }

  Future<Tono> _initFromDisk() async {
    return TonoSerializer.deserialize(id);
  }

  _initFromNet() {}

  @override
  void onClose() => TonoReaderConfig.close();
}
