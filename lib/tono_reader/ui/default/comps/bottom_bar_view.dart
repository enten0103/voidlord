import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/state/tono_flager.dart';
import 'package:voidlord/tono_reader/state/tono_left_drawer_controller.dart';
import 'package:voidlord/tono_reader/tool/lightness.dart';
import 'package:voidlord/tono_reader/ui/default/comps/book_text_setting.dart';

class BottomBarView extends GetView<TonoReaderConfig> {
  const BottomBarView({
    super.key,
    required this.onMenuBtnPress,
  });

  final Function onMenuBtnPress;

  @override
  Widget build(BuildContext context) {
    RxBool isStared = false.obs;
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(),
          IconButton(
              onPressed: () {
                Get.find<TonoLeftDrawerController>()
                    .scaffoldKey
                    .currentState
                    ?.openDrawer();
              },
              icon: Icon(Icons.menu)),
          IconButton(
              onPressed: () {
                Get.find<TonoFlager>().isStateVisible.value = false;
                showBottomSheet(
                    context: context,
                    enableDrag: true,
                    showDragHandle: true,
                    builder: (ctx) {
                      return const BookTextSetting();
                    });
              },
              icon: Icon(Icons.text_format)),
          IconButton(
              onPressed: () {
                isStared.value = !isStared.value;
              },
              icon: Obx(() => isStared.value
                  ? Icon(Icons.star)
                  : Icon(Icons.star_outline))),
          IconButton(
              onPressed: () {
                controller.toggleLightNess();
              },
              icon: Obx(() => Icon(
                    controller.lightness.value == Lightness.light
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ))),
        ],
      ),
    );
  }
}
