import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';
import 'package:voidlord/tono_reader/state/tono_assets_provider.dart';
import 'package:voidlord/tono_reader/state/tono_data_provider.dart';
import 'package:voidlord/tono_reader/tool/async_memory_image.dart';
import 'package:voidlord/tono_reader/tool/box_decoration.dart';

extension TonoCssBorderBgc on FlutterCssMixin {
  Decoration get boxDecoration => _boxDecoration();

  /// [BoxDecoration]
  /// 实现如下CSS
  /// - border
  /// - border-radius
  /// - background-color
  /// - background-image
  Decoration _boxDecoration() {
    var assetsProvider = Get.find<TonoAssetsProvider>();
    String? bookHash;
    try {
      bookHash = Get.find<TonoProvider>().bookHash;
    } catch (_) {}

    return TonoBoxDecoration(
      color: backgroundColor ?? (boxShadow != null ? Colors.white : null),
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow != null ? [boxShadow!] : [],
      image: backgroundImage != null
          ? TonoDecorationImage(
              alignment: backgroundPosition ?? Alignment.center,
              repeat: backgroundRepet,
              size: backgroundSize ?? BackgroundSize(),
              image: AsyncMemoryImage(
                assetsProvider.getAssetsById(backgroundImage!),
                backgroundImage!,
                bookHash: bookHash,
              ),
            )
          : null,
    );
  }
}
