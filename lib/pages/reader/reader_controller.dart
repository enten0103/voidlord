import 'package:get/get.dart';

class ReaderController extends GetxController {
  late RxString id = Get.parameters["id"]!.obs;
  late RxString type = Get.parameters["type"]!.obs;
}
