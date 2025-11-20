import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';

class TonoContainer extends TonoWidget {
  TonoContainer({
    required super.className,
    required super.css,
    required super.display,
    required this.children,
  });

  ///block/inline

  ///子元素
  List<TonoWidget> children;

  static TonoContainer fromMap(Map<String, dynamic> css) {
    return TonoContainer(
        className: css['className'] as String,
        display: css['display'] as String,
        css: (css['css'] as List).map((e) => TonoStyle.formMap(e)).toList(),
        children: (css['children'] as List?)
                ?.map((e) => TonoWidget.fromMap(e))
                .toList() ??
            []);
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      "_type": "tonoContainer",
      "className": className,
      "css": css.map((item) => item.toMap()).toList(),
      "display": display,
      "children": children.map((item) => item.toMap()).toList(),
    };
  }
}
