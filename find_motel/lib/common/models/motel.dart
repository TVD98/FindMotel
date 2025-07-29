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

class Fee {
  final String name;
  final double price;
  final String unit;

  const Fee({required this.name, required this.price, required this.unit});

  factory Fee.fromMap(Map<String, dynamic> map) {
    return Fee(
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'unit': unit};
  }
}

class Motel {
  final int? createdAt;
  final String id;
  final String address;
  final String commission;
  final List<String> extensions;
  final List<Fee> fees;
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

  String get displayName => id;

  /// Convert this [Motel] instance to a Map suitable for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'commission': commission,
      'extensions': extensions,
      'fees': fees.map((fee) => fee.toMap()).toList(),
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
      fees: List<Map<String, dynamic>>.from(
        map['fees'],
      ).map((fee) => Fee.fromMap(fee)).toList(),
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

  Motel copyWith({
    int? createdAt,
    String? address,
    String? commission,
    List<String>? extensions,
    List<Fee>? fees,
    LatLng? geoPoint,
    String? name,
    List<String>? note,
    double? price,
    String? roomCode,
    String? type,
    RentalStatus? status,
    List<String>? images,
    String? marker,
    String? thumbnail,
    String? texture,
  }) {
    return Motel(
      id: id,
      address: address ?? this.address,
      commission: commission ?? this.commission,
      extensions: extensions ?? this.extensions,
      fees: fees ?? this.fees,
      geoPoint: geoPoint ?? this.geoPoint,
      name: name ?? this.name,
      note: note ?? this.note,
      price: price ?? this.price,
      roomCode: roomCode ?? this.roomCode,
      type: type ?? this.type,
      status: status ?? this.status,
      images: images ?? this.images,
      marker: marker ?? this.marker,
      thumbnail: thumbnail ?? this.thumbnail,
      texture: texture ?? this.texture,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Motel empty(String id) {
    return Motel(
      id: id,
      address: '',
      commission: '',
      extensions: const [],
      fees: const [],
      geoPoint: const LatLng(0, 0),
      name: '',
      note: const [],
      price: 0,
      roomCode: id,
      type: '',
      status: RentalStatus.empty,
      images: const [],
      marker: '',
      thumbnail: '',
      texture: '',
      createdAt: null,
    );
  }
}
