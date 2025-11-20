import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';
import 'package:voidlord/tono_reader/ui/default/comps/title_divline.dart';

class BookContent extends StatelessWidget {
  const BookContent({super.key});

  @override
  Widget build(BuildContext context) {
    TonoProvider provider = Get.find();
    TonoProgresser progresser = Get.find();
    TonoReaderController controller = Get.find();
    var navList = provider.navList;
    return ListView.separated(
      padding: EdgeInsets.only(top: 20, left: 4, right: 4),
      itemBuilder: (context, index) {
        if (index == (navList.length)) {
          return Container();
        }
        var navItem = navList[index];
        return InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () => controller.changeChapter(navItem.path),
            child: Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: Container(
                    padding: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      navItem.title,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16),
                    ))));
      },
      itemCount: navList.length + 1,
      separatorBuilder: (BuildContext context, int index) {
        return Obx(() {
          var title = provider
              .convertIndexToTitle(progresser.currentElementIndex.value);
          if (navList[index].title == title) {
            return TitleDivline(title: "看到此处");
          }
          return Container();
        });
      },
    );
  }
}
