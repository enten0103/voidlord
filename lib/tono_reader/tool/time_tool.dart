import 'package:intl/intl.dart';

extension DateTimeTool on DateTime {
  String formatDateTime() {
    // 转换为本地时间
    DateTime localDateTime = toLocal();
    DateTime now = DateTime.now().toLocal();

    // 提取日期部分（去掉时间）
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime inputDate =
        DateTime(localDateTime.year, localDateTime.month, localDateTime.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (inputDate == today) {
      // 今天：显示时间（HH:mm格式）
      return DateFormat('HH:mm').format(localDateTime);
    } else if (inputDate == yesterday) {
      // 昨天：显示“昨天”
      return '昨天';
    } else {
      // 其他情况：判断年份
      if (localDateTime.year == now.year) {
        // 同年：显示月/日
        return DateFormat('MM/dd').format(localDateTime);
      } else {
        // 不同年：显示年/月/日
        return DateFormat('yyyy/MM/dd').format(localDateTime);
      }
    }
  }
}
