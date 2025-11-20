import 'dart:typed_data';

import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/widget_provider/local_tono_widget_provider.dart';

abstract class TonoWidgetProvider {
  ///通过id获取widget
  Future<TonoWidget> getWidgetsById(String id);

  ///通过id获取资源
  Future<Uint8List> getAssetsById(String id);

  ///获取全部字体
  Future<Map<String, Uint8List>> getAllFont();
  Future<Map<String, dynamic>> toMap();
  static Future<TonoWidgetProvider> formMap(Map<String, dynamic> map) async {
    if (map['_type'] == "LocalTonoWidgetProvider") {
      return await LocalTonoWidgetProvider.fromMap(map);
    } else {
      throw Error();
    }
  }
}
