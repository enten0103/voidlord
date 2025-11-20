import 'package:get/get.dart';
import 'package:voidlord/pages/book/book_detail_controller.dart';

class BookDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookDetailController());
  }
}
