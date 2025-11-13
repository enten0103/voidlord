import 'package:get/get.dart';
import '../../apis/client.dart';
import '../../apis/books_api.dart';
import '../../models/book_models.dart';

class UploadListController extends GetxController {
  final loading = false.obs;
  final error = RxnString();
  final books = <BookDto>[].obs;

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
      final list = await api.listMyBooks();
      books.assignAll(list);
    } catch (e) {
      error.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }
}
