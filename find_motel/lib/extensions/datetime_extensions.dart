import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String toFormattedString(String format) {
    final formatter = DateFormat(format);
    return formatter.format(this);
  }

  String formatTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(this);

    // Vừa xong (dưới 1 phút)
    if (difference.inMinutes < 1) {
      return 'vừa xong';
    }

    // X phút trước (dưới 1 giờ)
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes phút trước';
    }

    // X giờ trước (dưới 24 giờ)
    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours giờ trước';
    }

    // X ngày trước (dưới 7 ngày)
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ngày trước';
    }

    // X tuần trước (dưới 30 ngày)
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    }

    // X tháng trước (dưới 365 ngày)
    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    }

    // X năm trước (lớn hơn 365 ngày)
    final years = (difference.inDays / 365).floor();
    return '$years năm trước';
  }
}
