import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class TonoInteractionProvider extends InheritedWidget {
  const TonoInteractionProvider({
    super.key,
    required this.markded,
    required super.child,
  });

  final RxBool markded;

  static TonoInteractionProvider of(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<TonoInteractionProvider>()!
        .widget as TonoInteractionProvider;
  }

  @override
  bool updateShouldNotify(TonoInteractionProvider old) {
    return old.markded != markded;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty("markded", markded),
    );

    super.debugFillProperties(properties);
  }
}

extension InlineContainerWidget on BuildContext {
  RxBool get markded => TonoInteractionProvider.of(this).markded;
}
