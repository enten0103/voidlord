import 'package:flutter/material.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';
import 'package:voidlord/tono_reader/tool/styled_border.dart';

extension TonoCssBorder on FlutterStyleFromCss {
  StyledBorder parseBorder(Map<String, String> css) {
    BorderCustomStyle parseBorderStyle(String? style) {
      if (style == null) return BorderCustomStyle.solid;
      if (style == "dotted") return BorderCustomStyle.dotted;
      if (style == "dashed") return BorderCustomStyle.dashed;
      return BorderCustomStyle.solid;
    }

    StyledBorderSide? parseBorderSize(String side) {
      var borderStyle = css['border-$side-style']?.toValue();
      var borderWidth = css['border-$side-width']?.toValue() ?? "2";
      var borderColorStr = css['border-$side-color']?.toValue();
      if (borderStyle == null ||
          borderStyle == "0" ||
          borderWidth == "0px" ||
          borderWidth == "0em" ||
          borderWidth == "0%") {
        return StyledBorderSide(width: 0);
      }
      Color borderColor = Colors.black;
      if (borderColorStr != null) {
        borderColor = parseColor(borderColorStr) ?? Colors.black;
      }
      var style = parseBorderStyle(borderStyle);
      if (side == "left" || side == "right") {
        return StyledBorderSide(
            borderStyle: style,
            color: borderColor,
            width: parseUnit(borderWidth, parentSize?.width, em));
      } else {
        return StyledBorderSide(
            borderStyle: style,
            color: borderColor,
            width: parseUnit(borderWidth, parentSize?.height, em));
      }
    }

    var left = parseBorderSize("left");
    var right = parseBorderSize("right");
    var top = parseBorderSize("top");
    var bottom = parseBorderSize("bottom");
    return StyledBorder(
      top: top ?? StyledBorderSide(width: 0),
      bottom: bottom ?? StyledBorderSide(width: 0),
      left: left ?? StyledBorderSide(width: 0),
      right: right ?? StyledBorderSide(width: 0),
    );
  }
}
