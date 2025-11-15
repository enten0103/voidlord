import 'package:get/get.dart';
import '../../services/media_libraries_service.dart';
import '../../models/media_library_models.dart';

class MediaLibrariesController extends GetxController {
  late final MediaLibrariesService service;
  final creating = false.obs;

  @override
  void onInit() {
    super.onInit();
    service = Get.find<MediaLibrariesService>();
    // 使用统一初始化保障，避免重复完整加载
    service.ensureInitialized();
  }

  RxList<MediaLibraryDto> get myLibraries => service.myLibraries;
  Rxn<MediaLibraryDto> get readingRecord => service.readingRecord;
  Rxn<MediaLibraryDto> get virtualMyUploaded => service.virtualMyUploaded;
  RxBool get loading => service.loading;
  RxnString get error => service.error;

  Future<void> createLibrary(
    String name, {
    String? description,
    bool isPublic = false,
  }) async {
    creating.value = true;
    await service.createLibrary(
      name,
      description: description,
      isPublic: isPublic,
    );
    creating.value = false;
  }

  Future<void> deleteLibrary(int id) async => service.deleteLibrary(id);
}
