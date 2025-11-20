import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/model/base/tono.dart';

class ParseBookDialogController extends GetxController
    with GetSingleTickerProviderStateMixin {
  ParseBookDialogController({required this.filePath, this.returnTono = false});
  final String filePath;
  final bool returnTono;
  RxInt current = 0.obs;
  RxInt total = 0.obs;
  RxString info = "".obs;

  /// 通过路由打开解析弹窗并在完成后返回 Tono（不落地保存）
  static Future<Tono?> showAndParse({required String filePath}) async {
    final result = await Get.dialog<Tono>(
      ParseBookDialog(
        filePath: filePath,
        returnTono: true,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black45,
    );
    return result;
  }

  @override
  void onReady() async {
    super.onReady();
    final parser = await TonoParser.initFromDisk(filePath);
    final sub = parser.events.listen((e) async {
      // 简单节流：避免 UI 过度刷新
      await Future.delayed(const Duration(milliseconds: 80));
      info.value = e.info;
      current.value = e.currentIndex;
      total.value = e.totalIndex;
    });
    try {
      if (returnTono) {
        final tono = await parser.parseInBackground();
        await sub.cancel();
        await Future.delayed(const Duration(milliseconds: 200));
        Get.back<Tono>(result: tono);
        return;
      } else {
        await parser.parseInBackgroundAndSave();
      }
    } finally {
      await sub.cancel();
    }
    await Future.delayed(const Duration(milliseconds: 200));
    Get.back();
  }
}

class ParseBookDialog extends StatelessWidget {
  const ParseBookDialog({
    required this.filePath,
    this.returnTono = false,
    super.key,
  });
  final String filePath;
  final bool returnTono;
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(
        ParseBookDialogController(filePath: filePath, returnTono: returnTono));
    return Obx(() => Dialog(
        elevation: 19,
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: Get.mediaQuery.size.width,
              maxHeight: 100,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, top: 20),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                            "正在解析:${controller.info.value}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                          Text(
                              " ${controller.current.value + 1}/${controller.total.value}")
                        ])),
                SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 0,
                      ),
                    ),
                    child: Obx(() {
                      return Slider(
                        value: controller.current.value.toDouble(),
                        min: 0,
                        max: controller.total.value.toDouble(),
                        onChanged: (_) {},
                      );
                    }))
              ],
            ))));
  }
}
