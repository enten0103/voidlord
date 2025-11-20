import 'dart:convert';
import 'dart:typed_data';

extension Unit8Tool on Uint8List {
  String toUtf8() {
    return utf8.decode(toList(), allowMalformed: true);
  }
}
