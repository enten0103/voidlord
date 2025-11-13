import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'media_libraries_controller.dart';
import '../../models/media_library_models.dart';

class MediaLibrariesPage extends GetView<MediaLibrariesController> {
  const MediaLibrariesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(
        onRefresh: () => controller.service.loadAll(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle(context, '固定媒体库'),
            const SizedBox(height: 8),
            _fixedLibraryCard(context, controller.readingRecord.value, '阅读记录库'),
            _fixedLibraryCard(context, controller.virtualMyUploaded.value, '我的上传 (虚拟库)', virtual: true),
            const SizedBox(height: 24),
            _sectionTitle(context, '我的媒体库'),
            const SizedBox(height: 8),
            if (controller.myLibraries.isEmpty)
              Text('暂无自定义媒体库', style: Theme.of(context).textTheme.bodySmall)
            else
              ...controller.myLibraries.map((lib) => _libraryCard(context, lib)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: controller.creating.value ? null : () => _showCreateDialog(context),
              icon: const Icon(Icons.add_box),
              label: Text(controller.creating.value ? '创建中...' : '新建媒体库'),
            ),
          ],
        ),
      );
    });
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(title, style: Theme.of(context).textTheme.titleMedium);

  Widget _fixedLibraryCard(BuildContext context, MediaLibraryDto? lib, String label,{bool virtual=false}) {
    if (lib == null) {
      return Card(
        child: ListTile(
          title: Text(label),
          subtitle: const Text('加载中或不可用'),
        ),
      );
    }
    return Card(
      child: ListTile(
        title: Text(lib.name),
        subtitle: Text('${lib.itemsCount} 条目${virtual ? ' • 虚拟' : ''}'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _openLibraryDetail(context, lib),
      ),
    );
  }

  Widget _libraryCard(BuildContext context, MediaLibraryDto lib) {
    return Card(
      child: ListTile(
        title: Text(lib.name),
        subtitle: Text('${lib.itemsCount} 条目${lib.isPublic ? ' • 公开' : ''}'),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              tooltip: '打开',
              icon: const Icon(Icons.folder_open),
              onPressed: () => _openLibraryDetail(context, lib),
            ),
            IconButton(
              tooltip: '编辑',
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, lib),
            ),
            IconButton(
              tooltip: '删除',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(context, lib),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isPublic = false;
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建媒体库'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: '名称'),
                validator: (v) => (v == null || v.trim().isEmpty) ? '请输入名称' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: '描述'),
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) => CheckboxListTile(
                  value: isPublic,
                  onChanged: (v) => setState(() => isPublic = v ?? false),
                  title: const Text('公开媒体库'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx,false), child: const Text('取消')),
          FilledButton(onPressed: () { if(formKey.currentState!.validate()) Navigator.pop(ctx,true); }, child: const Text('创建')),
        ],
      ),
    );
    if (ok == true) {
      await controller.createLibrary(nameCtrl.text.trim(), description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(), isPublic: isPublic);
    }
  }

  Future<void> _showEditDialog(BuildContext context, MediaLibraryDto lib) async {
    final nameCtrl = TextEditingController(text: lib.name);
    final descCtrl = TextEditingController(text: lib.description ?? '');
    bool isPublic = lib.isPublic;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('编辑媒体库 #${lib.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '名称')),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: '描述')),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) => CheckboxListTile(
                value: isPublic,
                onChanged: lib.isSystem ? null : (v) => setState(() => isPublic = v ?? false),
                title: const Text('公开媒体库'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            if (lib.isSystem) const Text('系统库部分属性已锁定', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx,false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx,true), child: const Text('保存')),
        ],
      ),
    );
    if (ok == true) {
      await controller.service.updateLibrary(lib.id, UpdateLibraryRequest(
        name: nameCtrl.text.trim() == lib.name ? null : nameCtrl.text.trim(),
        description: descCtrl.text.trim() == (lib.description ?? '') ? null : descCtrl.text.trim(),
        isPublic: isPublic == lib.isPublic ? null : isPublic,
      ));
    }
  }

  Future<void> _confirmDelete(BuildContext context, MediaLibraryDto lib) async {
    if (lib.isSystem || lib.isVirtual) return; // 保护
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('删除媒体库 "${lib.name}"?'),
        content: const Text('此操作不可撤销，将删除媒体库及其条目。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx,false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(ctx,true), child: const Text('确认删除')),
        ],
      ),
    );
    if (ok == true) {
      await controller.deleteLibrary(lib.id);
    }
  }

  void _openLibraryDetail(BuildContext context, MediaLibraryDto lib) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(lib.name, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ],
              ),
              Text('${lib.itemsCount} 条目', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scroll,
                  itemCount: lib.items.length,
                  itemBuilder: (context, i) {
                    final item = lib.items[i];
                    return ListTile(
                      title: Text(item.book != null ? '书籍 #${item.book!.id}' : '子库 #${item.childLibrary!.id}'),
                      subtitle: item.childLibrary?.name != null ? Text(item.childLibrary!.name!) : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
