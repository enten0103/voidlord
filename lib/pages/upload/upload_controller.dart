import 'dart:io';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart' as dio; // alias dio
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import '../../apis/client.dart';
import '../../apis/files_api.dart';
import '../../apis/books_api.dart';
import '../../models/book_models.dart';
import '../../models/file_models.dart';
import '../../widgets/side_baner.dart';

class UploadController extends GetxController {
  final pendingFile = Rx<File?>(null);
  final uploadingMedia = false.obs;
  final creatingBook = false.obs;
  final customKeyController = TextEditingController();

  final uploadedItems = <UploadResultDto>[].obs;
  final tagFields = <_TagField>[].obs;

  Api get api => Get.find<Api>();

  int? editingBookId; // 若存在则处于编辑模式
  final editing = false.obs;
  final initialLoading = false.obs;

  void addTagRow() => tagFields.add(_TagField());
  void removeTagRow(int index) {
    if (index < 0 || index >= tagFields.length) return;
    final f = tagFields.removeAt(index);
    f.dispose();
  }

  void clearTags() {
    for (final f in tagFields) {
      f.keyController.clear();
      f.valueController.clear();
    }
  }

  void ensureTag(String key, String value) {
    for (final f in tagFields) {
      if (f.keyController.text.trim().toUpperCase() == key.toUpperCase()) {
        f.valueController.text = value;
        return;
      }
    }
    final f = _TagField();
    f.keyController.text = key;
    f.valueController.text = value;
    tagFields.add(f);
  }

  Future<void> pickFile() async {
    if (uploadingMedia.value) return;
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          final file = File(path);
          pendingFile.value = file;
          SideBanner.info('已选择文件');

          if (path.toLowerCase().endsWith('.epub')) {
            try {
              final stream = file.openRead();
              final digest = await md5.bind(stream).first;
              customKeyController.text = digest.toString();
              SideBanner.info('已自动填充 MD5 为 key');
            } catch (e) {
              // ignore
            }
          }
        }
      }
    } catch (e) {
      SideBanner.danger('选择文件失败');
    }
  }

  Future<void> uploadMediaFile() async {
    final file = pendingFile.value;
    if (file == null) {
      SideBanner.warning('请先选择文件');
      return;
    }
    uploadingMedia.value = true;
    try {
      final form = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path),
        if (customKeyController.text.trim().isNotEmpty)
          'key': customKeyController.text.trim(),
      });
      final result = await api.uploadMultipart(form);
      if (result.ok) {
        uploadedItems.insert(0, result);
        pendingFile.value = null;
        customKeyController.clear();
        SideBanner.info('上传成功');
      } else {
        SideBanner.danger('上传失败');
      }
    } catch (e) {
      SideBanner.danger('上传异常');
    } finally {
      uploadingMedia.value = false;
    }
  }

  Future<void> createOrUpdateBook() async {
    final tags = <TagInput>[];
    for (final f in tagFields) {
      final k = f.keyController.text.trim();
      final v = f.valueController.text.trim();
      if (k.isEmpty || v.isEmpty) continue;
      tags.add(TagInput(key: k, value: v, shown: f.shown.value));
    }
    if (tags.isEmpty) {
      SideBanner.warning('请至少添加一个标签');
      return;
    }
    final hasCover = tags.any((t) => t.key.toUpperCase() == 'COVER');
    if (!hasCover) SideBanner.warning('未设置封面标签 COVER，可继续但建议添加');

    creatingBook.value = true;
    try {
      if (editing.value && editingBookId != null) {
        final updated = await api.updateBook(
          editingBookId!,
          UpdateBookRequest(tags: tags),
        );
        SideBanner.info('更新成功：#${updated.id}');
      } else {
        final created = await api.createBook(CreateBookRequest(tags: tags));
        SideBanner.info('创建成功：#${created.id}');
        for (final f in tagFields) {
          f.keyController.clear();
          f.valueController.clear();
        }
      }
    } catch (e) {
      SideBanner.danger(editing.value ? '更新失败' : '创建失败');
    } finally {
      creatingBook.value = false;
    }
  }

  Future<void> loadExisting(int id) async {
    editingBookId = id;
    editing.value = true;
    initialLoading.value = true;
    try {
      final book = await api.getBook(id);
      // 清理现有
      for (final f in tagFields) {
        f.dispose();
      }
      tagFields.clear();
      for (final t in book.tags) {
        final f = _TagField();
        f.keyController.text = t.key;
        f.valueController.text = t.value;
        // 从后端加载标签显示状态
        f.shown.value = t.shown;
        tagFields.add(f);
      }
    } catch (e) {
      SideBanner.danger('加载图书失败');
    } finally {
      initialLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    int? id;
    final paramId = Get.parameters['id'];
    if (paramId != null) {
      id = int.tryParse(paramId);
    }
    if (id == null && Get.arguments is int) {
      id = Get.arguments as int;
    } else if (id == null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['id'] is int) id = args['id'] as int;
    }
    if (id != null) {
      loadExisting(id);
    }
  }

  @override
  void onClose() {
    customKeyController.dispose();
    for (final f in tagFields) {
      f.dispose();
    }
    super.onClose();
  }
}

class _TagField {
  final TextEditingController keyController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final RxBool shown = true.obs; // 默认显示
  void dispose() {
    keyController.dispose();
    valueController.dispose();
    shown.close();
  }
}
