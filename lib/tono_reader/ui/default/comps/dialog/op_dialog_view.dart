import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/model/base/tono_location.dart';
import 'package:voidlord/tono_reader/model/tono_book_mark.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_user_data_provider.dart';
import 'package:voidlord/tono_reader/tool/tono_container_stringify.dart';

class OpDialogView extends StatelessWidget {
  const OpDialogView({
    super.key,
    required this.index,
    required this.location,
    required this.isMarked,
  });

  final int index;
  final TonoLocation location;
  final RxBool isMarked;

  @override
  Widget build(BuildContext context) {
    var expended = false.obs;
    var provider = Get.find<TonoProvider>();
    var userData = Get.find<TonoUserDataProvider>();
    return Dialog(
      elevation: 19,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: Get.mediaQuery.size.width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Text("操作", style: TextStyle(fontSize: 24)),
            SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: 24, right: 24),
              child: AnimatedSize(
                duration: Duration(milliseconds: 300),
                child: Obx(
                  () => Container(
                    constraints: !expended.value
                        ? BoxConstraints(maxHeight: 20)
                        : BoxConstraints(maxHeight: 200),
                    width: double.infinity,
                    child: SelectableText(
                      provider.getWidgetByElementCount(index).stringify(),
                      maxLines: !expended.value ? 1 : null,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    expended.value = !expended.value;
                  },
                  icon: Obx(
                    () => !expended.value
                        ? Icon(Icons.fullscreen)
                        : Icon(Icons.fullscreen_exit),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    isMarked.value = !isMarked.value;
                    if (isMarked.value == true) {
                      userData.bookmarks.add(
                        TonoBookMark(
                          description: provider
                              .getWidgetByElementCount(index)
                              .stringify(),
                          location: location,
                          createTime: DateTime.now(),
                        ),
                      );
                    } else {
                      userData.bookmarks.removeWhere((e) {
                        return e.location.elementIndex ==
                                location.elementIndex &&
                            e.location.xhtmlIndex == location.xhtmlIndex;
                      });
                    }
                  },
                  icon: Obx(() {
                    if (isMarked.value) {
                      return Icon(Icons.bookmark_added);
                    } else {
                      return Icon(Icons.bookmark_add_outlined);
                    }
                  }),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: provider
                            .getWidgetByElementCount(index)
                            .stringify(),
                      ),
                    );
                  },
                  icon: Icon(Icons.copy_all_outlined),
                ),
                SizedBox(width: 12),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
