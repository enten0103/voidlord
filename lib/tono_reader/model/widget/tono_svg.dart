import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';

class TonoSvg extends TonoWidget {
  TonoSvg({
    required this.src,
    required super.css,
  }) : super(className: "svg", display: "inline");
  final String src;

  static TonoSvg fromMap(Map<String, dynamic> map) {
    return TonoSvg(
        src: map['src'] as String,
        css: (map['css'] as List).map((e) => TonoStyle.formMap(e)).toList());
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "_type": "tonoSvg",
      'src': src,
      "css": css.map((item) => item.toMap()).toList(),
    };
  }
}
