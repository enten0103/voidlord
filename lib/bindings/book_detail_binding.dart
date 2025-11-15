import 'package:get/get.dart';
import '../pages/book/book_detail_controller.dart';

class BookDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BookDetailController());
  }
}
