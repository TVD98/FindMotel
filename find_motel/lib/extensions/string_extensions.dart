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

  /// Hàm chuẩn hóa chuỗi: chuyển về chữ thường, bỏ dấu, loại bỏ ký tự đặc biệt.
  ///
  /// Bạn có thể cài đặt gói 'diacritic' để xử lý bỏ dấu tốt hơn:
  /// dependencies:
  ///   diacritic: ^latest_version
  String normalizeString() {
    if (isEmpty) {
      return '';
    }
    String normalized = toLowerCase();

    // Nếu sử dụng gói diacritic để bỏ dấu tiếng Việt:
    // normalized = removeDiacritics(normalized);
    // Nếu không sử dụng gói diacritic, bạn có thể tự implement hoặc chấp nhận
    // rằng việc bỏ dấu tiếng Việt thủ công sẽ phức tạp hơn và có thể không hoàn hảo.
    // Ví dụ đơn giản (chỉ xử lý 'đ' và một số dấu cơ bản, không đầy đủ):
    normalized = normalized.replaceAll('đ', 'd');
    normalized = normalized.replaceAll(RegExp(r'[áàảạãăằẳặẵâầẩậẫ]'), 'a');
    normalized = normalized.replaceAll(RegExp(r'[éèẻẹẽêềểệễ]'), 'e');
    normalized = normalized.replaceAll(RegExp(r'[íìỉịĩ]'), 'i');
    normalized = normalized.replaceAll(RegExp(r'[óòỏọõôồổộỗơờởợỡ]'), 'o');
    normalized = normalized.replaceAll(RegExp(r'[úùủụũưừửựữ]'), 'u');
    normalized = normalized.replaceAll(RegExp(r'[ýỳỷỵỹ]'), 'y');

    // Loại bỏ các ký tự không phải chữ cái, số, hoặc khoảng trắng
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9 ]'), '');

    return normalized.trim();
  }

  /// Hàm tạo mảng keywords từ một chuỗi tên.
  ///
  /// Các từ khóa được chuẩn hóa (chữ thường, không dấu) và loại bỏ trùng lặp.
  /// Bao gồm từng từ riêng lẻ và cả chuỗi gốc đã chuẩn hóa.
  List<String> generateKeywords() {
    final String normalizedName = normalizeString();
    // Tách chuỗi thành các từ và lọc bỏ các từ rỗng
    final List<String> words = normalizedName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    final Set<String> keywords =
        <String>{}; // Dùng Set để tránh từ khóa trùng lặp

    // Thêm từng từ riêng lẻ vào Set
    for (var word in words) {
      keywords.add(word);
    }

    // Thêm cả chuỗi gốc đã chuẩn hóa (nếu không rỗng)
    // Điều này giúp tìm kiếm chính xác cả cụm từ.
    if (normalizedName.isNotEmpty) {
      keywords.add(normalizedName);
    }

    // Chuyển Set thành List và trả về
    return keywords.toList();
  }
}
