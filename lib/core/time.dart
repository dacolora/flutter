import 'package:intl/intl.dart';

class Time {
  static final _ymd = DateFormat('yyyy-MM-dd');

  static DateTime startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static String ymd(DateTime d) {
    return _ymd.format(d);
  }

  static int isoWeekday(DateTime d) {
    return d.weekday; // 1 = Monday ... 7 = Sunday
  }
}