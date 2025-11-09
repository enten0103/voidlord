import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../widgets/side_baner.dart';
import '../../apis/client.dart';
import '../../apis/files_api.dart';
import 'package:dio/dio.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? selected;
  bool uploading = false;

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
              Text('图书文件上传', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                '当你拥有 BOOK_CREATE / BOOK_UPDATE / BOOK_DELETE 的一级权限时可见本页面。'
                ' 请选择要上传的文件（例如封面图、资料或导入 JSON）。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _fileSelector(),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: (selected != null && !uploading)
                        ? _startUpload
                        : null,
                    icon: const Icon(Icons.cloud_upload),
                    label: Text(uploading ? '上传中...' : '开始上传'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: (selected != null && !uploading)
                        ? () => setState(() => selected = null)
                        : null,
                    icon: const Icon(Icons.close),
                    label: const Text('清除选择'),
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

  Future<void> _startUpload() async {
    if (selected == null) return;
    setState(() => uploading = true);
    try {
      final file = selected!;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });
      final result = await api.uploadMultipart(form);
      if (result.ok) {
        SideBanner.info('上传完成: ${result.key}');
      } else {
        SideBanner.danger('上传失败');
      }
      setState(() => selected = null);
    } catch (e) {
      SideBanner.danger('上传失败');
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }
}
