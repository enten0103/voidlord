import 'dart:math' as math;
import 'dart:ui';

import 'package:get/instance_manager.dart';
import 'package:voidlord/tono_reader/config.dart';
import 'package:voidlord/tono_reader/tool/lightness.dart';

extension ColorTool on Color {
  Color applyLightness() {
    if (Get.find<TonoReaderConfig>().lightness.value == Lightness.light) {
      return this;
    }
    return Color.fromARGB(
      (a * 255).toInt(),
      255 - (r * 255).toInt(),
      255 - (g * 255).toInt(),
      255 - (b * 255).toInt(),
    );
  }

  List<double> rgbToHsl(double r, double g, double b) {
    final max = [r, g, b].reduce(math.max);
    final min = [r, g, b].reduce(math.min);
    double h = 0, s = 0, l = (max + min) / 2;

    if (max != min) {
      final d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

      if (max == r) {
        h = (g - b) / d + (g < b ? 6 : 0);
      } else if (max == g) {
        h = (b - r) / d + 2;
      } else {
        h = (r - g) / d + 4;
      }
      h /= 6;
    }

    return [h, s, l];
  }

  List<double> hslToRgb(double h, double s, double l) {
    double r, g, b;

    if (s == 0) {
      r = g = b = l; // 灰度
    } else {
      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = _hueToRgb(p, q, h + 1 / 3);
      g = _hueToRgb(p, q, h);
      b = _hueToRgb(p, q, h - 1 / 3);
    }

    return [r, g, b];
  }

  double _hueToRgb(double p, double q, double t) {
    final tt = t < 0
        ? t + 1
        : t > 1
            ? t - 1
            : t;
    if (tt < 1 / 6) return p + (q - p) * 6 * tt;
    if (tt < 1 / 2) return q;
    if (tt < 2 / 3) return p + (q - p) * (2 / 3 - tt) * 6;
    return p;
  }
}
