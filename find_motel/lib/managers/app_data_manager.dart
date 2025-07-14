import 'package:find_motel/common/models/area.dart';
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

  MotelsFilter filterMotels = MotelsFilter(
    roomCode: null,
    address: Address(province: 'Tp. Hồ Chí Minh', ward: null),
    amenities: null,
    status: null,
    priceRange: Range2D(values: RangeValues(0, 11), maxValue: 10),
    distanceRange: Range(value: 11, maxValue: 10),
  );

  final List<String> allAmenities = ['Thang máy', 'Xe'];

  final List<RentalStatus> allStatus = RentalStatus.values;

  List<Province> allProvinces = [];
}
