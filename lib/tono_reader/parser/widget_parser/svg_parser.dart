import 'dart:typed_data';

import 'package:html/dom.dart';
import 'package:voidlord/tono_reader/model/parser/tono_style_sheet_block.dart';
import 'package:voidlord/tono_reader/model/style/tono_style.dart';
import 'package:voidlord/tono_reader/model/widget/tono_container.dart';
import 'package:voidlord/tono_reader/model/widget/tono_svg.dart';
import 'package:voidlord/tono_reader/model/widget/tono_widget.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/parser/tono_selector_macher.dart';
import 'package:voidlord/tono_reader/tool/path_tool.dart';
import 'package:xml/xml.dart' as xml;

extension SvgParser on TonoParser {
  Future<TonoWidget> toSvg(
    Element element,
    String currentPath,
    List<TonoStyleSheetBlock> css, {
    List<TonoStyle>? inheritStyles,
  }) async {
    var matchedCss = matchAll(element, css, inheritStyles);
    var result = await processSvg(element.outerHtml, currentPath);
    return TonoContainer(
        className: "svg",
        css: matchedCss,
        display: "inline",
        children: [TonoSvg(src: result, css: matchedCss)]);
  }

  Future<String> processSvg(String svgText, String currentPath) async {
    // 解析 SVG
    final document = xml.XmlDocument.parse(svgText);

    // 查找所有 image 节点
    final images = document.findAllElements('image');

    for (final image in images) {
      // 获取 xlink:href 或 href
      final href =
          image.getAttribute('href') ?? image.getAttribute('xlink:href');

      if (href != null && href.isNotEmpty) {
        final imageData = await _fetchImage(href, currentPath);

        // 生成 Base64
        final base64Data = UriData.fromBytes(
          imageData,
          mimeType: _getMimeType(href),
        ).toString();
        // 更新属性（优先使用普通 href）
        image.attributes.removeWhere((attr) =>
            attr.name.qualified == 'href' ||
            attr.name.qualified == 'xlink:href');

        image.attributes.add(xml.XmlAttribute(xml.XmlName('href'), base64Data));
      }
    }

    document.rootElement.attributes
        .removeWhere((attr) => attr.name.qualified == 'xmlns:xlink');

    return document.toXmlString();
  }

  Future<Uint8List> _fetchImage(String url, String currentPath) async {
    var path = currentPath.pathSplicing(url);

    var result = await provider.getFileByPath(path);
    if (result != null) {
      return result;
    }
    throw Error();
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
