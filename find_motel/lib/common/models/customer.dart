class Customer {
  final String id;
  final String name;
  final String phone;
  final double deal; // Giá
  final DateTime schedule; // Ngày hẹn
  final String saleId;
  final String motelId;
  final String motelName; // Thêm trường tên nhà trọ

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.deal,
    required this.schedule,
    required this.saleId,
    required this.motelId,
    required this.motelName,
  });
}