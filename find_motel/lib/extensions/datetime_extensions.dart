import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toFormattedString(String format) {
    final formatter = DateFormat(format);
    return formatter.format(this);
  }
}