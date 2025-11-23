import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResponsiveRefresher extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const ResponsiveRefresher({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isDesktop) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        floatingActionButton: FloatingActionButton(
          onPressed: onRefresh,
          child: const Icon(Icons.refresh),
        ),
      );
    } else {
      return RefreshIndicator(onRefresh: onRefresh, child: child);
    }
  }
}
