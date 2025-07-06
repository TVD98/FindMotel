import 'package:geolocator/geolocator.dart';
import 'package:find_motel/services/geolocator/models/fm_position.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class IGeolocatorService {
  Future<({FMPosition? position, String? error})> getCurrentLocation();
  ({LatLng? center, LatLngBounds? bounds}) calculateCenterAndBounds(List<LatLng> positions);
//   Stream<Position> getLocationStream({required LocationSettings locationSettings});
//   Future<LocationPermission> checkPermission();
//   Future<LocationPermission> requestPermission();
//   Future<bool> isLocationServiceEnabled();
}

class GeolocatorService implements IGeolocatorService {
  @override
  Future<({FMPosition? position, String? error})> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (
          position: null,
          error: 'Location services are disabled',
        );
      }

      // Check & request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return (
            position: null,
            error: 'Location permission denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return (
          position: null,
          error: 'Location permission permanently denied',
        );
      }

      // All good – get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return (
        position: FMPosition(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        error: null,
      );
    } catch (e) {
      return (
        position: null,
        error: e.toString(),
      );
    }
  }

  @override
  ({LatLng? center, LatLngBounds? bounds}) calculateCenterAndBounds(List<LatLng> positions) {
    if (positions.isEmpty) {
      return (center: null, bounds: null);
    }
    double latSum = 0;
    double lngSum = 0;
    final minLat = positions.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final maxLat = positions.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final minLng = positions.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final maxLng = positions.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);
    for (var pos in positions) {
      latSum += pos.latitude;
      lngSum += pos.longitude;
    }
    final center = LatLng(latSum / positions.length, lngSum / positions.length);
    final bounds = LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
    return (center: center, bounds: bounds);
  }
}