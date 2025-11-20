import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';

class RubyItem {
  RubyItem({
    required this.text,
    this.ruby,
  });
  final String text;
  final String? ruby;
  static RubyItem formMap(Map<String, dynamic> map) {
    return RubyItem(text: map['text'], ruby: map['ruby']);
  }

  Map<String, dynamic> toMap() {
    return {
      "text": text,
      "ruby": ruby,
    };
  }
}

class TonoRuby extends TonoWidget {
  TonoRuby({
    required super.css,
    required this.texts,
  }) : super(className: "ruby", display: "inline");
  final List<RubyItem> texts;
  @override
  Map<String, dynamic> toMap() {
    return {
      "_type": "tonoRuby",
      "className": className,
      "css": css.map((e) => e.toMap()).toList(),
      "texts": texts.map((e) => e.toMap()).toList()
    };
  }

  static TonoRuby formMap(Map<String, dynamic> map) {
    return TonoRuby(
      css: List.from(map['css'].map((e) => TonoStyle.formMap(e)).toList()),
      texts: List<RubyItem>.from(
          map['texts'].map((e) => RubyItem.formMap(e)).toList()),
    );
  }
}
