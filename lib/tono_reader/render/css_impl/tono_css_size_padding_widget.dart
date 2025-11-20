import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_widget.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_display.dart';
import 'package:voidlord/tono_reader/render/state/tono_container_provider.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_border_bgc.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_height.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_width.dart';
import 'package:voidlord/tono_reader/render/state/tono_layout_provider.dart';
import 'package:voidlord/tono_reader/tool/after_layout.dart';

/// 实现如下css
/// - width
/// - height
/// - max-width
/// - max-height
/// - padding
class TonoCssSizePaddingWidget extends TonoCssWidget {
  TonoCssSizePaddingWidget({
    super.key,
    required this.child,
  });
  final Widget child;
  @override
  Widget content(BuildContext context) {
    /// valued css
    double? widthValue;
    double? heightValue;
    double? maxHeightValue;
    double? maxWidthValue;

    if (maxHeight is ValuedCssHeight) {
      maxHeightValue = (maxHeight as ValuedCssHeight).value;
    }

    if (maxWidth is ValuedCssWidth) {
      maxWidthValue = (maxWidth as ValuedCssWidth).value;
      if (maxWidthValue <= 0) {
        maxWidthValue = 0;
      }
    }

    if (width is ValuedCssWidth) {
      widthValue = (width as ValuedCssWidth).value;
    }

    if (height is ValuedCssHeight) {
      heightValue = (height as ValuedCssHeight).value;
    }

    if (width == null) {
      if (context.tonoLayoutType == TonoLayoutType.fix &&
          display == CssDisplay.block) {
        widthValue = double.infinity;
      }
    }

    var container = AfterLayout(
        callback: (values) {
          if (context.psize.value.height == null &&
              context.psize.value.width == null) {
            context.psize.value = values.size.toPredictSize();
          }
        },
        child: Container(
          padding: padding,
          height: heightValue,
          width: widthValue,
          decoration: boxDecoration,
          constraints: BoxConstraints(
            maxHeight: maxHeightValue ?? double.infinity,
            maxWidth: maxWidthValue ?? double.infinity,
          ),
          child: child,
        ));
    if (width is KeyWordCssWidth? &&
        (width as KeyWordCssWidth?)?.keyWord == CssWidthKeyWords.fitContent) {
      return TonoLayoutProvider(
        type: TonoLayoutType.shrink,
        child: container,
      );
    }
    if (width is ValuedCssWidth) {
      return TonoLayoutProvider(
        type: TonoLayoutType.fix,
        child: container,
      );
    }
    return container;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty<CssWidth>("width", width),
    );
    properties.add(
      DiagnosticsProperty<CssHeight>("height", height),
    );
    properties.add(
      DiagnosticsProperty<CssWidth>("max-width", maxWidth),
    );
    properties.add(
      DiagnosticsProperty<CssHeight>("max-height", maxHeight),
    );
    properties.add(
      DiagnosticsProperty<EdgeInsets>("padding", padding),
    );
    properties.add(
      DiagnosticsProperty<CssDisplay>("display", display),
    );
    properties.add(
      DiagnosticsProperty<String>("pdisplay", pDisplay),
    );
    super.debugFillProperties(properties);
  }
}
