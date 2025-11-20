import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/render/widget/tono_container_widget.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_prepager.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';
import 'package:voidlord/tono_reader/tool/pager.dart';

class PagingView extends StatelessWidget {
  const PagingView({super.key});

  @override
  Widget build(BuildContext context) {
    TonoProgresser tonoProgresser = Get.find<TonoProgresser>();
    var provider = Get.find<TonoProvider>();
    var config = Get.find<TonoReaderConfig>();
    var controller = Get.find<TonoReaderController>();
    var border = config.viewPortConfig;
    var prepager = Get.find<TonoPrepager>();
    for (var widget in provider.widgets) {
      prepager.total += widget.prepaging();
    }
    return GestureDetector(
      onTap: controller.onBodyClick,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        key: Key(tonoProgresser.xhtmlIndex.toString()),
        padding: EdgeInsetsDirectional.fromSTEB(
          border.left,
          border.top,
          border.right,
          border.bottom,
        ),
        child: Stack(
          children: [
            SafeArea(
              child: SizedBox.expand(
                child: SingleChildScrollView(
                  child: Column(
                    children: provider.widgets.map((e) {
                      prepager.total += e.prepaging();
                      return SizedBox(
                        height:
                            Get.mediaQuery.size.height -
                            config.viewPortConfig.bottom -
                            config.viewPortConfig.top,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TonoContainerWidget(
                            tonoContainer: e as TonoContainer,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              width: Get.mediaQuery.size.width,
              height: Get.mediaQuery.size.height,
              child: Center(child: Text("paging")),
            ),
          ],
        ),
      ),
    );
  }
}
