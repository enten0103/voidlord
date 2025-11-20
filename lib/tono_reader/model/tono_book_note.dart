import 'package:voidlord/tono_reader/model/base/tono_location.dart';

class TonoBookNote {
  String description;
  String note;
  TonoLocation location;
  DateTime createTime;
  TonoBookNote({
    required this.description,
    required this.note,
    required this.location,
    required this.createTime,
  });
  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "note": note,
      "location": location.toJson(),
      "createTime": createTime.millisecondsSinceEpoch,
    };
  }

  static TonoBookNote fromJson(Map<String, dynamic> json) {
    return TonoBookNote(
      description: json['description'] as String,
      note: json['note'] as String,
      location: TonoLocation.fromMap(json['location']),
      createTime:
          DateTime.fromMillisecondsSinceEpoch(json['createTime'] as int),
    );
  }
}
