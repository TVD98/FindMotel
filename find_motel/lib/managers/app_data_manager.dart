import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/common/models/import_images_options.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';
import 'package:find_motel/common/models/motel_index.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppDataManager {
  static final AppDataManager _instance = AppDataManager._internal();

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
    address: Address(province: 'Tp. Hồ Chí Minh', ward: null),
    amenities: null,
    status: null,
    texturies: null,
    type: 'Khác',
    priceRange: Range2D(
      values: RangeValues(1000000, 10000000),
      maxValue: 20000000,
    ),
    distanceRange: Range(value: 10, maxValue: 100),
  );

  final List<String> allAmenities = ['Thang máy', 'Xe'];

  final List<String> allTexturies = [
    'DUPLEX',
    'STUDIO',
    '1 phòng ngủ',
    '2 phòng ngủ',
    '3 phòng ngủ',
    'Tách bếp',
  ];

  final List<String> allRoomTypies = ['Ban công', 'Cửa sổ', 'Khác'];

  final List<RentalStatus> allStatus = RentalStatus.values;

  List<Province> allProvinces = [];
}
