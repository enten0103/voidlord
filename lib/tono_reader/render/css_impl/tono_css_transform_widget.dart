import 'package:flutter/widgets.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_widget.dart';

/// 实现如下css
/// -transform
/// -transform-origin
class TonoCssTransformWidget extends TonoCssWidget {
  final Widget child; // 要应用变换的子组件

  TonoCssTransformWidget({
    super.key,
    required this.child,
  });

  @override
  Widget content(BuildContext context) {
    if (transform == null) {
      return child;
    }
    return Transform(
      alignment: transformOrigin,
      transform: transform!,
      child: child,
    );
  }
}
