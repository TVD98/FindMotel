import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String toVND() {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(this);
  }
}