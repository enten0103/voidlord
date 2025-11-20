import 'package:flutter/material.dart';

class SizeWatchdBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error) fallback;

  const SizeWatchdBoundary({
    super.key,
    required this.child,
    required this.fallback,
  });

  @override
  ErrorBoundaryState createState() => ErrorBoundaryState();
}

class ErrorBoundaryState extends State<SizeWatchdBoundary> {
  late ErrorWidgetBuilder originalBuilder;

  @override
  void initState() {
    super.initState();
    // 保存原始的错误组件构建器
    originalBuilder = ErrorWidget.builder;
    // 设置自定义错误处理
    ErrorWidget.builder = _handleError;
  }

  @override
  void dispose() {
    // 恢复原始的错误处理
    ErrorWidget.builder = originalBuilder;
    super.dispose();
  }

  Widget _handleError(FlutterErrorDetails errorDetails) {
    return widget.fallback(errorDetails.exception);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
