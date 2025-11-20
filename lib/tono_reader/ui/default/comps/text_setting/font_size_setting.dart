import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/tono_reader/config.dart';

class FontSizeSetting extends StatelessWidget {
  const FontSizeSetting({super.key});

  @override
  Widget build(BuildContext context) {
    TonoReaderConfig config = Get.find();
    var fontsize = config.fontSize.obs;

    return Row(
      children: [
        IconButton(
            onPressed: () {
              fontsize.value -= 2;
              config.setFontSize(fontsize.value);
            },
            icon: Icon(Icons.text_decrease)),
        Expanded(
            child: Obx(() => Slider(
                  min: 12,
                  label: fontsize.toInt().toString(),
                  max: 24,
                  value: fontsize.value < 12
                      ? 12
                      : fontsize.value > 24
                          ? 24
                          : fontsize.value,
                  divisions: 6,
                  onChanged: (v) {
                    fontsize.value = v;
                  },
                  onChangeEnd: config.setFontSize,
                ))),
        IconButton(
            onPressed: () {
              fontsize.value += 2;
              config.setFontSize(fontsize.value);
            },
            icon: Icon(Icons.text_increase)),
        IconButton(
            onPressed: () {
              fontsize.value = 18;
              config.setFontSize(fontsize.value);
            },
            icon: Icon(Icons.refresh)),
      ],
    );
  }
}
