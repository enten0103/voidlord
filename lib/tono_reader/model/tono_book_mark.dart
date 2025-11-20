import 'package:voidlord/tono_reader/model/base/tono_location.dart';

class TonoBookMark {
  String description;
  TonoLocation location;
  DateTime createTime;
  TonoBookMark({
    required this.description,
    required this.location,
    required this.createTime,
  });

  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "location": location.toJson(),
      "createTime": createTime.millisecondsSinceEpoch,
    };
  }

  static TonoBookMark fromJson(Map<String, dynamic> json) {
    return TonoBookMark(
      description: json['description'] as String,
      location: TonoLocation.fromMap(json['location']),
      createTime:
          DateTime.fromMillisecondsSinceEpoch(json['createTime'] as int),
    );
  }
}
