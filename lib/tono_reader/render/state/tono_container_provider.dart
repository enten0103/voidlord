import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/state_manager.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';

extension SizeTool on Size {
  toPredictSize() {
    return PredictSize(width: width, height: height);
  }
}

class PredictSize {
  PredictSize({this.width, this.height});
  double? width;
  double? height;
}

class TonoContainerProvider extends InheritedWidget {
  const TonoContainerProvider({
    super.key,
    required this.data,
    required super.child,
    required this.fcm,
    required this.psize,
  });

  final TonoWidget data;
  final Rx<PredictSize> psize;
  final Map<String, dynamic> fcm;

  static TonoContainerProvider of(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<TonoContainerProvider>()!
        .widget as TonoContainerProvider;
  }

  @override
  bool updateShouldNotify(TonoContainerProvider old) {
    return old.data != data;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    for (var entity in fcm.entries) {
      properties.add(DiagnosticsProperty(entity.key, entity.value));
    }

    properties.add(
      DiagnosticsProperty("predict_size_width", psize.value.width),
    );
    properties.add(
      DiagnosticsProperty("predict_size_height", psize.value.height),
    );

    properties.add(DiagnosticsProperty("css node", data.css));
    super.debugFillProperties(properties);
  }
}

extension ContainerGetter on BuildContext {
  TonoWidget get tonoWidget => TonoContainerProvider.of(this).data;
  Rx<PredictSize> get psize => TonoContainerProvider.of(this).psize;
  Map<String, dynamic> get fcm => TonoContainerProvider.of(this).fcm;
}
