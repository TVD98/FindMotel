import 'package:find_motel/extensions/string_extensions.dart';

class MotelIndex {
  int? start;
  String? number;
  String? street;
  String? ward;
  String? price;
  String? type;
  String? roomCode;
  String? elevator;
  String? commission;
  String? electricity;
  String? water;
  String? other;
  String? car;
  String? note;
  String? geoPoint;
  String? texture;

  MotelIndex({
    this.start,
    this.number,
    this.street,
    this.ward,
    this.price,
    this.type,
    this.roomCode,
    this.elevator,
    this.commission,
    this.electricity,
    this.water,
    this.other,
    this.car,
    this.note,
    this.geoPoint,
    this.texture,
  });

  factory MotelIndex.fromJson(Map<String, dynamic> json) => MotelIndex(
    start: json['start'] as int?,
    number: json['number'] as String?,
    street: json['street'] as String?,
    ward: json['ward'] as String?,
    price: json['price'] as String?,
    type: json['type'] as String?,
    roomCode: json['room_code'] as String?,
    elevator: json['elevator'] as String?,
    commission: json['commission'] as String?,
    electricity: json['electricity_price'] as String?,
    water: json['water_price'] as String?,
    other: json['other_price'] as String?,
    car: json['car_deposit'] as String?,
    note: json['note'] as String?,
    geoPoint: json['geo_point'] as String?,
    texture: json['texture'] as String?,
  );

  int? maxFields() {
    final List<int> indexList = [
      street,
      ward,
      price,
      type,
      roomCode,
      elevator,
      commission,
      electricity,
      water,
      other,
      car,
      note,
      geoPoint,
      texture,
    ].map((e) => e?.toIndex()).where((e) => e != null).cast<int>().toList();
    if (indexList.isEmpty) return null;
    return indexList.reduce((a, b) => a > b ? a : b);
  }
}
