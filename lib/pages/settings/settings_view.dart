import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import '../../services/theme_service.dart';
import '../../services/image_cache_settings_service.dart';
import 'package:system_fonts/system_fonts.dart' as sf;

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DragToMoveArea(child: const Text('设置', style: TextStyle())),
        flexibleSpace:
            Platform.isWindows || Platform.isLinux || Platform.isMacOS
            ? DragToMoveArea(child: Container(color: Colors.transparent))
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('个性化配置'),
          const SizedBox(height: 24),
          _appearanceSection(),
          const SizedBox(height: 24),
          _imageCacheSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

Widget _appearanceSection() {
  final themeService = Get.find<ThemeService>();
  final palette = <Color>[
    Colors.indigo,
    Colors.deepPurple,
    Colors.blue,
    Colors.green,
    Colors.teal,
    Colors.orange,
    Colors.pink,
    Colors.red,
    Colors.brown,
  ];
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('外观', style: Get.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('选择应用主题主色：', style: Get.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final color in palette)
                Obx(
                  () => _colorOption(
                    color,
                    () => themeService.applySeed(color),
                    selected: themeService.seed.value == color,
                  ),
                ),
              _editColorButton(themeService),
            ],
          ),
          const SizedBox(height: 24),
          _themeModeToggles(themeService),
          const SizedBox(height: 32),
          if (GetPlatform.isDesktop) _fontSection(themeService),
        ],
      ),
    ),
  );
}

Widget _colorOption(Color c, VoidCallback onTap, {bool selected = false}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(24),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        boxShadow: [
          if (selected)
            BoxShadow(color: c.withAlpha(140), blurRadius: 8, spreadRadius: 2),
        ],
        border: Border.all(
          color: selected ? Colors.white : c.withAlpha(120),
          width: selected ? 2.4 : 1.2,
        ),
      ),
      child: selected ? const Icon(Icons.check, color: Colors.white) : null,
    ),
  );
}

Widget _imageCacheSection() {
  final svc = Get.find<ImageCacheSettingsService>();
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('图片与缓存', style: Get.textTheme.titleMedium),
          const SizedBox(height: 12),
          Text('图片质量（百分比，数值越高越清晰）：', style: Get.textTheme.bodyMedium),
          Obx(
            () => Slider(
              value: svc.qualityPercent.value.toDouble(),
              min: 10,
              max: 100,
              divisions: 18,
              label: '${svc.qualityPercent.value}%',
              onChanged: (v) => svc.setQualityPercent(v.round()),
            ),
          ),
          const SizedBox(height: 20),
          Text('内存缓存限制 (重启生效)：', style: Get.textTheme.bodyMedium),
          Obx(
            () => Slider(
              value: svc.maxMemoryCacheMb.value.toDouble(),
              min: 50,
              max: 500,
              divisions: 9,
              label: '${svc.maxMemoryCacheMb.value}MB',
              onChanged: (v) => svc.setMaxMemoryCacheMb(v.round()),
            ),
          ),
          const SizedBox(height: 20),
          Text('磁盘缓存占用：', style: Get.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Obx(() {
            final current = svc.diskCacheMb.value;
            return Row(
              children: [
                Expanded(
                  child: Text(
                    '当前 ${current.toStringAsFixed(1)} MB',
                    style: Get.textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  tooltip: '刷新',
                  onPressed: () => svc.refreshDiskCacheSize(),
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  tooltip: '清空磁盘缓存',
                  onPressed: () async {
                    await svc.clearDiskCache();
                    Get.snackbar('缓存', '已清空磁盘缓存');
                  },
                  icon: const Icon(Icons.delete_sweep),
                ),
              ],
            );
          }),
        ],
      ),
    ),
  );
}

Widget _editColorButton(ThemeService service) {
  return Tooltip(
    message: '自定义 RGB 颜色',
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showRgbDialog(service),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Get.theme.colorScheme.outlineVariant,
            width: 1.2,
          ),
        ),
        child: Icon(
          Icons.edit,
          size: 20,
          color: Get.theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ),
  );
}

Future<void> _showRgbDialog(ThemeService service) async {
  int rOf(Color c) => (c.toARGB32() >> 16) & 0xFF;
  int gOf(Color c) => (c.toARGB32() >> 8) & 0xFF;
  int bOf(Color c) => c.toARGB32() & 0xFF;
  final rCtrl = TextEditingController(text: rOf(service.seed.value).toString());
  final gCtrl = TextEditingController(text: gOf(service.seed.value).toString());
  final bCtrl = TextEditingController(text: bOf(service.seed.value).toString());
  Color preview = service.seed.value;
  await showDialog(
    context: Get.context!,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          void updatePreview() {
            final r = int.tryParse(rCtrl.text) ?? rOf(preview);
            final g = int.tryParse(gCtrl.text) ?? gOf(preview);
            final b = int.tryParse(bCtrl.text) ?? bOf(preview);
            setState(() {
              preview = Color.fromARGB(
                255,
                r.clamp(0, 255),
                g.clamp(0, 255),
                b.clamp(0, 255),
              );
            });
          }

          return AlertDialog(
            title: const Text('自定义主色 RGB'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: _rgbField('R', rCtrl, updatePreview)),
                    const SizedBox(width: 8),
                    Expanded(child: _rgbField('G', gCtrl, updatePreview)),
                    const SizedBox(width: 8),
                    Expanded(child: _rgbField('B', bCtrl, updatePreview)),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: preview,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('范围 0-255，实时预览，点击“应用”后生效', style: Get.textTheme.bodySmall),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('取消')),
              FilledButton(
                onPressed: () {
                  service.applySeed(preview);
                  Get.back();
                },
                child: const Text('应用'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _rgbField(
  String label,
  TextEditingController ctrl,
  VoidCallback onChanged,
) {
  return SizedBox(
    width: 70,
    child: TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      onChanged: (_) => onChanged(),
      validator: (v) {
        final value = int.tryParse(v ?? '');
        if (value == null || value < 0 || value > 255) return '0-255';
        return null;
      },
    ),
  );
}

Widget _fontSection(ThemeService service) {
  const common = [
    'system',
    'Arial',
    'Segoe UI',
    'Calibri',
    'Times New Roman',
    'Courier New',
    'Microsoft YaHei',
    'SimSun',
  ];
  return Obx(() {
    final current = service.fontFamily.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('字体', style: Get.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final f in common)
              ChoiceChip(
                label: Text(f == 'system' ? '系统默认' : f),
                selected: f == current,
                onSelected: (_) => service.applyFont(f),
              ),
            _moreFontsButton(service),
          ],
        ),
      ],
    );
  });
}

Widget _moreFontsButton(ThemeService service) {
  return OutlinedButton.icon(
    icon: const Icon(Icons.more_horiz),
    label: const Text('更多...'),
    onPressed: () async {
      List<String> fonts = await service.getInstalledFonts();
      fonts = fonts..sort();
      if (fonts.isEmpty) {
        Get.snackbar('字体', '未能获取系统字体列表');
        return;
      }
      await showDialog(
        context: Get.context!,
        builder: (context) {
          return Dialog(
            child: SizedBox(
              width: 520,
              height: 560,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.font_download),
                        const SizedBox(width: 8),
                        Text('选择字体', style: Get.textTheme.titleLarge),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _FontList(fonts: fonts, service: service),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _themeModeToggles(ThemeService service) {
  return Obx(() {
    final mode = service.mode.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('主题模式', style: Get.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: [
            _modeChip('跟随系统', ThemeMode.system, mode, service),
            _modeChip('浅色', ThemeMode.light, mode, service),
            _modeChip('深色', ThemeMode.dark, mode, service),
          ],
        ),
      ],
    );
  });
}

Widget _modeChip(
  String label,
  ThemeMode value,
  ThemeMode current,
  ThemeService service,
) {
  final selected = value == current;
  return FilterChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => service.setMode(value),
    selectedColor: Get.theme.colorScheme.primaryContainer,
    checkmarkColor: Get.theme.colorScheme.onPrimaryContainer,
  );
}

class _FontList extends StatefulWidget {
  final List<String> fonts;
  final ThemeService service;
  const _FontList({required this.fonts, required this.service});
  @override
  State<_FontList> createState() => _FontListState();
}

class _FontListState extends State<_FontList> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final current = widget.service.fontFamily.value;
    final filtered = widget.fonts
        .where((f) => f.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: '搜索字体...',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final f = filtered[index];
                final selected = f == current;
                return ListTile(
                  title: Text(
                    f,
                    style: TextStyle(fontFamily: selected ? f : null),
                  ),
                  trailing: selected
                      ? Icon(Icons.check, color: Get.theme.colorScheme.primary)
                      : null,
                  onTap: () async {
                    await widget.service.applyFont(f);
                    if (mounted) setState(() {});
                  },
                  onLongPress: () async {
                    await sf.SystemFonts().loadFont(f); // 强制加载以预览
                    if (mounted) setState(() {});
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              TextButton(onPressed: () => Get.back(), child: const Text('关闭')),
              const Spacer(),
              FilledButton(
                onPressed: () => Get.back(),
                child: const Text('完成'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// _themeModeToggles 已废弃，移除未引用方法

// _modeChip 已废弃，移除未引用方法
