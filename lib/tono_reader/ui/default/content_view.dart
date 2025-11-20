import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/route_manager.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';

class ContentView extends StatelessWidget {
  const ContentView({
    super.key,
    required this.onDoubleTap,
    required this.onTap,
  });

  final Function onTap;

  final Function onDoubleTap;

  @override
  Widget build(BuildContext context) {
    TonoProgresser tonoProgresser = Get.find<TonoProgresser>();
    var controller = Get.find<TonoReaderController>();
    var config = Get.find<TonoReaderConfig>();
    var border = config.viewPortConfig;
    var totalIndex = 0;
    for (var i = 0; i < tonoProgresser.pageSequence.length; i++) {
      totalIndex += tonoProgresser.pageSequence[i];
    }
    return Stack(children: [
      PageView.builder(
          allowImplicitScrolling: true,
          onPageChanged: (pageCount) {
            tonoProgresser.pageIndex.value = pageCount + 1;
          },
          itemCount: totalIndex,
          itemBuilder: (ctx, index) => SafeArea(
                child: GestureDetector(
                    onTap: () {
                      onTap();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                        key: Key(tonoProgresser.xhtmlIndex.toString()),
                        padding: EdgeInsetsDirectional.fromSTEB(border.left,
                            border.top, border.right, border.bottom),
                        child: SizedBox.expand(
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: FutureBuilder(
                                    future: controller.getWidgetByIndex(index),
                                    builder: (ctx, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          return Text("error");
                                        } else {
                                          return snapshot.data!;
                                        }
                                      }
                                      return Text("loading asstes");
                                    }))))),
              )),
      Positioned(
        bottom: border.bottom,
        right: border.right,
        child: Obx(() => Text(
                "${tonoProgresser.pageIndex.value}/${tonoProgresser.pageSequence.reduce((a, b) {
              return a + b;
            })}")),
      ),
    ]);
  }
}
