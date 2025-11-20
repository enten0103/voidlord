import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';

class SideBarView extends StatelessWidget {
  const SideBarView({super.key});

  @override
  Widget build(BuildContext context) {
    var progressor = Get.find<TonoProgresser>();
    var controller = Get.find<TonoReaderController>();
    return Padding(
        padding: EdgeInsets.only(
            right: 20,
            top: MediaQuery.of(context).padding.top + kToolbarHeight),
        child: SizedBox(
            width: 24,
            height: Get.height * 0.8,
            child: RotatedBox(
                quarterTurns: 1, // 逆时针旋转90度
                child: Obx(
                  () => Slider(
                    value: progressor.currentElementIndex.value.toDouble(),
                    min: 0,
                    max: progressor.totalElementCount.toDouble(),
                    onChanged: (c) {
                      controller.itemScrollController.jumpTo(
                        index: c.ceil(),
                      );
                    },
                    activeColor: Get.theme.colorScheme.onSurface,
                    inactiveColor: Get.theme.colorScheme.surfaceContainer,
                  ),
                ))));
  }
}
