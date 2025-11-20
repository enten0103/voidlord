import 'package:voidlord/tono_reader/model/base/tono_book_info.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/tool/path_tool.dart';

import 'package:html/parser.dart' as html;
import 'package:voidlord/tono_reader/tool/unit8_tool.dart';

extension TonoBwNcxParser on TonoParser {
  Future<List<TonoNavItem>> parseBwNcx(String nxcPath) async {
    var currentDir = nxcPath;
    var ncxFile = await provider.getFileByPath(nxcPath);
    var document = html.parse(ncxFile!.toUtf8());
    var nav = document.getElementsByTagName("nav").first;

    var navPoints = nav.getElementsByTagName("a");
    return navPoints.map((e) {
      var title = e.text;
      var src = e.attributes["href"]!;
      var path = currentDir.pathSplicing(src);
      return TonoNavItem(path: path, title: title);
    }).toList();
  }
}
