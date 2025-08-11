import 'package:find_motel/common/models/area.dart';
import 'package:find_motel/services/motel/models/motels_filter.dart';

class LocationFilterState {
  final List<Province> provinces;
  final List<Unit> districts;
  final List<Unit> wards;
  final Address? address;

  LocationFilterState({
    this.address,
    required this.provinces,
    required this.districts,
    required this.wards,
  });

  LocationFilterState copyWith({
    Address? address,
    List<Province>? provinces,
    List<Unit>? districts,
    List<Unit>? wards,
  }) {
    return LocationFilterState(
      address: address ?? this.address,
      provinces: provinces ?? this.provinces,
      districts: districts ?? this.districts,
      wards: wards ?? this.wards,
    );
  }
}
