import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/state/tono_left_drawer_controller.dart';

class LeftDarwer extends GetView<TonoLeftDrawerController> {
  const LeftDarwer({super.key});

  @override
  Widget build(BuildContext context) {
    controller.reInit();
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).padding.top,
        ),
        TabBar(
            controller: controller.tabController,
            dividerColor: Color.fromARGB(0, 0, 0, 0),
            tabs: [
              Text("目录", style: TextStyle(fontSize: 16)),
              Text("书签", style: TextStyle(fontSize: 16)),
            ]),
        Expanded(
          child: PageView(
            controller: controller.pageController,
            onPageChanged: (index) {
              controller.index = index;
              controller.tabController.animateTo(index);
            },
            children: controller.pages,
          ),
        )
      ],
    );
  }
}
