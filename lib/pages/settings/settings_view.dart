import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';
import 'widgets/appearance_section.dart';
import 'widgets/image_cache_section.dart';
import '../../widgets/draggable_app_bar.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DraggableAppBar(title: const Text('设置', style: TextStyle())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('个性化配置'),
          const SizedBox(height: 24),
          const AppearanceSection(),
          const SizedBox(height: 24),
          const ImageCacheSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
