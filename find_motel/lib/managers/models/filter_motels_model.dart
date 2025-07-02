import 'package:flutter/material.dart';

class FilterMotelsModel {
  final String? roomCode;
  final String? province;
  final String? ward;
  final List<String>? amenities;
  final String? status;
  final RangeValues? priceRange;
  final RangeValues? distanceRange;

  const FilterMotelsModel({
    this.roomCode,
    this.province,
    this.ward,
    this.amenities,
    this.status,
    this.priceRange,
    this.distanceRange,
  });
}
