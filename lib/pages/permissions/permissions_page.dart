import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/models/permission_models.dart';
import 'package:voidlord/pages/permissions/permissions_controller.dart';
import 'package:voidlord/services/permission_service.dart';
import 'package:voidlord/widgets/side_baner.dart';

// 新的批量权限编辑控制器

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.find<PermissionService>().canManagePermissions.value) {
      return Center(
        child: Text(
          '无权限访问 (需要任意权限 level ≥3)',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return GetBuilder<PermissionsController>(
      autoRemove: false,
      builder: (c) => Obx(() {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              // 使用 stretch 让子组件（Card 等）占满可用宽度，保证等宽
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('权限管理', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                _myPermissionsCard(context, c),
                const SizedBox(height: 20),
                _targetUserInputCard(context, c),
                const SizedBox(height: 20),
                if (c.targetUserId.value != null) _batchEditorCard(context, c),
              ],
            ),
          ),
          floatingActionButton: c.targetUserId.value != null
              ? FloatingActionButton.extended(
                  onPressed: c.applying.value || !c.hasChanges.value
                      ? null
                      : c.applyChanges,
                  icon: c.applying.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    c.applying.value
                        ? '提交中...'
                        : c.hasChanges.value
                        ? '提交变更'
                        : '无变更',
                  ),
                )
              : null,
        );
      }),
    );
  }

  Widget _myPermissionsCard(BuildContext context, PermissionsController c) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('我的权限', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (c.myPermissions.isEmpty)
              const Text('无权限')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: c.myPermissions
                    .map(
                      (e) => Chip(
                        label: Text('${e.permission}=${e.level}'),
                        avatar: CircleAvatar(
                          backgroundColor: _levelColor(e.level),
                          child: Text(
                            e.level.toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _targetUserInputCard(
    BuildContext context,
    PermissionsController controller,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('目标用户', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: controller.targetUserIdCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '用户ID',
                prefixIcon: Icon(Icons.person_search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () {
                    final id = int.tryParse(
                      controller.targetUserIdCtrl.text.trim(),
                    );
                    if (id == null || id <= 0) {
                      SideBanner.warning('请输入有效的用户ID');
                      return;
                    }
                    controller.targetUserId.value = id;
                    controller.loadTarget(id);
                  },
                  icon: const Icon(Icons.download),
                  label: Text(
                    controller.targetLoading.value ? '加载中...' : '加载权限',
                  ),
                ),
                const SizedBox(width: 16),
                if (controller.targetLoading.value)
                  const CircularProgressIndicator(),
                if (controller.error.value != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      controller.error.value!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _batchEditorCard(BuildContext context, PermissionsController c) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '批量编辑权限 (用户 #${c.targetUserId.value})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (c.targetLoading.value)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: PermissionName.all.map((p) {
                  final current = c.targetLevels[p] ?? 0;
                  final draft = c.draftLevels[p] ?? 0;
                  final changed = current != draft;
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: changed ? Colors.amber : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _levelColor(draft),
                        child: Text(
                          draft.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text(p),
                      subtitle: Text('当前: $current  → 草稿: $draft'),
                      trailing: _levelSelector(context, c, p, draft),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: c.hasChanges.value && !c.applying.value
                      ? c.applyChanges
                      : null,
                  icon: const Icon(Icons.save_alt),
                  label: Text(
                    c.applying.value
                        ? '提交中...'
                        : c.hasChanges.value
                        ? '提交变更'
                        : '无变更',
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: c.applying.value
                      ? null
                      : () {
                          c.resetDraftFromTarget(); // 使用深拷贝还原
                        },
                  icon: const Icon(Icons.refresh),
                  label: const Text('还原'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: c.applying.value
                      ? null
                      : () {
                          for (final p in PermissionName.all) {
                            c.setDraft(p, 0); // 全部撤销
                          }
                        },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('全部设为0'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _levelSelector(
    BuildContext context,
    PermissionsController c,
    String perm,
    int draft,
  ) {
    return Wrap(
      spacing: 4,
      children: List.generate(4, (i) {
        final selected = draft == i;
        return ChoiceChip(
          label: Text(i.toString()),
          selected: selected,
          onSelected: (_) => c.setDraft(perm, i),
          selectedColor: _levelColor(i),
        );
      }),
    );
  }

  static Color _levelColor(int level) {
    switch (level) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}
