import 'package:voidlord/tono_reader/model/parser/tono_selector_part.dart';

class TonoSelectorGroup {
  List<TonoSelectorPart> parts = [];
  List<String> combinators = [];
  int get specificity {
    int result = 0;
    for (var part in parts) {
      result += part.idCount * 100;
      result += (part.classCount + part.attributeCount) * 10;
      result += part.elementCount;
    }
    return result;
  }

  @override
  String toString() {
    String result = '';
    for (int i = 0; i < parts.length; i++) {
      result += parts[i].toString();
      if (i < combinators.length) {
        result += ' (${combinators[i]}) ';
      }
    }
    return result;
  }
}
