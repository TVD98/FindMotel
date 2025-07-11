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
}