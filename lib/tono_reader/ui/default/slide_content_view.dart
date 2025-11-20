import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/render/widget/tono_outer_widget.dart';
import 'package:voidlord/tono_reader/tool/lightness.dart';
import 'package:voidlord/tono_reader/ui/default/comps/water_mark.dart';

class SlideContentView extends StatelessWidget {
  const SlideContentView({super.key});
  @override
  Widget build(BuildContext context) {
    var controller = Get.find<TonoReaderController>();
    return GetBuilder<TonoReaderConfig>(
        builder: (config) => GestureDetector(
            onTap: () => controller.onBodyClick(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                    width: Get.size.width,
                    height: config.viewPortConfig.top,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Align(
                                child: Container(
                              width: Get.size.width -
                                  config.viewPortConfig.left -
                                  config.viewPortConfig.right,
                              height: 20,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  config.lightness.value == Lightness.dark
                                      ? BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 1),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                          offset: Offset(0, 6),
                                        )
                                      : BoxShadow(
                                          color:
                                              Color.fromRGBO(216, 216, 216, 1),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                          offset: Offset(0, -6),
                                        ),
                                ],
                              ),
                            ))),
                        Container(
                          width: Get.size.width,
                          height: config.viewPortConfig.bottom,
                          color: Get.theme.colorScheme.surface,
                        )
                      ],
                    )),
                SizedBox(
                    height: Get.size.height -
                        config.viewPortConfig.top -
                        config.viewPortConfig.bottom,
                    width: Get.size.width,
                    child: GetBuilder<TonoReaderConfig>(
                        builder: (c) => TonoOuterWidget(
                              root: controller.tonoDataProvider.widgets[0]
                                  as TonoContainer,
                            ))),
                SizedBox(
                    width: Get.size.width,
                    height: config.viewPortConfig.bottom,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Align(
                                child: Container(
                              width: Get.size.width -
                                  config.viewPortConfig.left -
                                  config.viewPortConfig.right,
                              height: 20,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  config.lightness.value == Lightness.dark
                                      ? BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 1),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                          offset: Offset(0, 6),
                                        )
                                      : BoxShadow(
                                          color:
                                              Color.fromRGBO(216, 216, 216, 1),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                          offset: Offset(0, 6),
                                        ),
                                ],
                              ),
                            ))),
                        Container(
                          width: Get.size.width,
                          height: config.viewPortConfig.bottom,
                          color: Get.theme.colorScheme.surfaceContainer,
                          child: WaterMark(),
                        )
                      ],
                    )),
              ],
            )));
  }
}
