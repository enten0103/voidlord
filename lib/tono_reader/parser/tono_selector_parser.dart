import 'package:voidlord/tono_reader/model/parser/tono_selector_group.dart';
import 'package:voidlord/tono_reader/model/parser/tono_selector_info.dart';
import 'package:voidlord/tono_reader/model/parser/tono_selector_part.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';

extension TonoSelectorParser on TonoParser {
  TonoSelectorInfo parseSelector(String selector) {
    TonoSelectorInfo info = TonoSelectorInfo();

    // 处理选择器列表
    selector.split(',').map((s) => s.trim()).forEach((s) {
      TonoSelectorGroup group = TonoSelectorGroup();
      var extracted = _extractAttributes(s);
      String replaced = extracted[0] as String;
      List<String> attributes = extracted[1] as List<String>;

      var splitResult = _splitCombinators(replaced);
      List<String> rawParts = splitResult[0] as List<String>;
      List<String> combinators = splitResult[1] as List<String>;

      List<String> parts =
          rawParts.map((p) => _restoreAttributes(p, attributes)).toList();

      group.parts = parts.map((p) => _parseSimpleSelector(p)).toList();
      group.combinators = combinators;
      info.groups.add(group);
    });

    return info;
  }

  List<dynamic> _extractAttributes(String selector) {
    final attrPattern = RegExp(r'\[.*?\]');
    var attributes = <String>[];
    var replaced = selector.replaceAllMapped(attrPattern, (match) {
      attributes.add(match.group(0)!);
      return '__ATTR_${attributes.length - 1}__';
    });
    return [replaced, attributes];
  }

  List<dynamic> _splitCombinators(String selectorPart) {
    final pattern = RegExp(r'(\s*>\s*|\s*\+\s*|\s*\~\s*|\s+)');
    var matches = pattern.allMatches(selectorPart);
    List<String> parts = [];
    List<String> combinators = [];
    int lastEnd = 0;

    for (var match in matches) {
      if (match.start > lastEnd) {
        parts.add(selectorPart.substring(lastEnd, match.start));
      }
      String comb = match.group(0)!;
      String trimmedComb = comb.trim();
      if (trimmedComb == '>') {
        combinators.add('child');
      } else if (trimmedComb == '+') {
        combinators.add('next-sibling');
      } else if (trimmedComb == '~') {
        combinators.add('general-sibling');
      } else {
        combinators.add('descendant');
      }
      lastEnd = match.end;
    }
    if (lastEnd < selectorPart.length) {
      parts.add(selectorPart.substring(lastEnd));
    }

    return [parts, combinators];
  }

  String _restoreAttributes(String part, List<String> attributes) {
    final attrPlaceholder = RegExp(r'__ATTR_(\d+)__');
    return part.replaceAllMapped(attrPlaceholder, (match) {
      int index = int.parse(match.group(1)!);
      return attributes[index];
    });
  }

  TonoSelectorPart _parseSimpleSelector(String part) {
    TonoSelectorPart components = TonoSelectorPart();

    // 处理通用选择器
    if (part == '*') {
      components.isUniversal = true;
      return components;
    }

    // 处理元素选择器
    final elementReg = RegExp(r'^[a-zA-Z_][\w-]*');
    var elementMatch = elementReg.firstMatch(part);
    if (elementMatch != null) {
      components.element = elementMatch.group(0);
    }

    // 处理ID选择器
    final idReg = RegExp(r'#([\w-]+)');
    var idMatch = idReg.firstMatch(part);
    if (idMatch != null) {
      components.id = idMatch.group(1);
    }

    // 处理类选择器
    final classReg = RegExp(r'\.([\w-]+)');
    components.classes =
        classReg.allMatches(part).map((m) => m.group(1)!).toList();

    // 处理属性选择器
    final attrReg = RegExp(r'\[.*?\]');
    components.attributes =
        attrReg.allMatches(part).map((m) => m.group(0)!).toList();
    // 伪类解析
    final pseudoClassReg = RegExp(r':([\w-]+)');
    List<String> pseudoClasses =
        pseudoClassReg.allMatches(part).map((m) => m.group(1)!).toList();
    components.pseudos = pseudoClasses;
    return components;
  }
}
