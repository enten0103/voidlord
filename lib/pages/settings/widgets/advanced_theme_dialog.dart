import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/theme_service.dart';

class AdvancedThemeDialog extends StatelessWidget {
  final ThemeService service;

  const AdvancedThemeDialog({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final keys = ['primary', 'secondary', 'tertiary', 'surface', 'error'];
    final labels = {
      'primary': '主要颜色 (Primary)',
      'secondary': '次要颜色 (Secondary)',
      'tertiary': '第三颜色 (Tertiary)',
      'surface': '表面颜色 (Surface)',
      'error': '错误颜色 (Error)',
    };

    return AlertDialog(
      title: const Text('高级主题设置'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('在此处自定义特定角色的颜色。未设置的颜色将根据主色自动生成。'),
              const SizedBox(height: 16),
              for (final key in keys)
                _ColorRow(label: labels[key]!, colorKey: key, service: service),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            service.clearCustomColors();
          },
          child: const Text('重置所有'),
        ),
        FilledButton(onPressed: () => Get.back(), child: const Text('完成')),
      ],
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final String colorKey;
  final ThemeService service;

  const _ColorRow({
    required this.label,
    required this.colorKey,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Obx(() {
                  final hasCustom = service.customColors.containsKey(colorKey);
                  return Text(
                    hasCustom ? '已自定义' : '自动生成',
                    style: TextStyle(
                      fontSize: 12,
                      color: hasCustom
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(() {
            final customValue = service.customColors[colorKey];
            Color displayColor;
            if (customValue != null) {
              displayColor = Color(customValue);
            } else {
              // Try to get from current scheme
              final scheme = Theme.of(context).colorScheme;
              switch (colorKey) {
                case 'primary':
                  displayColor = scheme.primary;
                  break;
                case 'secondary':
                  displayColor = scheme.secondary;
                  break;
                case 'tertiary':
                  displayColor = scheme.tertiary;
                  break;
                case 'surface':
                  displayColor = scheme.surface;
                  break;
                case 'error':
                  displayColor = scheme.error;
                  break;
                default:
                  displayColor = Colors.grey;
              }
            }

            return InkWell(
              onTap: () => _pickColor(context, displayColor),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: displayColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withAlpha(100)),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: '重置此项',
            onPressed: () => service.setCustomColor(colorKey, null),
          ),
        ],
      ),
    );
  }

  void _pickColor(BuildContext context, Color current) {
    showDialog(
      context: context,
      builder: (ctx) => _SimpleColorPicker(
        initialColor: current,
        onColorChanged: (c) => service.setCustomColor(colorKey, c),
      ),
    );
  }
}

class _SimpleColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const _SimpleColorPicker({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<_SimpleColorPicker> createState() => _SimpleColorPickerState();
}

class _SimpleColorPickerState extends State<_SimpleColorPicker> {
  late int r, g, b;

  @override
  void initState() {
    super.initState();
    r = (widget.initialColor.toARGB32() >> 16) & 0xFF;
    g = (widget.initialColor.toARGB32() >> 8) & 0xFF;
    b = widget.initialColor.toARGB32() & 0xFF;
  }

  void _update() {
    widget.onColorChanged(Color.fromARGB(255, r, g, b));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择颜色'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 50,
            width: double.infinity,
            color: Color.fromARGB(255, r, g, b),
          ),
          const SizedBox(height: 16),
          _slider('R', r, (v) {
            r = v;
            _update();
          }, Colors.red),
          _slider('G', g, (v) {
            g = v;
            _update();
          }, Colors.green),
          _slider('B', b, (v) {
            b = v;
            _update();
          }, Colors.blue),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('确定'),
        ),
      ],
    );
  }

  Widget _slider(
    String label,
    int value,
    ValueChanged<int> onChanged,
    Color activeColor,
  ) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 255,
            activeColor: activeColor,
            onChanged: (v) => onChanged(v.toInt()),
          ),
        ),
        SizedBox(width: 30, child: Text('$value')),
      ],
    );
  }
}
