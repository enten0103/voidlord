import 'package:get/get.dart';
import '../../apis/client.dart';

class RecommendationsController extends GetxController {
  final loading = false.obs;
  final error = RxnString();
  final recommendedBooks = <int>[].obs; // 简化：仅存书籍ID占位

  Api get api => Get.find<Api>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      // TODO: 调用后端推荐列表接口，当前占位模拟
      await Future.delayed(const Duration(milliseconds: 300));
      recommendedBooks.assignAll([1,2,3]);
    } catch (e) {
      error.value = '加载推荐失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> addBook(int id) async {
    // TODO: 调用后端添加接口
    recommendedBooks.add(id);
  }

  Future<void> removeBook(int id) async {
    // TODO: 调用后端移除接口
    recommendedBooks.remove(id);
  }
}
