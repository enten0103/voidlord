import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/state/tono_left_drawer_controller.dart';
import 'package:voidlord/tono_reader/state/tono_user_data_provider.dart';
import 'package:voidlord/tono_reader/tool/time_tool.dart';

class BookMarkContent extends StatelessWidget {
  const BookMarkContent({super.key});

  @override
  Widget build(BuildContext context) {
    TonoUserDataProvider dataProvider = Get.find();
    TonoReaderController readerController = Get.find();
    TonoLeftDrawerController drawerController = Get.find();
    var bookmarks = dataProvider.bookmarks;
    return ListView.builder(
      itemCount: bookmarks.length,
      padding: EdgeInsets.only(top: 10, left: 4, right: 4),
      itemBuilder: (ctx, index) {
        return InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () {
            drawerController.closeDrawer();
            readerController.changeLocation(bookmarks[index].location);
          },
          child: Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 10),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.bookmark_added),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmarks[index].description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        bookmarks[index].createTime.formatDateTime(),
                        style: TextStyle(color: Color.fromARGB(128, 0, 0, 0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
