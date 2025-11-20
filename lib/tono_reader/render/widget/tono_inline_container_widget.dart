import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_image.dart';
import 'package:voidlord/tono_reader/model/widget/tono_ruby.dart';
import 'package:voidlord/tono_reader/model/widget/tono_svg.dart';
import 'package:voidlord/tono_reader/model/widget/tono_text.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/render/css_impl/tono_css_widget.dart';
import 'package:voidlord/tono_reader/render/widget/inline/tono_container_render.dart';
import 'package:voidlord/tono_reader/render/widget/inline/tono_image_render.dart';
import 'package:voidlord/tono_reader/render/widget/inline/tono_ruby_render.dart';
import 'package:voidlord/tono_reader/render/widget/inline/tono_svg_render.dart';
import 'package:voidlord/tono_reader/render/widget/inline/tono_text_render.dart';

class TonoInlineContainerWidget extends TonoCssWidget {
  TonoInlineContainerWidget({
    super.key,
    required this.inlineWidgets,
  });

  final List<TonoWidget> inlineWidgets;

  @override
  Widget content(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: inlineWidgets.map((e) {
          if (e is TonoText) {
            return renderText(e, context);
          } else if (e is TonoContainer) {
            return renderContainer(e);
          } else if (e is TonoRuby) {
            return renderRuby(e, context);
          } else if (e is TonoImage) {
            return renderImage(e);
          } else if (e is TonoSvg) {
            return renderSvg(e);
          } else {
            return const TextSpan(text: "unknown widget");
          }
        }).toList(),
      ),
      textAlign: textAlign,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(
      DiagnosticsProperty("textAlign", textAlign),
    );
    super.debugFillProperties(properties);
  }
}
