import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 侧边提示条出现的位置。
///
/// - [BannerSide.left]: 从屏幕左侧滑入；向左滑动（外侧方向）关闭，向右滑动（内侧方向）固定。
/// - [BannerSide.right]: 从屏幕右侧滑入；向右滑动（外侧方向）关闭，向左滑动（内侧方向）固定。
enum BannerSide { left, right }

/// 侧边提示条的对外入口（静态方法集合）。
///
/// 特性概览：
/// - 使用根 Overlay 显示，不影响页面布局与交互；
/// - 支持左右两侧分别堆叠，支持新消息置顶/置底；
/// - 进入/退出动画平滑，自动消失前会反向动画；
/// - 右侧 Banner 最终“微露出”，便于发现；
/// - 横向滑动：外侧方向关闭，内侧方向固定并取消自动消失；
/// - 文本自动截断，最大宽度不超过半屏；
/// - 若使用 Material 容器色作为背景，会自动匹配 onXContainer 前景色以保证可读性。
class SideBanner {
  SideBanner._();

  /// 显示一个侧边提示条。
  ///
  /// 参数说明：
  /// - [message] 文本内容，将按 [maxChars] 截断并加省略号；
  /// - [side] 出现于左/右侧；
  /// - [duration] 自动消失前的停留时长；
  /// - [icon] 左侧图标；
  /// - [color] 背景色（容器色将自动匹配对应 onXContainer 前景色）；
  /// - [context] 可选上下文；缺省时尝试从 Get.overlayContext 或 Get.context；
  /// - [newestOnTop] 新消息是否置顶；
  /// - [maxChars] 文本最大长度范围 20~400，默认 120；
  /// - [dismissDuration] 关闭（反向）动画时长。
  static void show(
    String message, {
    BannerSide side = BannerSide.right,
    Duration duration = const Duration(seconds: 3),
    IconData icon = Icons.info_outline,
    Color? color,
    BuildContext? context,
    bool newestOnTop = true,
    int? maxChars,
    Duration? dismissDuration,
  }) {
    _SideBannerManager.instance._show(
      message: message,
      side: side,
      duration: duration,
      icon: icon,
      color: color,
      context: context,
      newestOnTop: newestOnTop,
      maxChars: maxChars,
      dismissDuration: dismissDuration,
    );
  }

  /// 便捷：信息提示（info）。
  ///
  /// 背景优先使用 [ColorScheme.primaryContainer]，
  /// 无上下文时使用接近的回退色。默认停留 3 秒。
  static void info(
    String message, {
    BannerSide side = BannerSide.right,
    Duration duration = const Duration(seconds: 3),
    BuildContext? context,
    bool newestOnTop = true,
    int? maxChars,
    Duration? dismissDuration,
  }) {
    final color = Get.theme.colorScheme.primaryContainer;
    show(
      message,
      side: side,
      duration: duration,
      icon: Icons.info_outline,
      color: color,
      context: context,
      newestOnTop: newestOnTop,
      maxChars: maxChars,
      dismissDuration: dismissDuration,
    );
  }

  /// 便捷：警告（warning）。
  ///
  /// 背景优先使用 [ColorScheme.tertiaryContainer]，
  /// 无上下文时使用回退色。默认停留 4 秒。
  static void warning(
    String message, {
    BannerSide side = BannerSide.right,
    Duration duration = const Duration(seconds: 4),
    BuildContext? context,
    bool newestOnTop = true,
    int? maxChars,
    Duration? dismissDuration,
  }) {
    final color = Get.theme.colorScheme.tertiaryContainer;
    show(
      message,
      side: side,
      duration: duration,
      icon: Icons.warning_amber_rounded,
      color: color,
      context: context,
      newestOnTop: newestOnTop,
      maxChars: maxChars,
      dismissDuration: dismissDuration,
    );
  }

  /// 便捷：危险/错误（danger）。
  ///
  /// 背景优先使用 [ColorScheme.errorContainer]，
  /// 无上下文时使用回退色。默认停留 5 秒。
  static void danger(
    String message, {
    BannerSide side = BannerSide.right,
    Duration duration = const Duration(seconds: 5),
    BuildContext? context,
    bool newestOnTop = true,
    int? maxChars,
    Duration? dismissDuration,
  }) {
    show(
      message,
      side: side,
      duration: duration,
      icon: Icons.error_outline,
      color: Get.theme.colorScheme.errorContainer,
      context: context,
      newestOnTop: newestOnTop,
      maxChars: maxChars,
      dismissDuration: dismissDuration,
    );
  }
}

/// 单例管理器：负责创建 Overlay Host 并向其添加/移除 Banner 项。
class _SideBannerManager {
  _SideBannerManager._();
  static final _SideBannerManager instance = _SideBannerManager._();

  OverlayEntry? _entry;
  _SideBannerOverlayState? _hostState;
  final List<_PendingEntry> _pending = [];

  /// 确保 Overlay Host 已插入到根 Overlay（仅创建一次）。
  void _ensureHost(BuildContext context) {
    if (_entry != null && _hostState != null) return;
    final overlay = Overlay.of(context, rootOverlay: true);
    final host = _SideBannerOverlay(
      onStateReady: (s) {
        _hostState = s;
        _flushPending();
      },
    );
    _entry = OverlayEntry(builder: (_) => host);
    overlay.insert(_entry!);
  }

  void _flushPending() {
    final host = _hostState;
    if (host == null || _pending.isEmpty) return;
    for (final p in _pending) {
      host.addItem(p.data, newestOnTop: p.newestOnTop);
    }
    _pending.clear();
  }

  /// 将一个新条目发送给 Host，并按需截断消息文本。
  void _show({
    required String message,
    required BannerSide side,
    required Duration duration,
    required IconData icon,
    Color? color,
    BuildContext? context,
    required bool newestOnTop,
    int? maxChars,
    Duration? dismissDuration,
  }) {
    final ctx = context ?? Get.overlayContext ?? Get.context;
    if (ctx == null) {
      debugPrint('SideBanner: no valid context to show overlay');
      return;
    }
    _ensureHost(ctx);
    // 限制消息长度，避免超长导致溢出
    final int limit = (maxChars ?? 120).clamp(20, 400);
    final String msg = message.length > limit
        ? '${message.substring(0, limit - 1)}…'
        : message;
    final data = _BannerData(
      id: UniqueKey(),
      message: msg,
      side: side,
      icon: icon,
      color: color,
      duration: duration,
      dismissDuration: dismissDuration ?? const Duration(milliseconds: 160),
    );
    if (_hostState == null) {
      // Host 还未完成挂载：先入等待队列，并在下一帧尝试刷新
      _pending.add(_PendingEntry(data, newestOnTop));
      WidgetsBinding.instance.addPostFrameCallback((_) => _flushPending());
    } else {
      _hostState!.addItem(data, newestOnTop: newestOnTop);
    }
  }
}

class _PendingEntry {
  final _BannerData data;
  final bool newestOnTop;
  const _PendingEntry(this.data, this.newestOnTop);
}

class _BannerData {
  final Key id;
  final String message;
  final BannerSide side;
  final IconData icon;
  final Color? color;
  final Duration duration;
  final Duration dismissDuration;
  _BannerData({
    required this.id,
    required this.message,
    required this.side,
    required this.icon,
    required this.color,
    required this.duration,
    required this.dismissDuration,
  });
}

/// Overlay 容器 Widget，承载左右两侧的 Banner 列表。
class _SideBannerOverlay extends StatefulWidget {
  final void Function(_SideBannerOverlayState) onStateReady;
  const _SideBannerOverlay({required this.onStateReady});

  @override
  State<_SideBannerOverlay> createState() => _SideBannerOverlayState();
}

/// Overlay 容器的 State，维护左右两侧的 Banner 列表及其渲染。
class _SideBannerOverlayState extends State<_SideBannerOverlay> {
  final List<_BannerData> _left = [];
  final List<_BannerData> _right = [];

  @override
  void initState() {
    super.initState();
    widget.onStateReady(this);
  }

  void addItem(_BannerData data, {required bool newestOnTop}) {
    setState(() {
      final list = data.side == BannerSide.left ? _left : _right;
      if (newestOnTop) {
        list.insert(0, data);
      } else {
        list.add(data);
      }
    });
  }

  void remove(_BannerData data) {
    if (!mounted) return;
    setState(() {
      _left.removeWhere((e) => e.id == data.id);
      _right.removeWhere((e) => e.id == data.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final topPadding = media.padding.top + 12;
    const gap = 8.0;
    // 最大宽度限制为屏幕宽度的一半（留出侧边距），确保不超过半屏
    const sidePadding = 12.0;
    final half = media.size.width * 0.5;
    final double maxWidth = math.max(0.0, half - sidePadding);

    return SafeArea(
      child: Stack(
        children: [
          // 左侧栈
          if (_left.isNotEmpty)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(top: topPadding, left: sidePadding),
                child: _BannerColumn(
                  items: _left,
                  onClose: remove,
                  gap: gap,
                  maxWidth: maxWidth,
                ),
              ),
            ),
          // 右侧栈
          if (_right.isNotEmpty)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: topPadding, right: sidePadding),
                child: _BannerColumn(
                  items: _right,
                  onClose: remove,
                  gap: gap,
                  maxWidth: maxWidth,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 单侧竖直堆叠的 Banner 列，控制间距与最大宽度。
class _BannerColumn extends StatelessWidget {
  final List<_BannerData> items;
  final void Function(_BannerData) onClose;
  final double gap;
  final double maxWidth;
  const _BannerColumn({
    required this.items,
    required this.onClose,
    required this.gap,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items) ...[
            _BannerCard(
              key: item.id,
              data: item,
              onClose: () => onClose(item),
              maxWidth: maxWidth,
            ),
            SizedBox(height: gap),
          ],
        ],
      ),
    );
  }
}

class _BannerCard extends StatefulWidget {
  /// 单个 Banner 项（含动画、手势、自动消失与固定逻辑）。
  final _BannerData data;
  final VoidCallback onClose;
  final double maxWidth;
  const _BannerCard({
    super.key,
    required this.data,
    required this.onClose,
    required this.maxWidth,
  });

  @override
  State<_BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends State<_BannerCard>
    with SingleTickerProviderStateMixin {
  /// 入场/退场动画控制器；退场时长由 data.dismissDuration 指定。
  late final AnimationController _ac;

  /// 位移动画：左右侧分别从 ±x 偏移进入；右侧最终会保留轻微正向偏移（微露出）。
  late final Animation<Offset> _offset;

  /// 透明度动画：随入场/退场同步变化。
  late final Animation<double> _fade;
  Timer? _timer;
  double _closeScale = 1.0;
  double _dragPx = 0.0;

  /// 是否已固定（被内侧滑动触发），固定后会取消自动消失并保持轻微内缩。
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: widget.data.dismissDuration,
    );
    final isLeft = widget.data.side == BannerSide.left;
    final from = isLeft ? const Offset(-0.2, 0) : const Offset(0.2, 0);
    // 右侧在最终状态保留一小段正向偏移，形成“部分隐藏在右侧”的效果
    final end = isLeft ? Offset.zero : const Offset(0.06, 0);
    _offset = Tween<Offset>(
      begin: from,
      end: end,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(_ac);
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _ac.forward();

    // 到时自动关闭，先播放消失动画再移除
    _timer = Timer(widget.data.duration, _close);
  }

  Future<void> _close() async {
    await _ac.reverse();
    widget.onClose();
  }

  void _onDragStart(DragStartDetails details) {
    // no-op for now
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      // 水平拖动位移，适度限制范围
      _dragPx = (_dragPx + details.delta.dx).clamp(-120.0, 120.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final isLeft = widget.data.side == BannerSide.left;
    final vx = details.velocity.pixelsPerSecond.dx;
    // 位移与速度双阈值判断
    const dxThreshold = 36.0;
    const vThreshold = 480.0;

    bool swipeToEdgeClose = false;
    bool swipeInwardPin = false;

    if (isLeft) {
      // 向左（负）关闭；向右（正）固定
      swipeToEdgeClose = _dragPx < -dxThreshold || vx < -vThreshold;
      swipeInwardPin = _dragPx > dxThreshold || vx > vThreshold;
    } else {
      // 右侧：向右（正）关闭；向左（负）固定
      swipeToEdgeClose = _dragPx > dxThreshold || vx > vThreshold;
      swipeInwardPin = _dragPx < -dxThreshold || vx < -vThreshold;
    }

    if (swipeToEdgeClose) {
      _close();
      return;
    }
    if (swipeInwardPin) {
      // 固定后，取消自动消失，轻微往内侧停靠
      _timer?.cancel();
      _timer = null;
      _isPinned = true;
      setState(() {
        _dragPx = isLeft ? 12.0 : -12.0;
      });
      return;
    }
    // 回弹：若已固定，则回到固定偏移；否则回到 0
    setState(() => _dragPx = _isPinned ? (isLeft ? 12.0 : -12.0) : 0.0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = widget.data.color ?? scheme.surfaceContainerHighest;
    // 当使用容器色作为背景时，自动匹配对应的 on*Container 前景色；否则回退到 onSurface
    final Color fg = () {
      if (widget.data.color == null) return scheme.onSurface;
      final c = bg;
      if (c == scheme.errorContainer) return scheme.onErrorContainer;
      if (c == scheme.primaryContainer) return scheme.onPrimaryContainer;
      if (c == scheme.secondaryContainer) return scheme.onSecondaryContainer;
      if (c == scheme.tertiaryContainer) return scheme.onTertiaryContainer;
      return scheme.onSurface;
    }();
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, child) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _offset, child: child),
      ),
      child: IgnorePointer(
        ignoring: false,
        child: Transform.translate(
          offset: Offset(_dragPx, 0),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Material(
              elevation: 4,
              color: bg,
              borderRadius: BorderRadius.circular(10),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // 更小的下限，避免短消息也被拉得过宽
                  minWidth: math.min(widget.maxWidth, 140.0),
                  maxWidth: widget.maxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.data.icon,
                        color: fg.withAlpha(230),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.data.message,
                          style: TextStyle(color: fg),
                          maxLines: 2,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _close,
                        onTapDown: (_) => setState(() => _closeScale = 0.86),
                        onTapUp: (_) => setState(() => _closeScale = 1.0),
                        onTapCancel: () => setState(() => _closeScale = 1.0),
                        child: AnimatedScale(
                          scale: _closeScale,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOut,
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: fg.withAlpha(204),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
