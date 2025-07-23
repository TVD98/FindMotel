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
  final int? createdAt;
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
    this.createdAt,
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
      'texture': texture,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory Motel.fromMap(Map<String, dynamic> map, {String? id}) {
    return Motel(
      id: id ?? map['id'] ?? '',
      address: map['address'] ?? '',
      commission: map['commission'] ?? '',
      extensions: List<String>.from(map['extensions'] ?? []),
      fees: List<Map<String, dynamic>>.from(map['fees'] ?? []),
      geoPoint: map['geo_point'] is GeoPoint
          ? LatLng(map['geo_point'].latitude, map['geo_point'].longitude)
          : const LatLng(0, 0),
      name: map['name'] ?? '',
      note: List<String>.from(map['note'] ?? []),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      roomCode: map['room_code'] ?? '',
      type: map['type'] ?? '',
      status: RentalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RentalStatus.empty,
      ),
      images: List<String>.from(map['images'] ?? []),
      marker: map['marker'] ?? '',
      thumbnail: map['thumbnail'] ?? '',
      texture: map['texture'] ?? '',
      createdAt: map['created_at'] is int ? map['created_at'] as int : null,
    );
  }
}
