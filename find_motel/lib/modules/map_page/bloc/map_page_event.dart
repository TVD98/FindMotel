import 'package:equatable/equatable.dart';
import 'package:find_motel/modules/detail/detail_motel_model.dart';
import 'package:flutter/material.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class LoadCurrentLocationEvent extends MapEvent {
  const LoadCurrentLocationEvent();
}

class LoadFirestoreMarkersEvent extends MapEvent {
  const LoadFirestoreMarkersEvent();
}

class FilterMarkersEvent extends MapEvent {
  final String? roomCode;
  final String? province;
  final String? ward;
  final List<String>? amenities;
  final String? status;
  final RangeValues? priceRange;
  final RangeValues? distanceRange;

  const FilterMarkersEvent({
    this.roomCode,
    this.province,
    this.ward,
    this.amenities,
    this.status,
    this.priceRange,
    this.distanceRange,
  });

  @override
  List<Object> get props => [
    roomCode ?? '',
    province ?? '',
    ward ?? '',
    amenities ?? [],
    status ?? '',
    priceRange ?? '',
    distanceRange ?? '',
  ];
}

class MarkerTapped extends MapEvent {
  final RoomDetail motel;
  const MarkerTapped(this.motel);

  @override
  List<Object> get props => [motel];
}
