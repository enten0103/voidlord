import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'recommendations_controller.dart';
import '../../services/media_libraries_service.dart';
import '../../widgets/side_baner.dart';
import '../../models/recommendations_models.dart';
import '../../models/media_library_models.dart';

class RecommendationsPage extends GetView<RecommendationsController> {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final libs = Get.find<MediaLibrariesService>();
    return Obx(() {
      if (controller.loading.value || libs.loading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.error.value != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.error.value!),
              const SizedBox(height: 12),
              FilledButton(onPressed: controller.load, child: const Text('重试')),
            ],
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () async {
          await libs.loadAll();
          await controller.load();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '推荐分区管理',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                // 刷新按钮：重新加载媒体库与分区
                Obx(
                  () => IconButton(
                    tooltip: (controller.loading.value || libs.loading.value)
                        ? '刷新中'
                        : '刷新',
                    icon: const Icon(Icons.refresh),
                    onPressed: (controller.loading.value || libs.loading.value)
                        ? null
                        : () async {
                            await libs.loadAll();
                            await controller.load();
                          },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: controller.creating.value
                      ? null
                      : () async {
                          await showDialog(
                            context: context,
                            builder: (ctx) {
                              final keyCtrl = TextEditingController();
                              final titleCtrl = TextEditingController();
                              final descCtrl = TextEditingController();
                              int? libId = libs.myLibraries.isNotEmpty
                                  ? libs.myLibraries.first.id
                                  : null;
                              return AlertDialog(
                                title: const Text('创建分区'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: keyCtrl,
                                        decoration: const InputDecoration(
                                          labelText: '唯一 Key',
                                        ),
                                      ),
                                      TextField(
                                        controller: titleCtrl,
                                        decoration: const InputDecoration(
                                          labelText: '标题',
                                        ),
                                      ),
                                      TextField(
                                        controller: descCtrl,
                                        decoration: const InputDecoration(
                                          labelText: '描述(可选)',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _createDialogLibraryDropdown(
                                        libs,
                                        (v) => libId = v,
                                        libId,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('取消'),
                                  ),
                                  FilledButton(
                                    onPressed: () async {
                                      if (keyCtrl.text.trim().isEmpty ||
                                          titleCtrl.text.trim().isEmpty ||
                                          libId == null) {
                                        SideBanner.warning('请填写必要字段');
                                        return;
                                      }
                                      await controller.createSection(
                                        keyCtrl.text.trim(),
                                        titleCtrl.text.trim(),
                                        libId!,
                                        description:
                                            descCtrl.text.trim().isNotEmpty
                                            ? descCtrl.text.trim()
                                            : null,
                                      );
                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                      }
                                    },
                                    child: const Text('创建'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('创建分区'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (libs.error.value != null)
              Text(
                '媒体库加载失败: ${libs.error.value}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 12),
            ...controller.visibleSections.map((sec) {
              return Card(
                key: ValueKey(sec.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '[${sec.key}] ',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          Expanded(
                            child: Text(
                              sec.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Switch(
                            value: sec.active,
                            onChanged: controller.saving.value
                                ? null
                                : (v) => controller.toggleActive(sec.id, v),
                          ),
                          IconButton(
                            tooltip: '编辑标题/描述',
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              final titleCtrl = TextEditingController(
                                text: sec.title,
                              );
                              final descCtrl = TextEditingController(
                                text: sec.description ?? '',
                              );
                              await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('编辑分区'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: titleCtrl,
                                        decoration: const InputDecoration(
                                          labelText: '标题',
                                        ),
                                      ),
                                      TextField(
                                        controller: descCtrl,
                                        decoration: const InputDecoration(
                                          labelText: '描述(可选)',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('取消'),
                                    ),
                                    FilledButton(
                                      onPressed: () async {
                                        if (titleCtrl.text.trim().isEmpty) {
                                          SideBanner.warning('标题不可为空');
                                          return;
                                        }
                                        await controller.updateTitleDesc(
                                          sec.id,
                                          titleCtrl.text.trim(),
                                          descCtrl.text.trim().isEmpty
                                              ? null
                                              : descCtrl.text.trim(),
                                        );
                                        if (ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }
                                      },
                                      child: const Text('保存'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: '删除分区',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: controller.saving.value
                                ? null
                                : () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('确认删除'),
                                        content: Text('删除分区 ${sec.title}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('取消'),
                                          ),
                                          FilledButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('删除'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      await controller.deleteSection(sec.id);
                                    }
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _libraryDropdown(context, libs, sec),
                      if (sec.description != null &&
                          sec.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            sec.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
            if (controller.orderDirty.value)
              Row(
                children: [
                  FilledButton(
                    onPressed: controller.saving.value
                        ? null
                        : controller.persistReorder,
                    child: const Text('保存排序'),
                  ),
                  const SizedBox(width: 12),
                  if (controller.saving.value)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
          ],
        ),
      );
    });
  }

  // 创建分区对话框中的库选择，下拉安全处理：若当前选中值不在列表中则置为 null
  Widget _createDialogLibraryDropdown(
    MediaLibrariesService libs,
    ValueChanged<int?> onChanged,
    int? current,
  ) {
    // 可选库包括：系统阅读记录库、虚拟“我上传”库、我的库列表
    final all = <MediaLibraryDto>[
      if (libs.readingRecord.value != null) libs.readingRecord.value!,
      if (libs.virtualMyUploaded.value != null) libs.virtualMyUploaded.value!,
      ...libs.myLibraries,
    ];
    // 去重
    final seen = <int>{};
    final dedup = <MediaLibraryDto>[];
    for (final m in all) {
      if (seen.add(m.id)) dedup.add(m);
    }
    final ids = dedup.map((e) => e.id).toSet();
    final safeValue = (current != null && ids.contains(current)) ? current : null;
    final items = dedup
        .map(
          (e) => DropdownMenuItem<int>(
            value: e.id,
            child: Text(e.name, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList();
    if (items.isEmpty) {
      // 提示用户需要先创建媒体库
      items.add(const DropdownMenuItem<int>(value: null, child: Text('暂无媒体库')));
    }
    return DropdownButtonFormField<int>(
      initialValue: safeValue,
      decoration: const InputDecoration(labelText: '媒体库'),
      items: items,
      onChanged: onChanged,
    );
  }

  // 列表中分区关联库选择，若库被删除则显示占位并允许重新选择
  Widget _libraryDropdown(
    BuildContext context,
    MediaLibrariesService libs,
    RecommendationSectionDto sec,
  ) {
    // 汇总可选库（含系统/虚拟）
    final all = <MediaLibraryDto>[
      if (libs.readingRecord.value != null) libs.readingRecord.value!,
      if (libs.virtualMyUploaded.value != null) libs.virtualMyUploaded.value!,
      ...libs.myLibraries,
    ];
    final seen = <int>{};
    final dedup = <MediaLibraryDto>[];
    for (final m in all) {
      if (seen.add(m.id)) dedup.add(m);
    }
    final exists = dedup.any((e) => e.id == sec.mediaLibraryId);
    final items = dedup
        .map(
          (lib) => DropdownMenuItem<int>(
            value: lib.id,
            child: Text(lib.name, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList();
    if (!exists && sec.mediaLibraryId > 0) {
      // 外部开放库（不在我的列表中），保留其当前选项
      items.insert(
        0,
        DropdownMenuItem<int>(
          value: sec.mediaLibraryId,
          child: Text(
            '外部开放库: ${sec.mediaLibraryName ?? sec.mediaLibraryId}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
    if (items.isEmpty) {
      items.add(const DropdownMenuItem<int>(value: null, child: Text('暂无媒体库')));
    }
    return DropdownButtonFormField<int>(
      initialValue: sec.mediaLibraryId > 0 ? sec.mediaLibraryId : null,
      isExpanded: true,
      decoration: const InputDecoration(labelText: '关联媒体库'),
      items: items,
      onChanged: controller.saving.value
          ? null
          : (val) {
              if (val != null && val != sec.mediaLibraryId) {
                controller.changeLibrary(sec.id, val);
              }
            },
    );
  }
}
