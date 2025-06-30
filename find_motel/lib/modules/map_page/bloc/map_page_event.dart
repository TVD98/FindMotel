import 'package:equatable/equatable.dart';

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
  final String? priceRange; // Ví dụ: "0-3", "3-5", "5-8", ">8"
  final String? distanceRange; // Ví dụ: "<1", "1-5", "5-10", ">10"

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
