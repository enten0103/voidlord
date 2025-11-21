import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:window_manager/window_manager.dart';

class TopBarView extends StatelessWidget {
  const TopBarView({super.key, required this.bookTitle});

  final String bookTitle;

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: SizedBox(
        height:
            kToolbarHeight +
            MediaQuery.of(context).padding.top, // AppBar 高度 + 状态栏高度
        child: Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Row(
            children: [
              SizedBox(width: 10),
              SizedBox(
                child: IconButton(
                  icon: Icon(Icons.arrow_back_sharp),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  bookTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(width: 10),
              SizedBox(
                child: IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
