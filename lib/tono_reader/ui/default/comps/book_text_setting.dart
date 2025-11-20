import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/state/tono_text_setting_controller.dart';
import 'package:voidlord/tono_reader/ui/default/comps/text_setting/font_size_setting.dart';
import 'package:voidlord/tono_reader/ui/default/comps/text_setting/font_speace_setting.dart';
import 'package:voidlord/tono_reader/ui/default/comps/text_setting/font_wordspace_setting.dart';

class BookTextSetting extends GetView<TonoTextSettingController> {
  const BookTextSetting({super.key});

  @override
  Widget build(BuildContext context) {
    controller.reInit();
    return SizedBox(
        width: double.infinity,
        height: 150,
        child: Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: PageView(
                controller: controller.pageController,
                children: [
                  FontSizeSetting(),
                  FontSpeaceSetting(),
                  FontWordspaceSetting(),
                ],
              )),
              SizedBox(
                  height: 40,
                  child: TabBar(
                      dividerColor: Color.fromARGB(0, 0, 0, 0),
                      controller: controller.tabController,
                      tabs: [
                        Text("字号"),
                        Text("行距"),
                        Text("字距"),
                      ])),
              SizedBox(
                height: 20,
              )
            ])));
  }
}
