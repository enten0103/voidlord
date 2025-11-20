import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_display_widget.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';
import 'package:voidlord/tono_reader/render/state/tono_container_provider.dart';
import 'package:voidlord/tono_reader/render/state/tono_parent_size_cache.dart';
import 'package:voidlord/tono_reader/tool/tono_container_tool.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_margin_widget.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_size_padding_widget.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_transform_widget.dart';

class TonoContainerWidget extends StatelessWidget {
  const TonoContainerWidget({
    super.key,
    required this.tonoContainer,
  });

  final TonoContainer tonoContainer;

  @override
  Widget build(BuildContext context) {
    var children = tonoContainer.genChildren();
    var cache = Get.find<TonoParentSizeCache>();
    try {
      var fcm = FlutterStyleFromCss(
        tonoContainer.css,
        pdisplay: tonoContainer.parent?.display,
        tdisplay: tonoContainer.display,
        parentSize:
            cache.getSize(tonoContainer.hashCode) ?? context.psize.value,
      ).flutterStyleMap;
      return TonoContainerProvider(
        fcm: fcm,
        psize: Rx(PredictSize()),
        data: tonoContainer,
        child: TonoCssTransformWidget(
            child: TonoCssMarginWidget(
          child: TonoCssSizePaddingWidget(
              child: TonoCssDisplayWidget(children: children)),
        )),
      );
    } on NeedParentSizeException catch (_) {
      return Obx(() {
        var parentSize = context.psize;
        if (parentSize.value.width == null && parentSize.value.height == null) {
          return SizedBox(
            width: double.infinity,
          );
        } else {
          cache.setSize(tonoContainer.hashCode, parentSize.value);
          var fcm = FlutterStyleFromCss(
            tonoContainer.css,
            pdisplay: tonoContainer.parent?.display,
            tdisplay: tonoContainer.display,
            parentSize: parentSize.value,
          ).flutterStyleMap;

          return TonoContainerProvider(
            fcm: fcm,
            psize: Rx(parentSize.value),
            data: tonoContainer,
            child: TonoCssTransformWidget(
                child: TonoCssMarginWidget(
              child: TonoCssSizePaddingWidget(
                  child: TonoCssDisplayWidget(children: children)),
            )),
          );
        }
      });
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty<String>("className", tonoContainer.className),
    );
    properties.add(
      DiagnosticsProperty<String>("display", tonoContainer.display),
    );
    super.debugFillProperties(properties);
  }
}
