import 'package:intl/intl.dart';

class Formatters {
  static String currency(num value) => NumberFormat.simpleCurrency().format(value);
  static String date(DateTime d) => DateFormat('dd MMM, yyyy').format(d);
}
