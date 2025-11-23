import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/apis/client.dart';
import 'package:voidlord/apis/permission_api.dart';
import 'package:voidlord/models/permission_models.dart';
import 'package:voidlord/widgets/side_baner.dart';

class PermissionsController extends GetxController {
  final myPermissions = <UserPermissionEntry>[].obs; // 当前操作者自己的权限（顶部展示）
  final targetUserIdCtrl = TextEditingController(); // 输入目标用户ID
  final targetUserId = RxnInt();
  final targetLoading = false.obs; // 正在加载目标用户权限
  final applying = false.obs; // 正在提交批量变更
  final error = RxnString();

  // 目标用户现有权限 (permission -> level)
  final targetLevels = <String, int>{}.obs; // 独立 RxMap
  // 目标用户期望权限 (UI 编辑中的草稿 level，0 表示撤销)
  final draftLevels = <String, int>{}.obs; // 独立 RxMap（深拷贝初始化）
  // 手动差异标记：每次修改或加载后重新计算
  final hasChanges = false.obs;

  Api get api => Get.find<Api>();

  Future<void> refreshData() async {
    await loadMine();
    if (targetUserId.value != null) {
      await loadTarget(targetUserId.value!);
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadMine();
    // 当输入框变化时尝试解析 userId（简单监听，回车或按钮也可触发）
    targetUserIdCtrl.addListener(onUserIdChanged);
    // 恢复响应式监听：任一 Map 变化时自动计算差异
    ever<Map<String, int>>(draftLevels, (_) => _computeHasChanges());
    ever<Map<String, int>>(targetLevels, (_) => _computeHasChanges());
  }

  void onUserIdChanged() {
    final id = int.tryParse(targetUserIdCtrl.text.trim());
    if (id != null && id > 0 && id != targetUserId.value) {
      targetUserId.value = id;
      loadTarget(id);
    }
  }

  Future<void> loadMine() async {
    try {
      myPermissions.assignAll(await api.listMyPermissions());
    } catch (_) {
      /* 忽略 */
    }
  }

  Future<void> loadTarget(int userId) async {
    targetLoading.value = true;
    error.value = null;
    try {
      final list = await api.listUserPermissions(userId);
      final map = <String, int>{};
      for (final e in list) {
        map[e.permission] = e.level;
      }
      targetLevels.assignAll(map); // 更新目标
      resetDraftFromTarget(); // 以目标深拷贝初始化草稿
    } on PermissionApiError catch (e) {
      error.value = e.message;
    } catch (_) {
      error.value = '加载目标用户权限失败';
    } finally {
      targetLoading.value = false;
    }
  }

  // 深拷贝目标权限到草稿，确保后续修改不会影响 targetLevels
  void resetDraftFromTarget() {
    draftLevels.clear();
    for (final entry in targetLevels.entries) {
      draftLevels[entry.key] = entry.value; // 拷贝值
    }
    // 补齐所有已定义权限键，缺失设为 0
    for (final p in PermissionName.all) {
      draftLevels.putIfAbsent(p, () => 0);
      targetLevels.putIfAbsent(p, () => targetLevels[p] ?? 0);
    }
    draftLevels.refresh(); // 触发 draftLevels 改变事件
  }

  void _computeHasChanges() {
    for (final p in PermissionName.all) {
      final draft = draftLevels[p] ?? 0;
      final current = targetLevels[p] ?? 0;
      if (draft != current) {
        hasChanges.value = true;
        return;
      }
    }
    hasChanges.value = false;
  }

  void setDraft(String permission, int level) {
    if (level < 0 || level > 3) return;
    draftLevels[permission] = level;
    draftLevels.refresh();
  }

  Future<void> applyChanges() async {
    final uid = targetUserId.value;
    if (uid == null || uid <= 0) {
      SideBanner.warning('请先输入有效的用户ID');
      return;
    }
    if (!hasChanges.value) {
      SideBanner.info('没有需要提交的变更');
      return;
    }
    applying.value = true;
    error.value = null;
    int success = 0;
    int fail = 0;
    try {
      for (final p in draftLevels.keys) {
        final desired = draftLevels[p]!;
        final current = targetLevels[p] ?? 0;
        if (desired == current) continue; // 未变化
        try {
          if (desired == 0 && current > 0) {
            final ok = await api.revokePermission(
              RevokePermissionRequest(userId: uid, permission: p),
            );
            if (ok) {
              success++;
            } else {
              fail++;
            }
          } else if (desired > 0) {
            final entry = await api.grantPermission(
              GrantPermissionRequest(
                userId: uid,
                permission: p,
                level: desired,
              ),
            );
            if (entry.level == desired) {
              success++;
            } else {
              fail++;
            }
          }
        } on PermissionApiError {
          fail++;
        } catch (_) {
          fail++;
        }
      }
      SideBanner.info('提交完成：成功 $success / 失败 $fail');
      // 刷新目标权限（重新加载后草稿被重置为当前值）
      await loadTarget(uid);
      // _loadTarget 已进行 _computeHasChanges
    } finally {
      applying.value = false;
    }
  }

  @override
  void onClose() {
    targetUserIdCtrl.dispose();
    super.onClose();
  }
}
