import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

extension StringExtensions on String {
  Query<Map<String, dynamic>> applyWhereEqualTo(
    Query<Map<String, dynamic>> query,
    String field,
  ) {
    return query.where(field, isEqualTo: this);
  }

  int? toIndex() {
    if (length != 1) return null; // Chỉ chấp nhận 1 ký tự
    final upperChar = toUpperCase();
    if (!RegExp(r'^[A-Z]$').hasMatch(upperChar)) {
      return null; // Chỉ chấp nhận A-Z
    }
    return codeUnitAt(0) - 'A'.codeUnitAt(0);
  }

  double toPrice() {
    final filter = replaceAll(RegExp(r'[^0-9]'), '');
    if (filter.isEmpty) return 0;
    return double.parse(filter) * 1000;
  }

  LatLng toGeoPoint() {
    final splited = split(',');
    if (splited.length != 2) return const LatLng(0, 0);
    final lat = double.parse(splited[0].trim());
    final lng = double.parse(splited[1].trim());
    return LatLng(lat, lng);
  }

  bool toBoolean() {
    return toLowerCase() == 'true' ||
        toLowerCase() == '1' ||
        toLowerCase() == 'yes' ||
        toLowerCase() == 'y' ||
        toLowerCase() == 'có';
  }

  DateTime? parseDate(String format) {
    return DateFormat(format).tryParse(this);
  }

  String toImageUrl() {
    RegExp regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?drive\.google\.com\/file\/d\/([a-zA-Z0-9_-]+)(?:\/view)?',
    );
    Match? match = regExp.firstMatch(this);

    if (match != null && match.groupCount > 0) {
      String fileId = match.group(1)!;
      return 'https://lh3.googleusercontent.com/d/$fileId';
    } else if (startsWith('https://lh3.googleusercontent.com/d/')) {
      return this; // Đã là link trực tiếp rồi
    }
    // Cố gắng tìm nếu là dạng link rút gọn drive.google.com/open?id=
    regExp = RegExp(
      r'(?:https?:\/\/)?(?:www\.)?drive\.google\.com\/open\?id=([a-zA-Z0-9_-]+)',
    );
    match = regExp.firstMatch(this);
    if (match != null && match.groupCount > 0) {
      String fileId = match.group(1)!;
      return 'https://lh3.googleusercontent.com/d/$fileId';
    }

    return this; // Không tìm thấy ID hoặc không phải link Drive hợp lệ
  }
}
