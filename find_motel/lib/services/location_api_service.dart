import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:find_motel/common/models/area.dart';

class LocationApiService {
  final String _baseUrl = 'https://provinces.open-api.vn/api';

  // Lấy tất cả các tỉnh thành
  Future<List<Province>> fetchProvinces() async {
    final response = await http.get(Uri.parse('$_baseUrl/p/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Province.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  // Lấy chi tiết một tỉnh (bao gồm cả huyện và xã)
  Future<Province> fetchProvinceWithDetails(int provinceCode) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/p/$provinceCode?depth=3'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Province.fromJson(data);
    } else {
      throw Exception('Failed to load province details');
    }
  }
}
