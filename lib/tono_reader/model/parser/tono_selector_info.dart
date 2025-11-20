import 'package:voidlord/tono_reader/model/parser/tono_selector_group.dart';

class TonoSelectorInfo {
  List<TonoSelectorGroup> groups = [];

  @override
  String toString() {
    return groups.map((g) => g.toString()).join(', ');
  }
}
