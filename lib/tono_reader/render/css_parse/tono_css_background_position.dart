import 'package:flutter/widgets.dart';
import 'package:voidlord/tono_reader/render/css_parse/tono_css_converter.dart';

extension TonoCssBackgroundPosition on FlutterStyleFromCss {
  AlignmentGeometry? parseBackgorundPosition(String? raw) {
    var cssBgp = raw?.toValue();
    if (cssBgp == null) return null;
    if (cssBgp.contains("center")) {
      if (cssBgp.contains("left")) {
        return Alignment.centerLeft;
      }
      if (cssBgp.contains("right")) {
        return Alignment.centerRight;
      }
      if (cssBgp.contains("top")) {
        return Alignment.topCenter;
      }
      if (cssBgp.contains("bottom")) {
        return Alignment.bottomCenter;
      }
      return Alignment.center;
    }
    if (cssBgp.contains("bottom")) {
      if (cssBgp.contains("left")) {
        return Alignment.bottomLeft;
      }
      if (cssBgp.contains("right")) {
        return Alignment.bottomRight;
      }
      return Alignment.bottomLeft;
    }
    if (cssBgp.contains("top")) {
      if (cssBgp.contains("left")) {
        return Alignment.topLeft;
      }
      if (cssBgp.contains("right")) {
        return Alignment.topRight;
      }
    }
    return Alignment.centerLeft;
  }
}
