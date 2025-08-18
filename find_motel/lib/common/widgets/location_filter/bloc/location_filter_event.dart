import 'package:find_motel/services/motel/models/motels_filter.dart';

abstract class LocationFilterEvent {}

class LoadProvinces extends LocationFilterEvent {
  final Address? address;
  LoadProvinces(this.address);
}

class ProvinceSelected extends LocationFilterEvent {
  final String provinceName;
  ProvinceSelected(this.provinceName);
}

class DistrictSelected extends LocationFilterEvent {
  final String districtName;
  DistrictSelected(this.districtName);
}

class WardSelected extends LocationFilterEvent {
  final String wardName;
  WardSelected(this.wardName);
}
