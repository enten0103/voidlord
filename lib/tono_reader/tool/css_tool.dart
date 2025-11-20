import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/model/style/tono_style.dart';

extension CssTool on List<TonoStyle> {
  Map<String, String> toMap() {
    Map<String, String> result = {};
    forEach((e) {
      result[e.property] = e.value;
    });
    return result;
  }

  double getFontSize() {
    var config = Get.find<TonoReaderConfig>();
    return parseUnit(
        toMap()['font-size']!, Get.mediaQuery.size.width, config.fontSize);
  }
}

Color? parseColor(String colorStr) {
  final normalized = colorStr
      .replaceAll(RegExp(r'[#!important]', caseSensitive: false), '')
      .trim()
      .toLowerCase();

  // 处理颜色名称
  if (_colorNameToHex.containsKey(normalized)) {
    return _parseHex('FF${_colorNameToHex[normalized]}');
  }

  // 处理RGB/RGBA
  if (normalized.startsWith('rgb')) {
    return _parseRgb(normalized);
  }

  // 处理十六进制
  return _parseHex(normalized);
}

Color? _parseHex(String hex) {
  hex = hex.toUpperCase();

  if (hex.length == 3) {
    hex = hex.split('').map((c) => c + c).join();
    hex = 'FF$hex';
  } else if (hex.length == 6) {
    hex = 'FF$hex';
  }

  if (hex.length != 8) return null;

  try {
    return Color(int.parse(hex, radix: 16));
  } catch (e) {
    return null;
  }
}

Color? _parseRgb(String rgbStr) {
  final params =
      rgbStr.replaceAll(RegExp(r'^rgba?\(|\)$', caseSensitive: false), '');
  final parts = params.split(',').map((s) => s.trim()).toList();

  if (parts.length != 3 && parts.length != 4) return null;

  final r = _parseColorValue(parts[0]);
  final g = _parseColorValue(parts[1]);
  final b = _parseColorValue(parts[2]);
  if (r == null || g == null || b == null) return null;

  double a = 1.0;
  if (parts.length == 4) {
    final parsedA = _parseAlphaValue(parts[3]);
    if (parsedA == null) return null;
    a = parsedA;
  }

  final alphaHex = (a * 255).round().toRadixString(16).padLeft(2, '0');
  final hex = alphaHex +
      r.toRadixString(16).padLeft(2, '0') +
      g.toRadixString(16).padLeft(2, '0') +
      b.toRadixString(16).padLeft(2, '0');

  return _parseHex(hex);
}

int? _parseColorValue(String part) {
  try {
    if (part.endsWith('%')) {
      final percent = double.parse(part.substring(0, part.length - 1));
      return (percent / 100 * 255).round().clamp(0, 255);
    }
    return int.parse(part).clamp(0, 255);
  } catch (e) {
    return null;
  }
}

double? _parseAlphaValue(String part) {
  try {
    if (part.endsWith('%')) {
      return double.parse(part.substring(0, part.length - 1)) / 100;
    }
    return double.parse(part).clamp(0.0, 1.0);
  } catch (e) {
    return null;
  }
}

const _colorNameToHex = {
  'black': '000000',
  'white': 'ffffff',
  'red': 'ff0000',
  'lime': '00ff00',
  'blue': '0000ff',
  'yellow': 'ffff00',
  'cyan': '00ffff',
  'magenta': 'ff00ff',
  'silver': 'c0c0c0',
  'gray': '808080',
  'maroon': '800000',
  'olive': '808000',
  'green': '008000',
  'purple': '800080',
  'teal': '008080',
  'navy': '000080',
  'orange': 'ffa500',
};
double parseUnit(String cssUnit, double parent, double em) {
  cssUnit = cssUnit.replaceAll("!important", "");
  if (cssUnit.contains('em')) {
    double emValue = double.parse(cssUnit.replaceAll('em', '')) * em;
    return emValue;
  } else if (cssUnit.contains('px')) {
    double pxValue = double.parse(cssUnit.replaceAll('px', ''));
    return pxValue;
  } else if (cssUnit.contains('%')) {
    double percentage = double.parse(cssUnit.replaceAll('%', ''));
    return parent * percentage / 100.0;
  } else if (cssUnit.contains('vh')) {
    double vhValue = double.parse(cssUnit.replaceAll('vh', ''));
    return Get.mediaQuery.size.height * vhValue / 100;
  } else if (cssUnit.contains("vw")) {
    double vwValue = double.parse(cssUnit.replaceAll('vw', ''));
    return Get.mediaQuery.size.height * vwValue / 100;
  } else {
    return double.parse(cssUnit);
  }
}
