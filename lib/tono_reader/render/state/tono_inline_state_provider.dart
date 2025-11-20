import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class InlineState {
  bool indented = false;
}

class TonoInlineStateProvider extends InheritedWidget {
  const TonoInlineStateProvider({
    super.key,
    required this.state,
    required super.child,
  });

  final InlineState state;

  static TonoInlineStateProvider of(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<TonoInlineStateProvider>()!
        .widget as TonoInlineStateProvider;
  }

  @override
  bool updateShouldNotify(TonoInlineStateProvider old) {
    return old.state.indented != state.indented;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty("indented", state.indented),
    );

    super.debugFillProperties(properties);
  }
}

extension InlineContainerWidget on BuildContext {
  bool get indented => TonoInlineStateProvider.of(this).state.indented;
  set indented(bool value) =>
      TonoInlineStateProvider.of(this).state.indented = value;
}
