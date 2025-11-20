import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';

extension TonoScrollableWindowParser on TonoParser {
  int calcScrollableDeepth(
      Map<String, TonoWidget> weights, List<String> xhtmls) {
    int deepth = getDeepth(weights[xhtmls[0]]!);
    for (int i = 1; i < xhtmls.length; i++) {
      var xhtml = xhtmls[i];
      var newDeepth = getDeepth(weights[xhtml]!);
      deepth = newDeepth < deepth ? newDeepth : deepth;
    }
    return deepth;
  }

  int getDeepth(TonoWidget widget) {
    int deepth = 0;
    while (widget is TonoContainer && widget.children.length == 1) {
      deepth++;
      widget = widget.children[0];
    }
    return deepth;
  }
}
