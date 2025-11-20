import 'package:voidlord/tono_reader/model/parser/tono_selector_info.dart';

class TonoStyleSheetBlock {
  TonoStyleSheetBlock({
    required this.selector,
    required this.properties,
  });

  TonoSelectorInfo selector;
  Map<String, String> properties;
}
