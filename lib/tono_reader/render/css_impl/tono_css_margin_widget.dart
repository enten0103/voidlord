import 'package:flutter/cupertino.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_widget.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_margin.dart';
import 'package:voidlord/tono_reader/tool/margin.dart';

/// 实现如下CSS
/// - margin*
class TonoCssMarginWidget extends TonoCssWidget {
  final Widget child;
  TonoCssMarginWidget({
    super.key,
    required this.child,
  });
  @override
  Widget content(BuildContext context) {
    var left = marginLeft is ValuedCssMargin
        ? (marginLeft as ValuedCssMargin).value
        : 0.0;
    var right = marginRight is ValuedCssMargin
        ? (marginRight as ValuedCssMargin).value
        : 0.0;
    var top = marginTop is ValuedCssMargin
        ? (marginTop as ValuedCssMargin).value
        : 0.0;
    var bottom = marginBottom is ValuedCssMargin
        ? (marginBottom as ValuedCssMargin).value
        : 0.0;
    if (marginLeft is KeyWordCssMargin && marginRight is KeyWordCssMargin) {
      return Center(
        child: AdaptiveMargin(
          margin: EdgeInsets.only(top: top, bottom: bottom),
          child: child,
        ),
      );
    }
    return AdaptiveMargin(
        margin:
            EdgeInsets.only(left: left, right: right, top: top, bottom: bottom),
        child: child);
  }
}
