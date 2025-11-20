import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';
import 'package:voidlord/tono_reader/tool/clock.dart';
import 'package:voidlord/tono_reader/tool/color_tool.dart';

class WaterMark extends StatelessWidget {
  const WaterMark({super.key});

  @override
  Widget build(BuildContext context) {
    var progressor = Get.find<TonoProgresser>();
    var config = Get.find<TonoReaderConfig>();
    var provider = Get.find<TonoProvider>();
    return Padding(
        padding: EdgeInsets.only(
            left: config.viewPortConfig.left,
            right: config.viewPortConfig.right),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Clock(),
          Obx(() {
            var title = provider
                .convertIndexToTitle(progressor.currentElementIndex.value);
            return Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF999999).applyLightness(),
                      ),
                    )));
          }),
          Obx(() => Text(
                "${((progressor.currentElementIndex.value + 1) / progressor.totalElementCount * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF999999),
                ),
              )),
        ]));
  }
}
