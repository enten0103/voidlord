import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';

class FontWordspaceSetting extends StatelessWidget {
  const FontWordspaceSetting({super.key});

  @override
  Widget build(BuildContext context) {
    TonoReaderConfig config = Get.find();
    var wordSpacing = config.wordSpacing.obs;

    return Row(
      children: [
        IconButton(
            onPressed: () {
              wordSpacing.value += 1;
              config.setWordSpacing(wordSpacing.value);
            },
            icon: Transform.rotate(
                angle: math.pi / 2, child: Icon(Icons.unfold_more))),
        Expanded(
            child: Obx(() => Slider(
                  min: 0.25,
                  label: wordSpacing.toStringAsFixed(2),
                  max: 5.25,
                  value: wordSpacing.value < 0.25
                      ? 0.25
                      : wordSpacing.value > 5.25
                          ? 5.25
                          : wordSpacing.value,
                  divisions: 5,
                  onChanged: (v) {
                    wordSpacing.value = v;
                  },
                  onChangeEnd: config.setWordSpacing,
                ))),
        IconButton(
            onPressed: () {
              wordSpacing.value += 1;
              config.setWordSpacing(wordSpacing.value);
            },
            icon: Transform.rotate(
                angle: math.pi / 2, child: Icon(Icons.unfold_less))),
        IconButton(
            onPressed: () {
              wordSpacing.value = 0.25;
              config.setWordSpacing(wordSpacing.value);
            },
            icon: Icon(Icons.refresh_outlined)),
      ],
    );
  }
}
