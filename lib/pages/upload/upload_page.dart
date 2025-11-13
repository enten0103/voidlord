import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../widgets/side_baner.dart';
import '../../models/file_models.dart';
import 'upload_controller.dart';

/// 图书上传页面：媒体文件上传与标签创建分离。
/// 宽屏 (>=1000)：左右两列；窄屏：Tab 切换。
/// 流程：先上传媒体获取 key，再用标签创建图书；封面标签为 COVER。
class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UploadController>(
      init: UploadController(),
      builder: (controller) => Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('图书上传', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(
                  '流程：1) 上传媒体获取 key  2) 添加标签 (封面=COVER) 创建图书',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 800;
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _mediaCard(context, controller)),
                          const SizedBox(width: 24),
                          Expanded(child: _tagsCard(context, controller)),
                        ],
                      );
                    }
                    return DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(text: '媒体文件'),
                              Tab(text: '标签与创建'),
                            ],
                          ),
                          SizedBox(
                            height: 720,
                            child: TabBarView(
                              children: [
                                SingleChildScrollView(
                                  child: _mediaCard(context, controller),
                                ),
                                SingleChildScrollView(
                                  child: _tagsCard(context, controller),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mediaCard(BuildContext context, UploadController c) {
    return Obx(
      () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('媒体文件', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: c.uploadingMedia.value ? null : c.pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(c.pendingFile.value == null ? '选择文件' : '更换文件'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (c.pendingFile.value != null) ...[
                Text(
                  c.pendingFile.value!.path.split(Platform.pathSeparator).last,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: c.customKeyController,
                  enabled: !c.uploadingMedia.value,
                  decoration: const InputDecoration(
                    labelText: '自定义对象 key (可选)',
                    hintText: '例如 covers/book-123.jpg',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: c.uploadingMedia.value ? null : c.uploadMediaFile,
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(c.uploadingMedia.value ? '上传中...' : '上传'),
                ),
              ] else ...[
                Text('未选择文件', style: Theme.of(context).textTheme.bodySmall),
              ],
              const Divider(height: 32),
              Text('已上传文件', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (c.uploadedItems.isEmpty)
                Text('暂无', style: Theme.of(context).textTheme.bodySmall)
              else
                Column(
                  children: c.uploadedItems
                      .map((r) => _uploadedItemTile(r, c))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadedItemTile(UploadResultDto r, UploadController c) {
    return ListTile(
      dense: true,
      title: Text(r.key, overflow: TextOverflow.ellipsis),
      subtitle: Text('${r.size} bytes${r.mime != null ? ' • ${r.mime}' : ''}'),
      trailing: Wrap(
        spacing: 8,
        children: [
          IconButton(
            tooltip: '复制 key',
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: r.key));
              SideBanner.info('已复制 key');
            },
          ),
          IconButton(
            tooltip: '设为 COVER',
            icon: const Icon(Icons.image),
            onPressed: c.creatingBook.value
                ? null
                : () {
                    c.ensureTag('COVER', r.key);
                    SideBanner.info('已设置 COVER 标签');
                  },
          ),
        ],
      ),
    );
  }

  Widget _tagsCard(BuildContext context, UploadController c) {
    return Obx(
      () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('标签与创建', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: c.creatingBook.value ? null : c.addTagRow,
                    icon: const Icon(Icons.add),
                    label: const Text('添加标签'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: c.creatingBook.value
                        ? null
                        : () {
                            c.clearTags();
                            SideBanner.info('已清空标签输入');
                          },
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('清空'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (c.tagFields.isEmpty)
                Text(
                  '提示：封面标签=COVER；示例：AUTHOR=刘慈欣、GENRE=科幻',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              for (int i = 0; i < c.tagFields.length; i++) _tagRow(i, c),
              const Divider(height: 32),
              FilledButton.icon(
                onPressed: c.creatingBook.value ? null : c.createBook,
                icon: const Icon(Icons.library_add),
                label: Text(c.creatingBook.value ? '创建中...' : '创建图书'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagRow(int index, UploadController c) {
    final f = c.tagFields[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Flexible(
            flex: 2,
            child: TextField(
              controller: f.keyController,
              enabled: !c.creatingBook.value,
              decoration: const InputDecoration(
                labelText: 'Key',
                hintText: '例如 COVER / AUTHOR',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 3,
            child: TextField(
              controller: f.valueController,
              enabled: !c.creatingBook.value,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: '例如 刘慈欣 / 科幻',
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: '删除',
            onPressed: c.creatingBook.value
                ? null
                : () {
                    c.removeTagRow(index);
                  },
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }
}
