import 'dart:convert';

import 'package:get/get.dart';
import 'package:voidlord/tono_reader/state/tono_progresser.dart';

class TonoLocation {
  TonoLocation({
    required this.xhtmlIndex,
    required this.elementIndex,
  });
  int xhtmlIndex;
  int elementIndex;

  Map<String, dynamic> toJson() {
    return {
      "xhtmlIndex": xhtmlIndex,
      "elementIndex": elementIndex,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "xhtmlIndex": xhtmlIndex,
      "elementIndex": elementIndex,
    };
  }

  static TonoLocation fromMap(Map<String, dynamic> map) {
    return TonoLocation(
      xhtmlIndex: map['xhtmlIndex'] as int,
      elementIndex: map['elementIndex'] as int,
    );
  }

  @override
  String toString() {
    return json.encoder.convert(toMap());
  }

  int toIndex() {
    var progressor = Get.find<TonoProgresser>();
    int count = 0;
    for (int i = 0; i < xhtmlIndex; i++) {
      count += progressor.elementSequence[i];
    }
    count += elementIndex;
    return count;
  }
}

extension TonoLocationExtension on int {
  TonoLocation toLocation() {
    var progressor = Get.find<TonoProgresser>();
    var count = this;
    int index = 0;
    while (count - progressor.elementSequence[index] >= 0 &&
        index < progressor.elementSequence.length) {
      count -= progressor.elementSequence[index];
      index++;
    }
    return TonoLocation(
      elementIndex: count,
      xhtmlIndex: index,
    );
  }
}
