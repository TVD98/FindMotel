import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
    if (!RegExp(r'^[A-Z]$').hasMatch(upperChar))
      return null; // Chỉ chấp nhận A-Z
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
}
