import 'package:intl/intl.dart';

/// 时间格式化工具。
class AppFormat {
  AppFormat._();

  /// 把秒数格式化成"X小时Y分钟" / "Y分钟" / "Z秒"。
  static String duration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) return '$h小时$m分钟';
    if (m > 0) return '$m分钟';
    return '$s秒';
  }

  /// 把秒数格式化成计时器显示 (mm:ss 或 hh:mm:ss)。
  static String timer(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    if (h > 0) {
      return '${_pad(h)}:${_pad(m)}:${_pad(s)}';
    }
    return '${_pad(m)}:${_pad(s)}';
  }

  /// 休息倒计时 mm:ss。
  static String restTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${_pad(m)}:${_pad(s)}';
  }

  /// 日期 → "今天" / "昨天" / "M月D日"。
  static String dateLabel(DateTime today, DateTime date) {
    final todayDate = DateTime(today.year, today.month, today.day);
    final thatDate = DateTime(date.year, date.month, date.day);
    final diff = todayDate.difference(thatDate).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '昨天';
    return DateFormat('M月d日').format(date);
  }

  /// HH:mm
  static String time(DateTime dt) => DateFormat('HH:mm').format(dt);

  /// YYYY-MM-DD
  static String dateOnly(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
