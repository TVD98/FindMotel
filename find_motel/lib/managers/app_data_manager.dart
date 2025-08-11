import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/common/models/import_images_options.dart';
import 'package:find_motel/services/location/location_service.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/common/models/motel_index.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppDataManager {
  static final AppDataManager _instance = AppDataManager._internal();
  final LocationService _locationService = LocationService();

  factory AppDataManager() {
    return _instance;
  }

  AppDataManager._internal();

  LatLng? currentLocation;

  UserProfile? currentUserProfile;

  MotelIndex? motelIndex;

  ImportImagesOptions? importImagesOptions;

  MotelsFilter filterMotels = MotelsFilter(
    roomCode: null,
    address: Address(
      province: 'Thành phố Hồ Chí Minh',
      district: null,
      ward: null,
    ),
    amenities: null,
    status: null,
    texturies: null,
    type: null,
    priceRange: Range2D(
      values: RangeValues(1000000, 10000000),
      maxValue: 20000000,
    ),
    distanceRange: Range(value: 10, maxValue: 100),
  );

  List<String> allAmenities = [];

  List<String> allTexturies = [];

  List<String> allRoomTypies = [];

  final List<RentalStatus> allStatus = RentalStatus.values;

  List<Province> allProvinces = [];

  Future<List<Unit>> getDistricts(String provinceId) async {
    if (provinceId == '0') {
      return [];
    }
    final Province province = allProvinces.firstWhere(
      (e) => e.id == provinceId,
    );
    if (province.units.isNotEmpty) {
      return province.units;
    } else {
      final result = await _locationService.getDistricts(provinceId);
      final List<Unit> districts = result
          .map((e) => Unit(id: e.id, name: e.fullName, units: []))
          .toList();
      allProvinces = allProvinces
          .map((e) => e.id == provinceId ? e.copyWith(districts) : e)
          .toList();
      return districts;
    }
  }

  Future<List<Unit>> getWards(String provinceId, String districtId) async {
    if (districtId == '0') {
      return [];
    }
    final Province province = allProvinces.firstWhere(
      (e) => e.id == provinceId,
    );
    final Unit district = province.units.firstWhere((e) => e.id == districtId);
    if (district.units.isNotEmpty) {
      return district.units;
    } else {
      final result = await _locationService.getWards(districtId);
      final List<Unit> wards = result
          .map((e) => Unit(id: e.id, name: e.fullName, units: []))
          .toList();
      allProvinces = allProvinces
          .map(
            (e) =>
                e.id == provinceId ? e.copyWithChildren(districtId, wards) : e,
          )
          .toList();
      return wards;
    }
  }

  Future<List<Unit>> getWardsNew(String provinceId) async {
    final Province province = allProvinces.firstWhere(
      (e) => e.id == provinceId,
    );
    if (province.units.isNotEmpty) {
      return province.units;
    } else {
      final result = await _locationService.getWards(provinceId);
      final List<Unit> wards = result
          .map((e) => Unit(id: e.id, name: e.fullName, units: []))
          .toList();
      allProvinces = allProvinces
          .map((e) => e.id == provinceId ? e.copyWith(wards) : e)
          .toList();
      return wards;
    }
  }
}
