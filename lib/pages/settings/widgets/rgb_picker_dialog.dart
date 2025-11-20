import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/theme_service.dart';

class RgbPickerDialog extends StatelessWidget {
  final ThemeService service;

  const RgbPickerDialog({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    int rOf(Color c) => (c.toARGB32() >> 16) & 0xFF;
    int gOf(Color c) => (c.toARGB32() >> 8) & 0xFF;
    int bOf(Color c) => c.toARGB32() & 0xFF;

    final rCtrl = TextEditingController(text: rOf(service.seed.value).toString());
    final gCtrl = TextEditingController(text: gOf(service.seed.value).toString());
    final bCtrl = TextEditingController(text: bOf(service.seed.value).toString());
    
    final previewColor = service.seed.value.obs;

    void updatePreview() {
      final r = int.tryParse(rCtrl.text) ?? rOf(previewColor.value);
      final g = int.tryParse(gCtrl.text) ?? gOf(previewColor.value);
      final b = int.tryParse(bCtrl.text) ?? bOf(previewColor.value);
      previewColor.value = Color.fromARGB(
        255,
        r.clamp(0, 255),
        g.clamp(0, 255),
        b.clamp(0, 255),
      );
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
              Obx(() => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: previewColor.value,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
              )),
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
            service.applySeed(previewColor.value);
            Get.back();
          },
          child: const Text('应用'),
        ),
      ],
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
}
