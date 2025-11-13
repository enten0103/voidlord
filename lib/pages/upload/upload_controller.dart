import 'dart:io';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart' as dio; // alias dio
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
          pendingFile.value = File(path);
          SideBanner.info('已选择文件');
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

  Future<void> createBook() async {
    final tags = <TagInput>[];
    for (final f in tagFields) {
      final k = f.keyController.text.trim();
      final v = f.valueController.text.trim();
      if (k.isEmpty || v.isEmpty) continue;
      tags.add(TagInput(key: k, value: v));
    }
    if (tags.isEmpty) {
      SideBanner.warning('请至少添加一个标签');
      return;
    }
    final hasCover = tags.any((t) => t.key.toUpperCase() == 'COVER');
    if (!hasCover) SideBanner.warning('未设置封面标签 COVER，可继续但建议添加');

    creatingBook.value = true;
    try {
      final created = await api.createBook(CreateBookRequest(tags: tags));
      SideBanner.info('创建成功：#${created.id}');
      for (final f in tagFields) {
        f.keyController.clear();
        f.valueController.clear();
      }
    } catch (e) {
      SideBanner.danger('创建失败');
    } finally {
      creatingBook.value = false;
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
  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}
