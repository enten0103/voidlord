import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';

class FontSpeaceSetting extends StatelessWidget {
  const FontSpeaceSetting({super.key});

  @override
  Widget build(BuildContext context) {
    TonoReaderConfig config = Get.find();
    var lineSpacing = config.lineSpacing.obs;

    return Row(
      children: [
        IconButton(
            onPressed: () {
              lineSpacing.value -= 0.25;
              config.setLineSpacing(lineSpacing.value);
            },
            icon: Icon(Icons.unfold_more)),
        Expanded(
            child: Obx(() => Slider(
                  min: 0.5,
                  label: lineSpacing.toStringAsFixed(2),
                  max: 2,
                  value: lineSpacing.value < 0.5
                      ? 0.5
                      : lineSpacing.value > 2
                          ? 2
                          : lineSpacing.value,
                  divisions: 6,
                  onChanged: (v) {
                    lineSpacing.value = v;
                  },
                  onChangeEnd: config.setLineSpacing,
                ))),
        IconButton(
            onPressed: () {
              lineSpacing.value += 0.25;
              config.setLineSpacing(lineSpacing.value);
            },
            icon: Icon(Icons.unfold_less)),
        IconButton(
            onPressed: () {
              lineSpacing.value = 1;
              config.setLineSpacing(lineSpacing.value);
            },
            icon: Icon(Icons.refresh_outlined)),
      ],
    );
  }
}
