// ignore: depend_on_referenced_packages
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState {
  final LatLng? currentPosition;
  final LatLng? centerPosition;
  final Set<Marker> markers;
  final bool isLoading;
  final String? error;

  MapState({
    this.currentPosition,
    this.centerPosition,
    this.markers = const {},
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    LatLng? currentPosition,
    LatLng? centerPosition,
    Set<Marker>? markers,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      currentPosition: currentPosition ?? this.currentPosition,
      centerPosition: centerPosition ?? this.centerPosition,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
