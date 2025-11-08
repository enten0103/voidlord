import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: 56,
          child: const Text('设置', style: TextStyle()),
        ),
        flexibleSpace:
            Platform.isWindows || Platform.isLinux || Platform.isMacOS
            ? DragToMoveArea(child: Container(color: Colors.transparent))
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('设置页面占位，可在此添加应用偏好、通知、隐私等配置。'),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('示例分类', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('· 外观设置（主题、字体大小）'),
                  Text('· 通知偏好'),
                  Text('· 隐私与安全'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
