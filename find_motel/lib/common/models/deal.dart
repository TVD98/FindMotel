class Deal {
  final String id;
  final String name;
  final String phone;
  final double price; // Giá
  final DateTime schedule; // Ngày hẹn
  final String saleId;
  final String motelId;
  final String motelName; // Thêm trường tên nhà trọ

  const Deal({
    required this.id,
    required this.name,
    required this.phone,
    required this.price,
    required this.schedule,
    required this.saleId,
    required this.motelId,
    required this.motelName,
  });

  copyWith({
    String? id,
    String? name,
    String? phone,
    double? price,
    DateTime? schedule,
    String? saleId,
    String? motelId,
    String? motelName,
  }) {
    return Deal(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      price: price ?? this.price,
      schedule: schedule ?? this.schedule,
      saleId: saleId ?? this.saleId,
      motelId: motelId ?? this.motelId,
      motelName: motelName ?? this.motelName,
    );
  }
}