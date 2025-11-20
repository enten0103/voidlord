import 'dart:convert';
import 'package:csslib/visitor.dart';
import 'package:voidlord/tono_reader/model/parser/tono_style_sheet_block.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_selector_parser.dart';
import 'package:voidlord/tono_reader/tool/path_tool.dart';
import 'package:csslib/parser.dart' as csslib;

extension TonoStyleParser on TonoParser {
  /// 解析 CSS 文件，返回选择器及其规则的 List
  Future<List<TonoStyleSheetBlock>> parseCss(
      String filePath, String? cssStr) async {
    final cssContent = cssStr ??
        utf8.decode((await provider.getFileByPath(filePath))!.toList(),
            allowMalformed: true);

    List<TonoStyleSheetBlock> result = [];
    var stylesheet = csslib.parse(cssContent);
    for (var styleBlock in stylesheet.topLevels) {
      if (styleBlock is RuleSet) {
        final selectorPart = styleBlock.selectorGroup?.span?.text ?? '';
        if (selectorPart.isEmpty || selectorPart.contains("type*=\"check\"")) {
          continue;
        }

        // 解析 CSS 属性
        final properties = <String, String>{};
        final declarations = styleBlock.declarationGroup;

        var selector = parseSelector(selectorPart);
        for (final declaration in declarations.declarations) {
          if (declaration is! Declaration) continue; // 跳过无效声明
          if (selectorPart.contains(":hover")) {
            continue;
          }
          final property = declaration.property;

          final value = declaration.span.text
              .replaceAll(property, "")
              .replaceAll(":", "");

          //缩略声明
          if (property == 'margin') {
            properties.addAll(marginSegmentation(value));
          } else if (property == "border-width") {
            properties.addAll(borderWidthSegmentation(value));
          } else if (property == "border") {
            properties.addAll(borderDirectionSegmentation(
                value, ["left", "top", "right", "bottom"]));
          } else if (property == "border-left") {
            properties.addAll(borderDirectionSegmentation(value, ["left"]));
          } else if (property == "border-right") {
            properties.addAll(borderDirectionSegmentation(value, ["right"]));
          } else if (property == "border-top") {
            properties.addAll(borderDirectionSegmentation(value, ["top"]));
          } else if (property == "border-bottom") {
            properties.addAll(borderDirectionSegmentation(value, ["bottom"]));
          } else if (property == "border-color") {
            properties.addAll(borderColorSegmentation(value));
          } else if (property == "border-style") {
            properties.addAll(borderStyleSegmentation(value));
          } else if (property == "padding") {
            properties.addAll(paddingSegmentation(value));
          } else {
            properties[property] = value;
          }
        }
        var styleSheetBlock =
            TonoStyleSheetBlock(selector: selector, properties: properties);
        result.add(styleSheetBlock);
      }
      if (styleBlock is ImportDirective) {
        result.addAll(
            await parseCss(filePath.pathSplicing(styleBlock.import), null));
      }
    }

    return result;
  }

  Map<String, String> paddingSegmentation(String value) {
    while (value.startsWith(" ")) {
      value = value.substring(1, value.length);
    }
    final values = value.split(RegExp(r'\s+')); // 按空格分割值
    final length = values.length;
    Map<String, String> properties = {};
    String top, right, bottom, left;

    // 根据值的数量拆分 padding
    if (length == 1) {
      // 1个值：所有边都使用该值
      top = right = bottom = left = values[0];
    } else if (length == 2) {
      // 2个值：上下用第一个值，左右用第二个值
      top = bottom = values[0];
      right = left = values[1];
    } else if (length == 3) {
      // 3个值：上用第一个值，左右用第二个值，下用第三个值
      top = values[0];
      right = left = values[1];
      bottom = values[2];
    } else if (length == 4) {
      // 4个值：分别对应上、右、下、左
      top = values[0];
      right = values[1];
      bottom = values[2];
      left = values[3];
    } else {
      return properties;
    }

    // 将拆分后的值存入 properties
    properties['padding-top'] = top;
    properties['padding-right'] = right;
    properties['padding-bottom'] = bottom;
    properties['padding-left'] = left;
    return properties;
  }

  Map<String, String> borderColorSegmentation(String value) {
    // 移除前导空格
    while (value.startsWith(" ")) {
      value = value.substring(1, value.length);
    }

    // 按空格分割值
    final values = value.split(RegExp(r'\s+'));
    final length = values.length;
    Map<String, String> properties = {};
    String top, right, bottom, left;

    // 根据值的数量分配逻辑
    if (length == 1) {
      // 1 个值：所有边颜色相同
      top = right = bottom = left = values[0];
    } else if (length == 2) {
      // 2 个值：上下用第一个值，左右用第二个值
      top = bottom = values[0];
      right = left = values[1];
    } else if (length == 3) {
      // 3 个值：上、左右、下
      top = values[0];
      right = left = values[1];
      bottom = values[2];
    } else if (length == 4) {
      // 4 个值：上、右、下、左
      top = values[0];
      right = values[1];
      bottom = values[2];
      left = values[3];
    } else {
      // 无效值数量返回空 Map
      return properties;
    }

    // 填充返回值
    properties['border-top-color'] = top;
    properties['border-right-color'] = right;
    properties['border-bottom-color'] = bottom;
    properties['border-left-color'] = left;

    return properties;
  }

  Map<String, String> borderWidthSegmentation(String value) {
    while (value.startsWith(" ")) {
      value = value.substring(1, value.length);
    }
    final values = value.split(RegExp(r'\s+')); // 按空格分割值
    final length = values.length;
    Map<String, String> properties = {};
    String top, right, bottom, left;

    // 根据值的数量拆分 margin
    if (length == 1) {
      // 1个值：所有边都使用该值
      top = right = bottom = left = values[0];
    } else if (length == 2) {
      // 2个值：上下用第一个值，左右用第二个值
      top = bottom = values[0];
      right = left = values[1];
    } else if (length == 3) {
      // 3个值：上用第一个值，左右用第二个值，下用第三个值
      top = values[0];
      right = left = values[1];
      bottom = values[2];
    } else if (length == 4) {
      // 4个值：分别对应上、右、下、左
      top = values[0];
      right = values[1];
      bottom = values[2];
      left = values[3];
    } else {
      return properties;
    }

    // 将拆分后的值存入 properties
    properties['border-top-width'] = top;
    properties['border-right-width'] = right;
    properties['border-bottom-width'] = bottom;
    properties['border-left-width'] = left;
    return properties;
  }

  Map<String, String> borderStyleSegmentation(String cssDeclaration) {
    // 提取值部分并分割为列表
    final valuePart = cssDeclaration.replaceAll(';', '').trim();
    if (valuePart.isEmpty) {
      throw const FormatException("Empty value in border-style");
    }
    final values = valuePart.split(RegExp(r'\s+'));

    // 根据值的数量生成四个边的样式
    List<String> fourStyles;
    switch (values.length) {
      case 1:
        fourStyles = List.filled(4, values[0]);
        break;
      case 2:
        fourStyles = [values[0], values[1], values[0], values[1]];
        break;
      case 3:
        fourStyles = [values[0], values[1], values[2], values[1]];
        break;
      case 4:
        fourStyles = values.sublist(0, 4);
        break;
      default:
        throw FormatException('Invalid value count: ${values.length}');
    }

    // 返回各边样式
    return {
      'border-top-style': fourStyles[0],
      'border-right-style': fourStyles[1],
      'border-bottom-style': fourStyles[2],
      'border-left-style': fourStyles[3],
    };
  }

  Map<String, String> marginSegmentation(String value) {
    while (value.startsWith(" ")) {
      value = value.substring(1, value.length);
    }

    final values = value.split(RegExp(r'\s+')); // 按空格分割值
    final length = values.length;
    Map<String, String> properties = {};
    String top, right, bottom, left;
    // 根据值的数量拆分 margin
    if (length == 1) {
      // 1个值：所有边都使用该值
      top = right = bottom = left = values[0];
    } else if (length == 2) {
      // 2个值：上下用第一个值，左右用第二个值
      top = bottom = values[0];
      right = left = values[1];
    } else if (length == 3) {
      // 3个值：上用第一个值，左右用第二个值，下用第三个值
      top = values[0];
      right = left = values[1];
      bottom = values[2];
    } else if (length == 4) {
      // 4个值：分别对应上、右、下、左
      top = values[0];
      right = values[1];
      bottom = values[2];
      left = values[3];
    } else {
      return properties;
    }
    // 将拆分后的值存入 properties
    properties['margin-top'] = top;
    properties['margin-right'] = right;
    properties['margin-bottom'] = bottom;
    properties['margin-left'] = left;
    return properties;
  }

  Map<String, String> borderDirectionSegmentation(
    String borderValue,
    List<String> sides,
  ) {
    const widthKeywords = {'thin', 'medium', 'thick'};
    const styleKeywords = {
      'none',
      'hidden',
      'dotted',
      'dashed',
      'solid',
      'double',
      'groove',
      'ridge',
      'inset',
      'outset'
    };
    const cssColorKeywords = {
      'black': '#000',
      'white': '#fff',
      'red': '#f00',
      'green': '#080',
      'blue': '#00f',
      'yellow': '#ff0',
      'gray': '#888',
    };

    String parseColor(String colorStr) {
      colorStr = colorStr.toLowerCase();
      if (cssColorKeywords.containsKey(colorStr)) {
        return cssColorKeywords[colorStr]!;
      }
      return colorStr;
    }

    bool isWidth(String token) {
      token = token.toLowerCase();
      if (widthKeywords.contains(token)) return true;
      return RegExp(r'^\d+\.?\d*(px|em|rem|pt|in|cm|mm)$').hasMatch(token);
    }

    bool isStyle(String token) => styleKeywords.contains(token.toLowerCase());

    // 处理输入字符串
    String normalized = borderValue.replaceAll('border:', '').trim();
    List<String> tokens = normalized.split(RegExp(r'\s+'));
    String? widthVal;
    String? styleVal;
    String? colorVal;

    for (String token in tokens) {
      if (widthVal == null && isWidth(token)) {
        widthVal = token;
      } else if (styleVal == null && isStyle(token)) {
        styleVal = token;
      } else {
        colorVal = colorVal ?? token;
      }
    }

    // 设置默认值
    widthVal ??= '0';
    styleVal ??= 'none';
    colorVal ??= '#000';

    // 转换颜色
    String parsedColor = colorVal.isEmpty ? '#000' : parseColor(colorVal);

    // 生成所有边的属性
    Map<String, String> result = {};
    for (var side in sides) {
      result['border-$side-width'] = widthVal;
      result['border-$side-style'] = styleVal;
      result['border-$side-color'] = parsedColor;
    }

    return result;
  }
}
