// Class định nghĩa thông tin chi tiết phòng
class RoomDetail {
  final String address; // Địa chỉ phòng
  final String commission; // Hoa hồng
  final List<String> extensions; // Tiện ích (ví dụ: ["Xe"])
  final List<Map<String, dynamic>> fees; // Chi phí khác (điện, nước, dịch vụ)
  final List<double> geoPoint; // Tọa độ [latitude, longitude]
  final String name; // Tên phòng
  final List<String> note; // Ghi chú
  final int price; // Giá thuê
  final String id; // Mã phòng
  final String typeRoom; // Kiểu phòng
  final List<String> images; // Danh sách ảnh phòng
  final String mainImage; // Ảnh chính

  RoomDetail({
    required this.address,
    required this.commission,
    required this.extensions,
    required this.fees,
    required this.geoPoint,
    required this.name,
    required this.note,
    required this.price,
    required this.id,
    required this.typeRoom,
    required this.images,
    required this.mainImage,
  });
}
