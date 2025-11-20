import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/ui/default/comps/book_content.dart';
import 'package:voidlord/tono_reader/ui/default/comps/book_mark_content.dart';

class TonoLeftDrawerController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var index = 0;

  late PageController pageController = PageController();

  late TabController tabController =
      TabController(length: 2, initialIndex: index, vsync: this)
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

  closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

  openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  List<Widget> pages = [
    BookContent(),
    BookMarkContent(),
  ];

  @override
  void onClose() {
    tabController.dispose();
    pageController.dispose();
  }
}
