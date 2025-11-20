import 'package:html/dom.dart';
import 'package:voidlord/tono_reader/model/parser/tono_style_sheet_block.dart';
import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/model/widget/tono_image.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_selector_macher.dart';
import 'package:voidlord/tono_reader/tool/path_tool.dart';

extension ImgParser on TonoParser {
  TonoWidget toImg(
    Element element,
    String currentPath,
    List<TonoStyleSheetBlock> css, {
    List<TonoStyle>? inheritStyles,
  }) {
    var matchedCss = matchAll(element, css, inheritStyles);
    var imageUrl = "";
    var imageSrc = element.attributes['src'];
    if (imageSrc != null) {
      imageUrl = currentPath.pathSplicing(imageSrc);
    }
    return TonoImage(url: imageUrl, css: matchedCss);
  }
}
