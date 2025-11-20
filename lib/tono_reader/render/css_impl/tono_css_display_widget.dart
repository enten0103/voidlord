import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_widget.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_display.dart';
import 'package:voidlord/tono_reader/render/state/tono_inline_state_provider.dart';
import 'package:voidlord/tono_reader/render/state/tono_layout_provider.dart';
import 'package:voidlord/tono_reader/tool/reversed_column.dart';

/// 实现如下CSS
/// - display
/// - justify-content
/// - align-item
/// - text-align
/// 提供inline state
class TonoCssDisplayWidget extends TonoCssWidget {
  TonoCssDisplayWidget({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget content(BuildContext context) {
    if (children.length == 1) {
      if (display == CssDisplay.block) {
        return TonoInlineStateProvider(
          state: InlineState(),
          child: children[0],
        );
      }
      return children[0];
    }
    return switch (display) {
      CssDisplay.flex => TonoLayoutProvider(
          type: TonoLayoutType.shrink,
          child: Row(
            mainAxisAlignment: justifyContent,
            crossAxisAlignment: alignItems,
            children: children,
          )),
      CssDisplay.block => TonoInlineStateProvider(
          state: InlineState(),
          child: ReversedColumn(
            crossAxisAlignment: context.tonoLayoutType == TonoLayoutType.fix
                ? CrossAxisAlignment.stretch
                : alignItems,
            mainAxisAlignment: justifyContent,
            children: children,
          )),
      CssDisplay.inline => Row(
          mainAxisAlignment: justifyContent,
          crossAxisAlignment: alignItems,
          children: children,
        ),
    };
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty("display", display),
    );
    properties.add(
      DiagnosticsProperty("justifyContent", justifyContent),
    );
    properties.add(
      DiagnosticsProperty("alignItems", alignItems),
    );
    properties.add(
      DiagnosticsProperty("border-width", border?.left.width),
    );

    super.debugFillProperties(properties);
  }
}
