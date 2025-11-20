import 'package:html/dom.dart';
import 'package:voidlord/tono_reader/model/parser/tono_style_sheet_block.dart';
import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/model/widget/tono_ruby.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_selector_macher.dart';

extension RubyParser on TonoParser {
  TonoWidget toRuby(
    Element element,
    List<TonoStyleSheetBlock> css, {
    List<TonoStyle>? inheritStyles,
  }) {
    var matchedCss = matchAll(element, css, inheritStyles);
    try {
      var rb = element.getElementsByTagName('rb').toList();
      var rt = element.getElementsByTagName('rt').toList();
      List<RubyItem> texts = [];
      for (var i = 0; i < rb.length; i++) {
        texts.add(RubyItem(
          text: rb[i].text,
          ruby: i < rt.length ? rt[i].text : null,
        ));
      }
      return TonoRuby(
        css: matchedCss,
        texts: texts,
      );
    } catch (_) {
      return TonoRuby(
        css: matchedCss,
        texts: [RubyItem(text: element.text)],
      );
    }
  }
}
