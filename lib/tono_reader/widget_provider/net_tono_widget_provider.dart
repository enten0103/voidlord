import 'dart:typed_data';

import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/widget_provider/tono_widget_provider.dart';

class NetTonoWidgetProvider extends TonoWidgetProvider {
  String hash;

  NetTonoWidgetProvider({
    required this.hash,
  });

  @override
  Future<Map<String, Uint8List>> getAllFont() {
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> getAssetsById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<TonoWidget> getWidgetsById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> toMap() {
    throw UnimplementedError();
  }
}
