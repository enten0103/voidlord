import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:voidlord/tono_reader/model/base/tono.dart';
import 'package:voidlord/tono_reader/model/base/tono_book_info.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/parser/tono_bw_ncx_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_parse_event.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_scrollable_window_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_widget_parser.dart';
import 'package:voidlord/tono_reader/tool/path_tool.dart';
import 'package:voidlord/tono_reader/tool/unit8_tool.dart';
import 'package:voidlord/tono_reader/widget_provider/local_tono_widget_provider.dart';
import 'package:xml/xml.dart';

extension TonoOpfParser on TonoParser {
  Future<Tono> parseOpf(String opfPath) async {
    emit(TonoParseEvent(info: "opf", currentIndex: 0, totalIndex: 1));
    var currentDir = opfPath;
    var xmlContent = (await provider.getFileByPath(currentDir))!.toUtf8();
    var document = XmlDocument.parse(xmlContent);
    var manifest = document.findAllElements("manifest").first;
    var title = document.findAllElements("dc:title").first.innerText;
    emit(TonoParseEvent(info: "opf", currentIndex: 1, totalIndex: 1));
    var parseItemResult = await parseItem(manifest, currentDir);
    TonoBookInfo tonoBookInfo =
        TonoBookInfo(title: title, coverUrl: parseItemResult[4]);
    List<TonoNavItem> tonoNavItems = parseItemResult[3];
    var ltwp = LocalTonoWidgetProvider(
        hash: provider.hash,
        widgets: parseItemResult[0],
        images: parseItemResult[1],
        fonts: parseItemResult[2]);
    var spine = document.findAllElements("spine").first;
    var xhtmls = await parseXhtmlList(
      spine,
      parseItemResult[5],
      currentDir,
    );
    var scrollDeepth = calcScrollableDeepth(parseItemResult[0], xhtmls);
    return Tono(
      bookInfo: tonoBookInfo,
      navItems: tonoNavItems,
      deepth: scrollDeepth,
      widgetProvider: ltwp,
      xhtmls: xhtmls,
      hash: provider.hash,
    );
  }

  Future<List<String>> parseXhtmlList(
      XmlElement spine, Map<String, String> idmap, String currentDir) async {
    var items = spine.findAllElements('itemref');
    List<String> result = [];
    for (var item in items) {
      if (item.getAttribute('linear') != "no") {
        var idref = item.getAttribute("idref");
        if (idref != null) {
          result.add(idmap[idref]!);
        }
      }
    }
    return result;
  }

  Future<List<dynamic>> parseItem(
      XmlElement manifest, String currentDir) async {
    Map<String, TonoWidget> widgets = {};
    Map<String, Uint8List> images = {};
    Map<String, Uint8List> fonts = {};

    List<TonoNavItem> navItems = [];
    String coverUrl = "";
    Map<String, String> idmap = {};
    var items = manifest.findAllElements("item").toList();
    for (int index = 0; index < items.length; index++) {
      var item = items[index];
      var href = item.getAttribute("href");
      if (href == null) continue;
      var fullPath = currentDir.pathSplicing(href);
      emit(TonoParseEvent(
        info: href,
        currentIndex: index,
        totalIndex: items.length,
      ));
      if (href.endsWith("xhtml")) {
        idmap[item.getAttribute("id")!] = fullPath;
        widgets[fullPath] = await parseWidget(fullPath);
      }
      if (item.getAttribute("media-type")?.startsWith("image") ?? false) {
        if (item.getAttribute("id")?.startsWith("cover") ?? false) {
          coverUrl = p.basenameWithoutExtension(fullPath);
        }
        images[p.basenameWithoutExtension(fullPath)] =
            (await provider.getFileByPath(fullPath))!;
      }
      if (item.getAttribute("media-type")?.contains("font") ?? false) {
        fonts[p.basenameWithoutExtension(fullPath)] =
            (await provider.getFileByPath(fullPath))!;
      }
      if (navItems.isEmpty && href.endsWith("ncx")) {
        navItems.addAll(await parseNcx(fullPath));
      }
      if (navItems.isEmpty &&
          item.getAttribute("properties") == "nav" &&
          href.endsWith("xhtml")) {
        navItems.addAll(await parseBwNcx(fullPath));
      }
    }
    return [widgets, images, fonts, navItems, coverUrl, idmap];
  }

  Future<List<TonoNavItem>> parseNcx(String nxcPath) async {
    var currentDir = nxcPath;
    var ncxFile = await provider.getFileByPath(nxcPath);
    var document = XmlDocument.parse(ncxFile!.toUtf8());
    var navPoints = document.findAllElements("navPoint");
    return navPoints.map((e) {
      var textNode = e.findAllElements("text").first;
      var title = textNode.innerText;
      var src = e.findAllElements("content").first.getAttribute("src")!;
      var path = currentDir.pathSplicing(src);
      return TonoNavItem(path: path, title: title);
    }).toList();
  }
}
