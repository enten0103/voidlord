import 'package:get/get_utils/get_utils.dart';
import 'package:html/dom.dart' as dom;
import 'package:voidlord/tono_reader/model/parser/tono_selector_part.dart';
import 'package:voidlord/tono_reader/model/parser/tono_style_sheet_block.dart';
import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_style_parser.dart';

extension TonoSelectorMacher on TonoParser {
  List<TonoStyle> genInlineStyle(dom.Element element) {
    var style = element.attributes['style'];
    List<TonoStyle> result = [];

    /// 添加用户代理样式表
    if (element.localName == "hr") {
      result.add(TonoStyle(
          priority: -100, value: "1px", property: "border-top-width"));
      result.add(
          TonoStyle(priority: -100, value: "0.5em", property: "margin-top"));
      result.add(
          TonoStyle(priority: -100, value: "0.5em", property: "margin-bottom"));
    }

    if (element.localName == "tr") {
      result.add(TonoStyle(priority: -100, value: "flex", property: "display"));
    }

    if (element.localName == "table") {
      result.add(
          TonoStyle(priority: -100, value: "fit-content", property: "width"));
    }

    if (element.localName == "tbody") {
      result.add(
          TonoStyle(priority: -100, value: "fit-content", property: "width"));
    }

    /// 解析内联样式
    if (style == null) return result;
    var splitedStyle = style.split(';');
    for (var ss in splitedStyle) {
      if (ss.trim() == "") {
        continue;
      }
      var rule = ss.split(":");
      if (rule.length < 2) continue;
      var property = rule[0];
      var value = rule[1];
      if (property == 'margin') {
        var margins = marginSegmentation(value);
        for (var key in margins.keys) {
          result.add(TonoStyle(
              priority: 10000000000, value: margins[key]!, property: key));
        }
      } else if (property == 'padding') {
        var paddings = paddingSegmentation(value);
        for (var key in paddings.keys) {
          result.add(TonoStyle(
              priority: 10000000000, value: paddings[key]!, property: key));
        }
      } else if (property == "border-width") {
        var borderWidths = borderWidthSegmentation(value);
        for (var key in borderWidths.keys) {
          result.add(TonoStyle(
              priority: 10000000000, value: borderWidths[key]!, property: key));
        }
      } else if (property == "border") {
        var borders = borderDirectionSegmentation(
            value, ["left", "right", "top", "bottom"]);
        for (var key in borders.keys) {
          result.add(TonoStyle(
              priority: 10000000000, value: borders[key]!, property: key));
        }
      } else if (property == "border-left") {
        var borders = borderDirectionSegmentation(value, ["left"]);
        for (var key in borders.keys) {
          result.add(TonoStyle(
              priority: 10000000000, value: borders[key]!, property: key));
        }
      } else if (property == "border-right") {
        var borders = borderDirectionSegmentation(value, ["right"]);
        for (var key in borders.keys) {
          result.add(TonoStyle(
              priority: 10000000000, value: borders[key]!, property: key));
        }
      } else if (property == "border-top") {
        var borders = borderDirectionSegmentation(value, ["top"]);
        for (var key in borders.keys) {
          result.add(TonoStyle(
              priority: 10000000000, value: borders[key]!, property: key));
        }
      } else if (property == "border-bottom") {
        var borders = borderDirectionSegmentation(value, ["bottom"]);
        for (var key in borders.keys) {
          result.add(TonoStyle(
              priority: 10000000000, value: borders[key]!, property: key));
        }
      } else {
        result.add(
            TonoStyle(priority: 10000000000, value: value, property: property));
      }

      result.add(
          TonoStyle(priority: 10000000000, value: rule[1], property: rule[0]));
    }

    return result;
  }

  List<TonoStyle> matchAll(
    dom.Element element,
    List<TonoStyleSheetBlock> css,
    List<TonoStyle>? inheritStyles,
  ) {
    List<TonoStyle> result = genInlineStyle(element);
    if (inheritStyles != null) {
      for (var i = 0; i < inheritStyles.length; i++) {
        var ist = inheritStyles[i];
        var r = result.firstWhereOrNull((e) {
          return e.property == ist.property;
        });
        if (r == null) {
          var priority = -100;
          if (ist.value.contains('important')) {
            priority = 1000;
          }
          if (ist.property == "font-family") {
            priority = -1000;
          }
          result.add(TonoStyle(
              priority: priority, value: ist.value, property: ist.property));
        }
      }
    }
    for (var cssBlock in css) {
      var selector = cssBlock.selector;
      for (var group in selector.groups) {
        var isSelect = false;
        String? combinator;
        s2:
        for (var i = 0; i < group.parts.length; i++) {
          var part = group.parts.reversed.toList()[i];
          if (combinator != null) {
            isSelect = _combinat(element, part, combinator);
          } else {
            isSelect = _select(element, part);
          }
          if (i < group.combinators.length) {
            combinator = group.combinators[i];
          }
          if (!isSelect) {
            break s2;
          }
        }
        if (isSelect) {
          cssBlock.properties.forEach((k, v) {
            var p = result.where((e) {
              return e.property == k;
            });
            if (p.isNotEmpty) {
              ///字号继承 复杂,建议重写
              if (k == 'font-size') {
                v = v.replaceAll("!important", "");
                if (v.endsWith("em") && p.first.value.endsWith("em")) {
                  /// em -> em
                  var newFontSize = double.parse(v.replaceAll("em", ""));
                  var oldFontSize =
                      double.parse(p.first.value.replaceAll("em", ""));
                  result.remove(p.first);
                  result.add(TonoStyle(
                    priority: group.specificity,
                    value: "${newFontSize * oldFontSize}em",
                    property: k,
                  ));
                } else if (v.endsWith("px")) {
                  ///x -> px
                  result.remove(p.first);
                  result.add(TonoStyle(
                    priority: group.specificity,
                    value: v,
                    property: k,
                  ));
                } else if (v.endsWith("em") && p.first.value.endsWith("px")) {
                  /// px -> em
                  var newFontSize = double.parse(v.replaceAll("em", ""));
                  var oldFontSize =
                      double.parse(p.first.value.replaceAll("px", ""));
                  result.remove(p.first);
                  result.add(TonoStyle(
                    priority: group.specificity,
                    value: "${newFontSize * oldFontSize}px",
                    property: k,
                  ));
                } else if (v.endsWith("%")) {
                  if (p.first.value.endsWith("px")) {
                    var newFontSize = double.parse(v.replaceAll("%", "")) / 100;
                    var oldFontSize =
                        double.parse(p.first.value.replaceAll("px", ""));
                    result.remove(p.first);
                    result.add(TonoStyle(
                      priority: group.specificity,
                      value: "${newFontSize * oldFontSize}px",
                      property: k,
                    ));
                  }
                  if (p.first.value.endsWith("em")) {
                    var newFontSize = double.parse(v.replaceAll("%", "")) / 100;
                    var oldFontSize =
                        double.parse(p.first.value.replaceAll("em", ""));
                    result.remove(p.first);
                    result.add(TonoStyle(
                      priority: group.specificity,
                      value: "${newFontSize * oldFontSize}em",
                      property: k,
                    ));
                  }
                }
              } else {
                var specificity = v.contains("!important")
                    ? 1000000000000000000
                    : group.specificity;
                v = v.trim();
                if (p.first.priority <= group.specificity) {
                  result.remove(p.first);
                  result.add(TonoStyle(
                    priority: specificity,
                    value: v.replaceAll("!important", "").trim(),
                    property: k,
                  ));
                }
              }
            } else {
              var specificity = v.contains("!important")
                  ? 1000000000000000000
                  : group.specificity;

              result.add(TonoStyle(
                priority: specificity,
                value: v.replaceAll("!important", "").trim(),
                property: k,
              ));
            }
          });
        }
      }
    }
    return result;
  }

  bool _select(dom.Element element, TonoSelectorPart selector) {
    var result = true;
    if (selector.isUniversal) {
      return true;
    }
    if (selector.element != null) {
      result = (element.localName == selector.element);
      if (!result) return false;
    }
    if (selector.id != null && selector.id != "") {
      result = result && (element.id == selector.id);
    }
    if (selector.classes.isNotEmpty) {
      for (var i = 0; i < selector.classes.length; i++) {
        var className = selector.classes[i];
        result = result && element.classes.contains(className);
      }
    }

    if (selector.attributes.isNotEmpty) {
      for (var i = 0; i < selector.attributes.length; i++) {
        var attribute = selector.attributes[i];
        result = result && (element.attributes[attribute] == null);
      }
    }

    return result;
  }

  bool _combinat(
    dom.Element element,
    TonoSelectorPart selector,
    String combinat,
  ) {
    return switch (combinat) {
      "child" => _childCombiator(element, selector),
      "next-sibling" => _nextSiblingCombiator(element, selector),
      "general-sibling" => _generalSiblingCombiator(element, selector),
      "descendant" => _descendantCombiatro(element, selector),
      _ => throw Exception("未知组合器"),
    };
  }

  bool _childCombiator(
    dom.Element element,
    TonoSelectorPart selector,
  ) {
    var pn = element.parent;
    if (pn == null) return false;
    return _select(pn, selector);
  }

  bool _nextSiblingCombiator(
    dom.Element element,
    TonoSelectorPart selector,
  ) {
    var pn = element.previousElementSibling;
    if (pn == null) return false;
    return _select(pn, selector);
  }

  bool _generalSiblingCombiator(
    dom.Element element,
    TonoSelectorPart selector,
  ) {
    var nn = element.nextElementSibling;
    while (nn != null) {
      if (_select(nn, selector)) {
        return true;
      }
      nn = nn.nextElementSibling;
    }
    return false;
  }

  bool _descendantCombiatro(
    dom.Element element,
    TonoSelectorPart selector,
  ) {
    var pn = element.parent;
    while (pn != null) {
      if (_select(pn, selector)) {
        return true;
      }
      pn = pn.parent;
    }
    return false;
  }
}
