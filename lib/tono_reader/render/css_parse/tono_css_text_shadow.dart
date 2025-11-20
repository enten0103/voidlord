import 'package:flutter/material.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssTextShadow on FlutterStyleFromCss {
  Shadow? parseTextShadow(String? textShadow) {
    if (textShadow == null) return null;
    var shadowSplit = textShadow.split(" ");
    var xOffset = parseUnit(shadowSplit[0], parentSize?.width, em);
    var yOffset = parseUnit(shadowSplit[1], parentSize?.height, em);
    var blurRadius = parseUnit(shadowSplit[2], parentSize?.width, em);

    var color = parseColor(shadowSplit[3]);
    return Shadow(
        color: color ?? Colors.black,
        offset: Offset(xOffset, yOffset),
        blurRadius: blurRadius);
  }
}
