// ignore: depend_on_referenced_packages

import 'package:equatable/equatable.dart';
import 'package:find_motel/modules/detail/detail_motel_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState extends Equatable {
  final LatLng? currentPosition;
  final LatLng? centerPosition;
  final LatLngBounds? bounds;
  final Set<Marker> markers;
  final RoomDetail? selectedMotel;
  final bool isLoading;
  final String? error;

  const MapState({
    this.currentPosition,
    this.centerPosition,
    this.bounds,
    this.markers = const {},
    this.selectedMotel,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    LatLng? currentPosition,
    LatLng? centerPosition,
    LatLngBounds? bounds,
    Set<Marker>? markers,
    RoomDetail? selectedMotel,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      currentPosition: currentPosition ?? this.currentPosition,
      centerPosition: centerPosition ?? this.centerPosition,
      bounds: bounds ?? this.bounds,
      markers: markers ?? this.markers,
      selectedMotel: selectedMotel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    currentPosition,
    centerPosition,
    bounds,
    markers,
    selectedMotel,
    isLoading,
    error,
  ];
}
