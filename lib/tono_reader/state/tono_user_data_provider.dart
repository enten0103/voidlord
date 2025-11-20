import 'package:get/get.dart';
import 'package:voidlord/tono_reader/model/base/tono_location.dart';
import 'package:voidlord/tono_reader/model/tono_book_mark.dart';
import 'package:voidlord/tono_reader/model/tono_book_note.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';

class TonoUserDataProvider extends GetxController {
  List<TonoBookMark> bookmarks = [];
  List<TonoBookNote> booknotes = [];
  var bookHash = Get.find<TonoProvider>().bookHash;
  TonoLocation histroy = TonoLocation(xhtmlIndex: 0, elementIndex: 0);

  bool isMarked(TonoLocation location) {
    return false;
  }
}
