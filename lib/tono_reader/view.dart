import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/model/base/tono_type.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_flager.dart';
import 'package:voidlord/tono_reader/state/tono_left_drawer_controller.dart';
import 'package:voidlord/tono_reader/ui/default/comps/bottom_bar_view.dart';
import 'package:voidlord/tono_reader/ui/default/comps/drawers/left_darwer.dart';
import 'package:voidlord/tono_reader/ui/default/comps/drawers/side_bar_view.dart';
import 'package:voidlord/tono_reader/ui/default/slide_content_view.dart';
import 'package:voidlord/tono_reader/ui/default/comps/drawers/top_bar_view.dart';
import 'package:voidlord/tono_reader/tool/type.dart';

class TonoReader extends StatelessWidget {
  const TonoReader({
    super.key,
    required this.id,
    required this.tonoType,
  });
  final String id;
  final TonoType tonoType;

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(TonoReaderController(id: id, tonoType: tonoType));
    TonoLeftDrawerController sideBarController = Get.find();
    TonoFlager flager = Get.find();
    TonoProvider dataProvoder = Get.find();

    return Scaffold(
      key: sideBarController.scaffoldKey,
      body: Stack(
        children: [
          // 阅读内容，固定大小
          Positioned.fill(
              child: Obx(() => AnimatedSwitcher(
                  duration: Duration(milliseconds: 700),
                  child: switch (flager.state.value) {
                    LoadingState.loading => _buildLoading(),
                    LoadingState.failed => _buildFailed(),
                    LoadingState.success => _buildSuccess(controller, flager)
                  }))),
          // AppBar 的滑动动画
          Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Obx(
                () => AnimatedSlide(
                    offset: flager.isStateVisible.value
                        ? Offset(0, 0)
                        : Offset(0, -1), // 从顶部滑出
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: TopBarView(bookTitle: dataProvoder.title)),
              )),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() => AnimatedSlide(
                  offset: flager.isStateVisible.value
                      ? Offset(0, 0)
                      : Offset(0, 1), // 从底部滑出
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: BottomBarView(
                    onMenuBtnPress: () {
                      controller.openNavDrawer();
                    },
                  ),
                )),
          ),
          Positioned(
            right: 0,
            child: Obx(() => AnimatedSlide(
                  offset:
                      flager.isStateVisible.value ? Offset(0, 0) : Offset(1, 0),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: SideBarView(),
                )),
          ),
        ],
      ),
      drawer: Drawer(
        child: LeftDarwer(),
      ),
    );
  }

  Widget _buildSuccess(TonoReaderController controller, TonoFlager flager) {
    return Obx(() => AnimatedScale(
        scale: flager.isStateVisible.value ? 0.8 : 1,
        filterQuality: FilterQuality.high,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        child: SlideContentView()));
  }

  Widget _buildLoading() {
    return CircularProgressIndicator(
      color: Get.theme.colorScheme.primary,
      strokeWidth: 2,
    );
  }

  Widget _buildFailed() {
    return Text("failed");
  }
}
