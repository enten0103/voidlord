import 'package:get/get.dart';
import '../../apis/client.dart';
import '../../apis/books_api.dart';
import '../../models/book_models.dart';
import '../../widgets/side_baner.dart';
import '../../services/media_libraries_service.dart';

class BookDetailController extends GetxController {
  final loading = false.obs;
  final deleting = false.obs;
  final error = RxnString();
  final book = Rxn<BookDto>();

  Api get api => Get.find<Api>();

  int? bookId;

  @override
  void onInit() {
    super.onInit();
    // 确保媒体库服务已初始化（收藏操作依赖）
    try {
      final libs = Get.find<MediaLibrariesService>();
      libs.ensureInitialized();
    } catch (_) {}
    int? id;
    final paramId = Get.parameters['id'];
    if (paramId != null) id = int.tryParse(paramId);
    if (id == null && Get.arguments is int) id = Get.arguments as int;
    if (id == null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['id'] is int) id = args['id'] as int;
    }
    bookId = id;
    if (bookId != null) {
      load();
    } else {
      error.value = '未提供图书 ID';
    }
  }

  Future<void> load() async {
    if (bookId == null) return;
    loading.value = true;
    error.value = null;
    try {
      final data = await api.getBook(bookId!);
      book.value = data;
    } catch (e) {
      error.value = '加载失败';
    } finally {
      loading.value = false;
    }
  }

  Future<void> deleteCurrent() async {
    if (bookId == null) return;
    deleting.value = true;
    try {
      final ok = await api.deleteBook(bookId!);
      if (ok) {
        SideBanner.info('已删除图书 #$bookId');
        Get.back(result: true);
      } else {
        SideBanner.danger('删除失败');
      }
    } catch (e) {
      SideBanner.danger('删除异常');
    } finally {
      deleting.value = false;
    }
  }
}
