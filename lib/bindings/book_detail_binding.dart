import 'package:get/get.dart';
import 'package:voidlord/pages/book/book_detail_controller.dart';

class BookDetailBinding extends Bindings {
  @override
  void dependencies() {
    String? tag;
    final paramId = Get.parameters['id'];
    if (paramId != null) {
      tag = paramId;
    } else if (Get.arguments is int) {
      tag = (Get.arguments as int).toString();
    } else if (Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['id'] != null) {
        tag = args['id'].toString();
      }
    }

    Get.lazyPut(() => BookDetailController(), tag: tag);
  }
}
