import 'package:html/dom.dart';
import 'package:voidlord/tono_reader/model/parser/tono_style_sheet_block.dart';
import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_text.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_selector_macher.dart';
import 'package:voidlord/tono_reader/parser/widget_parser/img_parser.dart';
import 'package:voidlord/tono_reader/parser/widget_parser/ruby_parser.dart';
import 'package:voidlord/tono_reader/parser/widget_parser/svg_parser.dart';
import 'package:voidlord/tono_reader/tool/css_tool.dart';

extension ContainerParser on TonoParser {
  Future<TonoWidget> toContainer(
    Element element,
    String currentPath,
    List<TonoStyleSheetBlock> css, {
    List<TonoStyle>? inheritStyles,
  }) async {
    var matchedCss = matchAll(element, css, inheritStyles);
    var theInheritStyle = matchedCss.where((e) {
      return e.property == 'color' ||
          e.property == 'text-align' ||
          e.property == "font-family" ||
          e.property == "font-size" ||
          e.property == "font-weight" ||
          e.property == "text-indent" ||
          e.property == "text-align" ||
          e.property == 'text-shadow' ||
          e.property == 'line-height';
    }).toList();

    List<TonoWidget> children = [];
    for (var childrenNode in element.nodes) {
      if (childrenNode.nodeType == 1) {
        var element = childrenNode as Element;
        if (element.localName == "head" ||
            element.localName == 'noscript' ||
            element.localName == 'nav' ||
            element.localName == 'aside') {
          continue;
        }
        if (element.localName == "br") {
          if (element.parent?.children.length == 1) {
            children.add(TonoText(text: " ", css: theInheritStyle));
          } else {
            children.add(TonoText(text: "\n", css: theInheritStyle));
          }
        } else if (element.localName == "svg") {
          children.add(await toSvg(element, currentPath, css,
              inheritStyles: inheritStyles));
        } else if (element.localName == "img") {
          children.add(
              toImg(element, currentPath, css, inheritStyles: inheritStyles));
        } else {
          if (element.localName == "ruby") {
            children.add(toRuby(
              element,
              css,
              inheritStyles: theInheritStyle,
            ));
          } else {
            children.add(await toContainer(element, currentPath, css,
                inheritStyles: theInheritStyle));
          }
        }
      }
      if (childrenNode.nodeType == 3) {
        if (!(childrenNode.text?.trim() == "" &&
            childrenNode.parentNode?.nodes.length != 1)) {
          children.add(
              TonoText(text: childrenNode.text ?? "", css: theInheritStyle));
        }
      }
    }
    var display = "block";
    if (element.localName == "a" ||
        element.localName == "span" ||
        element.localName == "ruby" ||
        element.localName == "sup") {
      display = "inline";
    }
    if (matchedCss.toMap()['display']?.contains("block") ?? false) {
      display = "block";
    }
    if (matchedCss.toMap()['display']?.contains("flex") ?? false) {
      display = "flex";
    }
    return TonoContainer(
      css: matchedCss,
      children: children,
      className: element.localName!,
      display: display,
    );
  }
}
