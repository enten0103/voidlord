import 'package:voidlord/tono_reader/parser/tono_parse_event.dart';
import 'package:voidlord/tono_reader/parser/tono_parser.dart';
import 'package:voidlord/tono_reader/tool/unit8_tool.dart';
import 'package:xml/xml.dart';

extension TonoContainerXml on TonoParser {
  Future<String> parseContainerXml() async {
    emit(TonoParseEvent(info: "container.xml", currentIndex: 0, totalIndex: 1));
    var xmlContent = (await provider.getFileByPath(
      "META-INF/container.xml",
    ))!.toUtf8();
    var document = XmlDocument.parse(xmlContent);
    var rootElement = document.findAllElements("rootfile").first;
    var path = rootElement.getAttribute("full-path")!;
    emit(TonoParseEvent(info: "container.xml", currentIndex: 1, totalIndex: 1));
    return path;
  }
}
