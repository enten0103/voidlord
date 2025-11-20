import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TonoTextSettingController extends GetxController
    with GetSingleTickerProviderStateMixin {
  int index = 0;
  late PageController pageController = PageController();

  late TabController tabController =
      TabController(length: 3, initialIndex: index, vsync: this)
        ..addListener(() {
          if (tabController.indexIsChanging) {
            index = tabController.index;
            pageController.animateToPage(
              tabController.index,
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        });
  reInit() {
    pageController = PageController(initialPage: index);
    tabController.index = index;
  }

  @override
  void onClose() {
    tabController.dispose();
    pageController.dispose();
  }
}
