import 'dart:math';

import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/extensions/string_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

abstract class QueryFilter {
  /// Applies this filter to the provided Firestore [query] and returns the new query.
  Query<Map<String, dynamic>> apply(Query<Map<String, dynamic>> query);
}

abstract class KeywordsFilter {
  List<String> makeKeywords(List<String> keywords);
}

abstract class LocalFilter {
  bool checkCondition(Motel motel);
}

class Range implements LocalFilter {
  final double value;
  final double maxValue;

  Range({required this.value, required this.maxValue});

  @override
  bool checkCondition(Motel motel) {
    if (value > maxValue) return true;

    // If we don't have the user's current location yet, we can't apply a distance filter.
    final LatLng? currentLocation = AppDataManager().currentLocation;
    if (currentLocation == null) return true;

    // Calculate the straight-line distance between the user's location and the motel.
    final double distanceInMeters = Geolocator.distanceBetween(
      currentLocation.latitude,
      currentLocation.longitude,
      motel.geoPoint.latitude,
      motel.geoPoint.longitude,
    );

    final double distanceInKm = distanceInMeters / 1000;

    return distanceInKm <= value;
  }
}

class Range2D implements QueryFilter {
  final RangeValues values;
  final double maxValue;

  Range2D({required this.values, required this.maxValue});

  @override
  Query<Map<String, dynamic>> apply(Query<Map<String, dynamic>> query) {
    if (values.start > 0) {
      query = query.where('price', isGreaterThanOrEqualTo: values.start);
    }
    if (values.end <= maxValue) {
      query = query.where('price', isLessThanOrEqualTo: values.end);
    }
    return query;
  }
}

class Address implements KeywordsFilter {
  final String? province;
  final String? district;
  final String? ward;

  Address({this.province, this.district, this.ward});

  @override
  List<String> makeKeywords(List<String> keywords) {
    if (district != null) {
      if (ward != null) {
        keywords = keywords + [ward!.normalizeAddressString(), district!.normalizeAddressString()];
      } else {
        keywords = keywords + [district!.normalizeAddressString()];
      }
      return keywords;
    }
    return keywords;
  }
}

class MotelsFilter {
  final String? keywords;
  final String? roomCode;
  final Address? address;
  final List<String>? amenities;
  final List<String>? status;
  final List<String>? texturies;
  final String? type;
  final Range2D? priceRange;
  final Range? distanceRange;

  MotelsFilter({
    this.keywords,
    this.roomCode,
    this.address,
    this.amenities,
    this.status,
    this.texturies,
    this.type,
    this.priceRange,
    this.distanceRange,
  });

  copyWith({
    String? keywords,
    String? roomCode,
    Address? address,
    List<String>? amenities,
    List<String>? status,
    List<String>? texturies,
    String? type,
    Range2D? priceRange,
    Range? distanceRange,
  }) {
    return MotelsFilter(
      keywords: keywords ?? this.keywords,
      roomCode: roomCode ?? this.roomCode,
      address: address ?? this.address,
      amenities: amenities ?? this.amenities,
      status: status ?? this.status,
      texturies: texturies ?? this.texturies,
      type: type ?? this.type,
      priceRange: priceRange ?? this.priceRange,
      distanceRange: distanceRange ?? this.distanceRange,
    );
  }
}
