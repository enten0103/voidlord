import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_image.dart';
import 'package:voidlord/tono_reader/model/widget/tono_ruby.dart';
import 'package:voidlord/tono_reader/model/widget/tono_svg.dart';
import 'package:voidlord/tono_reader/model/widget/tono_text.dart';

abstract class TonoWidget {
  TonoWidget({
    required this.className,
    required this.css,
    required this.display,
    this.parent,
  });
  TonoWidget? parent;
  List<TonoStyle> css;
  String className;
  String? display;
  Map<String, dynamic> extra = {};

  Map<String, dynamic> toMap();

  static TonoWidget fromMap(Map<String, dynamic> map) {
    var type = map['_type'];
    return switch (type) {
      "tonoContainer" => TonoContainer.fromMap(map),
      "tonoImage" => TonoImage.fromMap(map),
      "tonoRuby" => TonoRuby.formMap(map),
      "tonoText" => TonoText.formMap(map),
      "tonoSvg" => TonoSvg.fromMap(map),
      _ => throw Error()
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
