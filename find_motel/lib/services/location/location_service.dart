import 'dart:convert';
import 'package:find_motel/services/location/models/location_model.dart';
import 'package:http/http.dart' as http;

const String _baseUrl = 'https://esgoo.net/api-tinhthanh';

class LocationService {

  Future<List<Location>> getProvinces() async {
    final response = await http.get(Uri.parse('$_baseUrl/1/0.htm'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['error'] == 0) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load provinces: ${jsonResponse['error_text']}');
      }
    } else {
      throw Exception('Failed to connect to API: ${response.reasonPhrase}');
    }
  }

  Future<List<Location>> getDistricts(String provinceId) async {
    final response = await http.get(Uri.parse('$_baseUrl/2/$provinceId.htm'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['error'] == 0) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load districts: ${jsonResponse['error_text']}');
      }
    } else {
      throw Exception('Failed to connect to API: ${response.reasonPhrase}');
    }
  }

  Future<List<Location>> getWards(String districtId) async {
    final response = await http.get(Uri.parse('$_baseUrl/3/$districtId.htm'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['error'] == 0) {
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Location.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load wards: ${jsonResponse['error_text']}');
      }
    } else {
      throw Exception('Failed to connect to API: ${response.reasonPhrase}');
    }
  }
}