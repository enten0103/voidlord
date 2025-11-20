import 'package:voidlord/tono_reader/model/base/tono_location.dart';

class TonoNote {
  TonoLocation location;
  String text;
  TonoNote({
    required this.location,
    required this.text,
  });
  Map<String, dynamic> toMap() {
    return {
      "location": location.toMap(),
      "text": text,
    };
  }

  static TonoNote fromMap(Map<String, dynamic> map) {
    return TonoNote(
      location: TonoLocation.fromMap(map['location']),
      text: map['text'] as String,
    );
  }
}
