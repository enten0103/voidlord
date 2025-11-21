import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:voidlord/tono_reader/model/widget/tono_image.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_size_padding_widget.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_widget.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_height.dart';
import 'package:voidlord/tono_reader/render/state/tono_container_provider.dart';
import 'package:voidlord/tono_reader/render/widget/tono_inline_container_widget.dart';
import 'package:voidlord/tono_reader/state/tono_assets_provider.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/tool/async_memory_image.dart';
import 'package:voidlord/tono_reader/ui/default/comps/dialog/pic_dialog_view.dart';

extension TonoImageRender on TonoInlineContainerWidget {
  InlineSpan renderImage(TonoImage tonoImage) {
    var fcm = FlutterStyleFromCss(
      tonoImage.css,
      pdisplay: tonoImage.parent?.display,
      tdisplay: "inline",
      parentSize: Size(
        Get.mediaQuery.size.width,
        Get.mediaQuery.size.height,
      ).toPredictSize(),
    ).flutterStyleMap;

    return WidgetSpan(
      baseline: TextBaseline.alphabetic,
      alignment: PlaceholderAlignment.baseline,
      child: TonoContainerProvider(
        fcm: fcm,
        data: tonoImage,
        key: ValueKey(tonoImage.hashCode),
        psize: Rx(Get.mediaQuery.size.toPredictSize()),
        child: TonoCssSizePaddingWidget(
          child: TonoImageWidget(
            key: ValueKey("${tonoImage.hashCode}/1"),
            tonoImage: tonoImage,
          ),
        ),
      ),
    );
  }
}

class TonoImageWidget extends TonoCssWidget {
  TonoImageWidget({super.key, required this.tonoImage});

  final TonoImage tonoImage;

  @override
  Widget content(BuildContext context) {
    var assetsProvider = Get.find<TonoAssetsProvider>();
    final assetId = p.basenameWithoutExtension(tonoImage.url);
    String? bookHash;
    try {
      bookHash = Get.find<TonoProvider>().bookHash;
    } catch (_) {}

    return GestureDetector(
      onTap: () {
        Get.dialog(
          PicDialogView(
            image: AsyncMemoryImage(
              assetsProvider.getAssetsById(assetId),
              assetId,
              bookHash: bookHash,
            ),
          ),
        );
      },
      child: Image(
        key: ValueKey(tonoImage.hashCode),
        gaplessPlayback: true,
        image: AsyncMemoryImage(
          assetsProvider.getAssetsById(assetId),
          assetId,
          bookHash: bookHash,
        ),
        height: height is ValuedCssHeight
            ? (height as ValuedCssHeight).value
            : null,
        width: width is ValuedCssHeight
            ? (width as ValuedCssHeight).value
            : null,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty("height", height));
    properties.add(DiagnosticsProperty("width", width));
    super.debugFillProperties(properties);
  }
}
