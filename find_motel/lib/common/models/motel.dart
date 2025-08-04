import 'package:find_motel/extensions/double_extensions.dart';
import 'package:find_motel/extensions/string_extensions.dart';
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
  final String car;
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
  final List<String> phoneNumbers;

  Motel({
    this.createdAt,
    required this.id,
    required this.address,
    required this.commission,
    required this.car,
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
    required this.phoneNumbers,
  });

  String get displayName => roomCode;

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
      'phone_numbers': phoneNumbers,
      'car': car,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory Motel.fromMap(Map<String, dynamic> map, {String? id}) {
    return Motel(
      id: id ?? map['id'] ?? '',
      address: map['address'] ?? '',
      commission: map['commission'] ?? '',
      car: map['car'] ?? '',
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
      phoneNumbers: List<String>.from(map['phone_numbers'] ?? []),
      createdAt: map['created_at'] is int ? map['created_at'] as int : null,
    );
  }

  Motel copyWith({
    int? createdAt,
    String? address,
    String? commission,
    String? car,
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
    List<String>? phoneNumbers,
  }) {
    return Motel(
      id: id,
      address: address ?? this.address,
      commission: commission ?? this.commission,
      car: car ?? this.car,
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
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static Motel empty(String id) {
    return Motel(
      id: id,
      address: '',
      commission: '',
      car: '',
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
      phoneNumbers: const [],
      createdAt: null,
    );
  }

  Map<String, String> getRowData() {
    Map<String, String> parsedAddress = address.parseAddress();
    final elevator = extensions.contains('Thang máy') ? 'Có' : 'Không';
    final electricity = fees
        .firstWhere((fee) => fee.name == 'Điện')
        .price
        .toVND();
    final water = fees.firstWhere((fee) => fee.name == 'Nước').price.toVND();
    final other = fees
        .firstWhere((fee) => fee.name == 'Phí dịch vụ')
        .price
        .toVND();
    return {
      'roomCode': roomCode,
      'type': type,
      'price': price.toVND(),
      'commission': commission,
      'car': car,
      'elevator': elevator,
      'electricity': electricity,
      'water': water,
      'other': other,
      'images': images.join(', '),
      'texture': texture,
      'phone_numbers': phoneNumbers.join(' - '),
      'note': note.join(', '),
      'location': '${geoPoint.latitude}, ${geoPoint.longitude}',
      ...parsedAddress,
    };
  }
}
