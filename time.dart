/// Utilidades de fecha sin intl.
class Time {
  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static String ymd(DateTime d) {
    String two(int n) => n < 10 ? '0$n' : '$n';
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  static int isoWeekday(DateTime d) => d.weekday; // 1..7
}