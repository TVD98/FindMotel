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
    final price = double.tryParse(this);
    if (price != null) return price;
    final filter = replaceAll(RegExp(r'[^0-9]'), '');
    if (filter.isEmpty) return 0;
    return double.parse(filter);
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
    normalized = normalized.replaceAll(RegExp(r'[óòỏọõôốồổộỗơờởợỡ]'), 'o');
    normalized = normalized.replaceAll(RegExp(r'[úùủụũưừửựữ]'), 'u');
    normalized = normalized.replaceAll(RegExp(r'[ýỳỷỵỹ]'), 'y');

    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9 /\-]'), '');

    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    return normalized.trim();
  }

  /// Hàm tạo mảng keywords từ một chuỗi tên.
  ///
  /// Các từ khóa được chuẩn hóa (chữ thường, không dấu) và loại bỏ trùng lặp.
  /// Bao gồm từng từ riêng lẻ và cả chuỗi gốc đã chuẩn hóa.
  List<String> generateKeywords() {
    final String normalizedName = normalizeString();
    final List<String> parts = normalizedName
        .split(RegExp(r'[ /\-]')) // Tách bằng khoảng trắng, '/', hoặc '-'
        .where((part) => part.isNotEmpty)
        .toList();

    final Set<String> keywords =
        <String>{}; // Dùng Set để tránh từ khóa trùng lặp

    // Thêm từng từ riêng lẻ vào Set
    for (var word in parts) {
      keywords.add(word);
    }

    for (int i = 0; i < parts.length - 1; i++) {
      // Ghép hai từ liền kề với một khoảng trắng ở giữa
      final String biGram = '${parts[i]} ${parts[i + 1]}';
      keywords.add(biGram);
    }

    // Thêm cả chuỗi gốc đã chuẩn hóa (nếu không rỗng)
    // Điều này giúp tìm kiếm chính xác cả cụm từ.
    if (normalizedName.isNotEmpty) {
      keywords.add(normalizedName);
    }

    // Chuyển Set thành List và trả về
    return keywords.toList();
  }

  String normalizeAddressString() {
    String result = this;

    // Danh sách các cụm từ cần loại bỏ
    final List<String> phrasesToRemove = [ 'đặc khu','quận','huyện','tỉnh','thành phố'];

    for (String phrase in phrasesToRemove) {
      String resultTemp = result.replaceAll(
        RegExp(r'\b' + phrase + r'\b', caseSensitive: false),
        '',
      );
      try {
        int.parse(resultTemp);
      }
      catch (e) {
        result = resultTemp;
      }
    }

    // Loại bỏ khoảng trắng thừa do việc xóa cụm từ gây ra
    result = result.replaceAll(RegExp(r'\s+'), ' ').trim();

    return result.normalizeString();
  }

  String removeTrailingZero() {
    if (endsWith('.0') || endsWith(',0')) {
      return substring(0, length - 2); // Xóa 2 ký tự ".0" hoặc ",0"
    }
    return this; // Trả về chuỗi gốc nếu không có ".0" hoặc ",0" ở cuối
  }

  List<String> extractPhoneNumbers() {
    // Biểu thức chính quy để tìm các chuỗi số có 9 đến 11 chữ số
    // Rất phù hợp với định dạng số điện thoại ở Việt Nam
    final RegExp regex = RegExp(r'\d{9,11}');

    // Danh sách để lưu các số điện thoại tìm được
    final List<String> phoneNumbers = [];

    // Tìm tất cả các kết quả phù hợp trong chuỗi
    for (final Match m in regex.allMatches(this)) {
      // Thêm số điện thoại tìm được vào danh sách
      phoneNumbers.add(m.group(0)!.padLeft(10, '0'));
    }

    return phoneNumbers;
  }

  String formatPhoneNumber() {
    // 1. Làm sạch chuỗi, chỉ giữ lại các chữ số
    final cleanNumber = replaceAll(RegExp(r'\D'), '');

    // 2. Thêm số 0 vào đầu nếu cần, để chuỗi có đủ 10 chữ số
    // Ví dụ: "1234567" sẽ thành "0001234567"
    final paddedNumber = cleanNumber.padLeft(10, '0');

    // 3. Tách chuỗi thành 3 phần và ghép lại với dấu "-"
    // xxx-xxx-xxxx
    final part1 = paddedNumber.substring(0, 3);
    final part2 = paddedNumber.substring(3, 6);
    final part3 = paddedNumber.substring(6, 10);

    return '$part1-$part2-$part3';
  }

  Map<String, String> parseAddress() {
    final Map<String, String> parsedAddress = {
      'number': '',
      'street': '',
      'ward': '',
      'district': '',
    };

    final firstSplit = split(' ');
    if (firstSplit.length < 2) return parsedAddress;
    final number = firstSplit[0];
    final remainingAddress = firstSplit.sublist(1).join(' ').trim();
    final secondSplit = remainingAddress.split(',');
    if (secondSplit.length < 3) return parsedAddress;
    final street = secondSplit[0].trim();
    final ward = secondSplit[1]
        .replaceAll(RegExp(r'p(hương|huong|hường)', caseSensitive: false), '')
        .trim();
    final district = secondSplit[2].trim();

    parsedAddress['number'] = number;
    parsedAddress['street'] = street;
    parsedAddress['ward'] = ward;
    parsedAddress['district'] = district;

    return parsedAddress;
  }
}
