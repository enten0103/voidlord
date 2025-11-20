import 'package:get/instance_manager.dart';
import 'package:voidlord/pages/reader/reader_controller.dart';

class ReaderBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReaderController());
  }
}
