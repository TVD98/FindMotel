import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum RentalStatus {
  empty,
  deposit,
  rented;

  String get title {
    switch (this) {
      case RentalStatus.empty:
        return 'Trống';
      case RentalStatus.deposit:
        return 'Đặt cọc';
      case RentalStatus.rented:
        return 'Đã thuê';
    }
  }
}

class Motel {
  final String id;
  final String address;
  final String commission;
  final List<String> extensions;
  final List<Map<String, dynamic>> fees;
  final LatLng geoPoint;
  final String name;
  final List<String> note;
  final double price;
  final String roomCode;
  final String type;
  final RentalStatus status;
  final List<String> images;
  final String marker;
  final String thumbnail;
  final String texture;

  Motel({
    required this.id,
    required this.address,
    required this.commission,
    required this.extensions,
    required this.fees,
    required this.geoPoint,
    required this.name,
    required this.note,
    required this.price,
    required this.roomCode,
    required this.type,
    required this.status,
    required this.images,
    required this.marker,
    required this.thumbnail,
    required this.texture,
  });

  /// Convert this [Motel] instance to a Map suitable for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'commission': commission,
      'extensions': extensions,
      'fees': fees,
      'geo_point': GeoPoint(geoPoint.latitude, geoPoint.longitude),
      'name': name,
      'note': note,
      'price': price,
      'room_code': roomCode,
      'type': type,
      'status': status.name,
      'images': images,
      'marker': marker,
      'thumbnail': thumbnail,
    };
  }
}
