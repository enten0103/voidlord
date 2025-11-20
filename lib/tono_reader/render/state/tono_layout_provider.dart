import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

enum TonoLayoutType {
  fix,
  shrink,
}

class TonoLayoutProvider extends InheritedWidget {
  const TonoLayoutProvider({
    super.key,
    required this.type,
    required super.child,
  });

  final TonoLayoutType type;

  static TonoLayoutProvider of(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<TonoLayoutProvider>()!
        .widget as TonoLayoutProvider;
  }

  @override
  bool updateShouldNotify(TonoLayoutProvider old) {
    return old.type != type;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty("type", type),
    );

    super.debugFillProperties(properties);
  }
}

extension ContainerGetter on BuildContext {
  get tonoLayoutType => TonoLayoutProvider.of(this).type;
}
