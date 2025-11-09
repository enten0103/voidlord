import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/side_baner.dart';
import '../../apis/client.dart';
import '../../apis/files_api.dart';
import '../../apis/books_api.dart';
import '../../models/book_models.dart';
import 'package:dio/dio.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? selected;
  bool uploading = false;
  final List<_TagField> _tagFields = [];

  @override
  void dispose() {
    for (final f in _tagFields) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('图书上传', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                '当你拥有 BOOK_CREATE / BOOK_UPDATE / BOOK_DELETE 的一级权限时可见本页面。\n'
                ' 提示：本系统中图书的所有属性均以标签（tag）形式存储；封面使用标签名 "COVER" 存放对象存储的 key。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _fileSelector(),
              const SizedBox(height: 16),
              _tagsEditor(),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: (selected != null && !uploading)
                        ? _createBook
                        : null,
                    icon: const Icon(Icons.library_add),
                    label: Text(uploading ? '处理中...' : '创建图书'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: (selected != null && !uploading)
                        ? () => setState(() => selected = null)
                        : null,
                    icon: const Icon(Icons.close),
                    label: const Text('清除选择'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: uploading
                        ? null
                        : () {
                            for (final f in _tagFields) {
                              f.keyController.clear();
                              f.valueController.clear();
                            }
                            SideBanner.info('已清空标签输入');
                          },
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('清空标签'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fileSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('选择文件', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (selected == null) ...[
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('选择文件'),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selected!.path.split(Platform.pathSeparator).last,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: '重新选择',
                    onPressed: uploading ? null : _pickFile,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withReadStream: false);
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          setState(() => selected = File(path));
          SideBanner.info('已选择文件');
        }
      }
    } catch (e) {
      SideBanner.danger('选择文件失败');
    }
  }

  Widget _tagsEditor() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('图书标签', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: uploading ? null : _addTagRow,
                  icon: const Icon(Icons.add),
                  label: const Text('添加标签'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_tagFields.isEmpty)
              Text(
                '提示：可添加任意标签（key/value）。封面将自动使用标签名 "COVER" 写入上传后的对象 key。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            for (int i = 0; i < _tagFields.length; i++) _tagRow(i),
          ],
        ),
      ),
    );
  }

  void _addTagRow() {
    setState(() {
      _tagFields.add(_TagField());
    });
  }

  Widget _tagRow(int index) {
    final f = _tagFields[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: TextField(
              controller: f.keyController,
              enabled: !uploading,
              decoration: const InputDecoration(
                labelText: 'Key',
                hintText: '例如 author / genre',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: TextField(
              controller: f.valueController,
              enabled: !uploading,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: '例如 刘慈欣 / 科幻',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: '删除',
            onPressed: uploading
                ? null
                : () {
                    setState(() {
                      final removed = _tagFields.removeAt(index);
                      removed.dispose();
                    });
                  },
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }

  Future<void> _createBook() async {
    if (selected == null) {
      SideBanner.warning('请先选择封面文件');
      return;
    }
    setState(() => uploading = true);
    try {
      // 1) 先上传封面文件
      final file = selected!;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final result = await api.uploadMultipart(form);
      if (!result.ok) {
        SideBanner.danger('封面上传失败');
        return;
      }

      // 2) 收集标签，并写入 COVER 标签为对象 key
      final tags = <TagInput>[];
      for (final f in _tagFields) {
        final k = f.keyController.text.trim();
        final v = f.valueController.text.trim();
        if (k.isEmpty || v.isEmpty) continue;
        if (k.toUpperCase() == 'COVER') continue; // 避免用户手动覆盖
        tags.add(TagInput(key: k, value: v));
      }
      tags.add(TagInput(key: 'COVER', value: result.key));

      // 3) 创建图书
      final created = await api.createBook(CreateBookRequest(tags: tags));
      SideBanner.info('创建成功：#${created.id}');

      // 4) 重置界面
      setState(() {
        selected = null;
        for (final f in _tagFields) {
          f.keyController.clear();
          f.valueController.clear();
        }
      });
    } catch (e) {
      SideBanner.danger('创建失败');
    } finally {
      if (mounted) setState(() => uploading = false);
    }
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
