import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';

class Marker extends StatelessWidget {
  const Marker({super.key, required this.isMarked});

  final bool isMarked;

  @override
  Widget build(BuildContext context) {
    var config = Get.find<TonoReaderConfig>();
    return Positioned.fill(
        child: Transform.translate(
      offset: Offset(-config.viewPortConfig.left, 0),
      child: Align(
          alignment: Alignment.topLeft,
          child: isMarked
              ? Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    clipBehavior: Clip.hardEdge,
                    width: 5,
                    child: Container(color: config.markerColor),
                  ))
              : Container()),
    ));
  }
}
