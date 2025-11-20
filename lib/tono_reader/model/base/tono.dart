import 'package:voidlord/tono_reader/model/base/tono_book_info.dart';
import 'package:voidlord/tono_reader/widget_provider/tono_widget_provider.dart';

///Tono文件模型
class Tono {
  const Tono(
      {required this.bookInfo,
      required this.hash,
      required this.deepth,
      required this.navItems,
      required this.xhtmls,
      required this.widgetProvider});

  final String hash;

  ///基础信息
  final TonoBookInfo bookInfo;

  ///导航信息
  final List<TonoNavItem> navItems;

  ///xhtml序列
  final List<String> xhtmls;

  ///布局信息提供器
  final TonoWidgetProvider widgetProvider;

  final int deepth;

  Future<Map<String, dynamic>> toMap() async {
    return {
      'bookInfo': bookInfo.toMap(),
      'hash': hash,
      'navItems': navItems.map((item) => item.toMap()).toList(),
      'xhtmls': xhtmls,
      'deepth': deepth,
      'widgetProvider': await widgetProvider.toMap(),
    };
  }

  static Future<Tono> fromMap(Map<String, dynamic> map) async {
    return Tono(
      bookInfo: TonoBookInfo.fromMap(map['bookInfo'] as Map<String, dynamic>),
      hash: map['hash'] as String,
      deepth: map['deepth'] as int,
      navItems: (map['navItems'] as List)
          .map((item) => TonoNavItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      xhtmls: (map['xhtmls'] as List).map((e) {
        return e.toString();
      }).toList(),
      widgetProvider: await TonoWidgetProvider.formMap(
          map['widgetProvider'] as Map<String, dynamic>),
    );
  }
}
