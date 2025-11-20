import 'package:flutter/material.dart';
import 'package:voidlord/tono_reader/model/widget/tono_ruby.dart';
import 'package:voidlord/tono_reader/render/state/tono_inline_state_provider.dart';
import 'package:voidlord/tono_reader/render/widget/tono_inline_container_widget.dart';

extension TonoRubyRender on TonoInlineContainerWidget {
  InlineSpan renderRuby(
    TonoRuby tonoRuby,
    BuildContext context,
  ) {
    bool indented = context.indented;
    if (!indented) {
      context.indented = true;
    }
    return TextSpan(
      children: [
        !indented
            ? WidgetSpan(
                child: SizedBox(
                  width: (fontSize *
                      (textIndent == null
                          ? 0
                          : textIndent! < 0
                              ? 0
                              : textIndent!)),
                ),
              )
            : const WidgetSpan(child: SizedBox()),
        ...tonoRuby.texts.map((e) {
          return WidgetSpan(
              baseline: TextBaseline.alphabetic,
              alignment: PlaceholderAlignment.baseline,
              child: Column(verticalDirection: VerticalDirection.up, children: [
                Text(
                  e.text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamilyFallback: fontFamily,
                    height: lineHeight,
                    color: color,
                    fontWeight: fontWeight,
                  ),
                ),
                Text(
                  e.ruby ?? "",
                  style: TextStyle(
                      fontSize: fontSize * 0.5, height: lineHeight * 0.5),
                ),
              ]));
        })
      ],
    );
  }
}
