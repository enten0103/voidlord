import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/controller.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';

class NavDarwer {
  static void openNavDrawer() async {
    var controller = Get.find<TonoReaderController>();
    late TonoProvider tonoDataProvider = Get.find<TonoProvider>();
    var navList = tonoDataProvider.navList;
    showModalBottomSheet(
        context: Get.context!,
        builder: (ctx) {
          return BottomSheet(
              onClosing: () {},
              builder: (ctx) {
                return Padding(
                    padding: EdgeInsets.all(20),
                    child: SizedBox(
                      height: Get.mediaQuery.size.height / 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.dataset,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "章节",
                                    style: TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                              Row(
                                children: [],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Expanded(
                            child: ListView.builder(
                                itemCount: tonoDataProvider.navList.length,
                                itemBuilder: (ctx, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                          child: TextButton(
                                        style: TextButton.styleFrom(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(left: 20)),
                                        child: Text(
                                          navList[index].title,
                                          style: TextStyle(color: Colors.black),
                                          maxLines: 1,
                                        ),
                                        onPressed: () {
                                          controller.changeChapter(
                                              navList[index].path);
                                        },
                                      )),
                                      SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ));
              });
        });
  }
}
