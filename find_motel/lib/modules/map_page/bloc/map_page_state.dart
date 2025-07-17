// ignore: depend_on_referenced_packages

import 'package:equatable/equatable.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MotelCard {
  final String id;
  final String name;
  final String address;
  final String image;
  final String commission;
  final String price;

  MotelCard(this.id, this.name, this.address, this.image, this.commission, this.price);
}

class MapState extends Equatable {
  final LatLng? currentPosition;
  final LatLng? centerPosition;
  final LatLngBounds? bounds;
  final Set<Marker> markers;
  final List<MotelCard> cards;
  final Motel? selectedMotel;
  final bool isLoading;
  final String? error;

  const MapState({
    this.currentPosition,
    this.centerPosition,
    this.bounds,
    this.markers = const {},
    this.cards = const [],
    this.selectedMotel,
    this.isLoading = false,
    this.error,
  });

  MapState copyWith({
    LatLng? currentPosition,
    LatLng? centerPosition,
    LatLngBounds? bounds,
    Set<Marker>? markers,
    List<MotelCard>? cards,
    Motel? selectedMotel,
    bool? isLoading,
    String? error,
  }) {
    return MapState(
      currentPosition: currentPosition ?? this.currentPosition,
      centerPosition: centerPosition ?? this.centerPosition,
      bounds: bounds ?? this.bounds,
      markers: markers ?? this.markers,
      cards: cards ?? this.cards,
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
    cards,
    selectedMotel,
    isLoading,
    error,
  ];
}
