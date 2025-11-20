import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/model/widget/tono_svg.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';
import 'package:voidlord/tono_reader/render/state/tono_container_provider.dart';
import 'package:voidlord/tono_reader/render/widget/tono_inline_container_widget.dart';

extension TonoImageRender on TonoInlineContainerWidget {
  InlineSpan renderSvg(TonoSvg tonoSvg) {
    var fcm = FlutterStyleFromCss(
      tonoSvg.css,
      pdisplay: tonoSvg.parent?.display,
      tdisplay: "inline",
      parentSize: Size(Get.mediaQuery.size.width, Get.mediaQuery.size.height)
          .toPredictSize(),
    ).flutterStyleMap;

    return WidgetSpan(
        baseline: TextBaseline.alphabetic,
        alignment: PlaceholderAlignment.baseline,
        child: TonoContainerProvider(
            fcm: fcm,
            data: tonoSvg,
            psize: Rx(Get.mediaQuery.size.toPredictSize()),
            child: TonoSvgWidget(src: tonoSvg.src)));
  }
}

class TonoSvgWidget extends StatelessWidget {
  const TonoSvgWidget({super.key, required this.src});
  final String src;
  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(src);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty("src", src));
    super.debugFillProperties(properties);
  }
}
