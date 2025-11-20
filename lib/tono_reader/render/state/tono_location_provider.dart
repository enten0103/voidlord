import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:voidlord/tono_reader/model/base/tono_location.dart';

class TonoLocationProvider extends InheritedWidget {
  const TonoLocationProvider({
    super.key,
    required this.location,
    required super.child,
  });

  final TonoLocation location;

  static TonoLocationProvider of(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<TonoLocationProvider>()!
        .widget as TonoLocationProvider;
  }

  @override
  bool updateShouldNotify(TonoLocationProvider old) {
    return (old.location.elementIndex != location.elementIndex) &&
        (old.location.xhtmlIndex != location.xhtmlIndex);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty("location", location),
    );

    super.debugFillProperties(properties);
  }
}

extension ContainerGetter on BuildContext {
  TonoLocation get location => TonoLocationProvider.of(this).location;
}
