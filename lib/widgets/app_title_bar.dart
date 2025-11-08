import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Windows 自定义标题栏支持
import 'package:bitsdojo_window/bitsdojo_window.dart';

/// 跨平台标题栏组件：
/// - Windows: 使用自绘无边框窗口 + 拖拽区域 + 系统控制按钮
/// - 其他平台: 退化为标准的 Material AppBar
class AppTitleBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double height;
  final bool centerTitle;

  const AppTitleBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor,
    this.height = 48,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
  if (GetPlatform.isWindows) {
      return WindowTitleBarBox(
        child: Container(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              // 拖拽区域
              Expanded(
                child: MoveWindow(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Align(
                      alignment:
                          centerTitle ? Alignment.center : Alignment.centerLeft,
                      child: Text(
                        title.tr,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              if (actions != null) ...actions!,
              const _WindowButtons(),
            ],
          ),
        ),
      );
    }
    // 默认平台使用标准 AppBar
    return AppBar(
      title: Text(title.tr),
      centerTitle: centerTitle,
      backgroundColor:
          backgroundColor ?? Theme.of(context).colorScheme.surface,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _WindowButtons extends StatelessWidget {
  const _WindowButtons();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.08);
    return Row(
      children: [
        _WindowButton(
          icon: Icons.remove,
          onTap: () => appWindow.minimize(),
          tooltip: 'Minimize',
          hoverColor: hoverColor,
        ),
        _WindowButton(
          icon: Icons.crop_square,
          onTap: () => appWindow.maximizeOrRestore(),
          tooltip: appWindow.isMaximized ? 'Restore' : 'Maximize',
          hoverColor: hoverColor,
        ),
        _WindowButton(
          icon: Icons.close,
          onTap: () => appWindow.close(),
          tooltip: 'Close',
          hoverColor: theme.colorScheme.error.withValues(alpha: 0.15),
          iconColor: theme.colorScheme.error,
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? hoverColor;
  final Color? iconColor;
  const _WindowButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.hoverColor,
    this.iconColor,
  });
  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 46,
            height: double.infinity,
      color: _hover
        ? widget.hoverColor ?? colorScheme.surfaceContainerHighest
        : null,
            child: Icon(
              widget.icon,
              size: 18,
              color: widget.iconColor ?? colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
