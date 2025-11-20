import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/theme_service.dart';
import 'rgb_picker_dialog.dart';
import 'font_list_dialog.dart';

class AppearanceSection extends StatelessWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              BoxShadow(
                color: c.withAlpha(140),
                blurRadius: 8,
                spreadRadius: 2,
              ),
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

  Widget _editColorButton(ThemeService service) {
    return Tooltip(
      message: '自定义 RGB 颜色',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => showDialog(
          context: Get.context!,
          builder: (context) => RgbPickerDialog(service: service),
        ),
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
          builder: (context) => FontListDialog(fonts: fonts, service: service),
        );
      },
    );
  }
}
