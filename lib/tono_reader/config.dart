import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/model/config.dart';
import 'package:voidlord/tono_reader/tool/lightness.dart';

class TonoReaderConfig extends GetxController {
  ///翻页方式
  PageTurningMethod pageTurningMethod = PageTurningMethod.turn;

  Color? backGroundColor;

  ///自定义文字颜色
  String? fontColor;

  ///自定义字体
  String? customFont;

  ///字间距
  double wordSpacing = 0.25;

  ///字体大小
  double fontSize = 18;

  ///行间距
  double lineSpacing = 1;

  ///是否启用行首缩进
  bool indentationEnable = true;

  ///ruby大小
  double rubySize = 0.5;

  //markder颜色
  Color markerColor = Color.fromARGB(230, 192, 54, 69);

  ///视口设置
  ViewPortConfig viewPortConfig =
      ViewPortConfig(left: 25, right: 25, top: 40, bottom: 40);

  Rx<Lightness> lightness =
      (Get.isDarkMode ? Lightness.dark : Lightness.light).obs;

  setWordSpacing(double newSpace) {
    if (newSpace < 0.25) {
      return;
    }
    wordSpacing = newSpace;
    update();
  }

  setLineSpacing(double newSpace) {
    if (newSpace < 0.25) {
      return;
    }
    lineSpacing = newSpace;
    update();
  }

  setFontSize(double newFontSize) {
    if (newFontSize < 2) {
      return;
    }
    fontSize = newFontSize;
    update();
  }

  Future toggleLightNess() async {
    if (lightness.value == Lightness.dark) {
      Get.changeThemeMode(ThemeMode.light);
      lightness.value = Lightness.light;
    } else {
      Get.changeThemeMode(ThemeMode.dark);
      lightness.value = Lightness.dark;
    }
    await Future.delayed(Duration(milliseconds: 200));
    update();
  }

  static init() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
        overlays: []);
  }

  static close() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
