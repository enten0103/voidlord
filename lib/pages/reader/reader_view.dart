import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voidlord/pages/reader/reader_controller.dart';
import 'package:voidlord/tono_reader/model/base/tono_type.dart';
import 'package:voidlord/tono_reader/view.dart';

class ReaderPage extends GetView<ReaderController> {
  const ReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return switch (controller.type.value) {
      "local" => TonoReader(id: controller.id.value, tonoType: TonoType.local),
      _ => Text("")
    };
  }
}
