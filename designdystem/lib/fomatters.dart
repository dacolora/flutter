import 'package:intl/intl.dart';

class Fmt {
  static final _money = NumberFormat.decimalPattern('es_CO');

  static String money(int value) => _money.format(value);
  static String dt(DateTime d) => DateFormat('yyyy-MM-dd HH:mm').format(d);
}