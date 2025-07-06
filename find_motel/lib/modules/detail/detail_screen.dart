// ignore_for_file: library_private_types_in_public_api

import 'package:find_motel/common/models/motel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:find_motel/theme/app_colors.dart';

// Class chứa các hằng số dùng chung
class AppConstants {
  static const primaryColor = AppColors.primary; // Màu xanh chủ đạo
  static const padding = 16.0; // Khoảng cách lề
  static const borderRadius = 12.0; // Bo góc
  static const smallSpacing = 8.0; // Khoảng cách nhỏ
  static const chipBorderRadius = 44.0; // Bo góc cho chip
  static const bottomNavBarHeight =
      56.0; // Chiều cao giả định của BottomNavigationBar
}

// Hàm định dạng tiền tệ VNĐ
String formatVND(dynamic price) {
  final formatter = NumberFormat("#,##0", "vi_VN");
  return formatter.format(price);
}

class RoomDetailScreen extends StatefulWidget {
  final Motel detail;

  const RoomDetailScreen({super.key, required this.detail});

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late String _currentMainImage; // Lưu trữ mainImage hiện tại

  @override
  void initState() {
    super.initState();
    _currentMainImage = widget.detail.thumbnail;
  }

  // Cập nhật mainImage khi nhấn vào ảnh con
  void _updateMainImage(String newImage) {
    setState(() {
      _currentMainImage = newImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tính maxChildSize để không che BottomNavigationBar
    final bottomNavHeight =
        AppConstants.bottomNavBarHeight; // Chiều cao BottomNavigationBar
    final bottomPadding = MediaQuery.of(
      context,
    ).padding.bottom; // Chiều cao bottom bar hệ thống
    final maxHeightFraction =
        (MediaQuery.of(context).size.height - bottomNavHeight - bottomPadding) /
        MediaQuery.of(context).size.height;
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // Bắt đầu với 1/2 màn hình
      minChildSize: 0.5, // Chiều cao tối thiểu: 1/2 màn hình
      maxChildSize:
          maxHeightFraction, // Chiều cao tối đa: không che BottomNavigationBar
      snap: true, // Bật snap giữa các mức
      snapSizes: [
        0.5,
        0.75,
        maxHeightFraction,
      ], // Các mức: 1/2, 3/4, max (không che BottomNavigationBar)
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.borderRadius),
            ),
          ),
          child: SafeArea(
            bottom: true, // Không che bottom navigation bar hệ thống
            child: SingleChildScrollView(
              controller:
                  scrollController, // Gắn scrollController từ DraggableScrollableSheet
              padding: const EdgeInsets.all(AppConstants.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: AppConstants.padding),
                  _buildMainImage(),
                  const SizedBox(height: AppConstants.smallSpacing),
                  _buildImageGallery(),
                  const SizedBox(height: AppConstants.smallSpacing),
                  _buildTags(),
                  const SizedBox(height: AppConstants.smallSpacing),
                  _buildRoomInfo(),
                  const SizedBox(height: AppConstants.padding),
                  _buildAddress(context),
                  const SizedBox(height: AppConstants.padding),
                  _buildExtensions(),
                  const SizedBox(height: AppConstants.padding),
                  _buildFees(),
                  const SizedBox(height: AppConstants.padding),
                  _buildNotes(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị tiêu đề và nút đóng
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: 'Tên phòng: ${widget.detail.name}',
            child: Text(
              widget.detail.name,
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(), // Đóng bottom sheet
          icon: const Icon(Icons.close),
          tooltip: 'Đóng',
        ),
      ],
    );
  }

  // Widget hiển thị ảnh chính
  Widget _buildMainImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Image.network(
        _currentMainImage,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            height: 180,
            child: Center(child: Icon(Icons.error, color: Colors.red)),
          );
        },
      ),
    );
  }

  // Widget hiển thị danh sách ảnh thu nhỏ
  Widget _buildImageGallery() {
    return widget.detail.images.isEmpty
        ? const Text('Không có hình ảnh', style: TextStyle(fontSize: 14))
        : SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.detail.images.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppConstants.smallSpacing),
              itemBuilder: (_, index) {
                final imageUrl = widget.detail.images[index];
                return GestureDetector(
                  onTap: () =>
                      _updateMainImage(imageUrl), // Cập nhật mainImage khi nhấn
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.smallSpacing,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentMainImage == imageUrl
                              ? AppConstants.primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 60,
                            height: 60,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 60,
                            height: 60,
                            child: Center(
                              child: Icon(Icons.error, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  // Widget hiển thị hoa hồng và giá thuê
  Widget _buildTags() {
    return Row(
      children: [
        _tagChip("HH ${widget.detail.commission}", Colors.teal),
        const SizedBox(width: 12),
        _tagChip(
          "Giá thuê: ${formatVND(widget.detail.price)}đ/tháng",
          Colors.grey.shade300,
          textColor: Colors.black,
        ),
      ],
    );
  }

  // Widget hiển thị Mã phòng và Kiểu phòng
  Widget _buildRoomInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mã phòng: ${widget.detail.roomCode}',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Kiểu phòng: ${widget.detail.type}',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            color: AppConstants.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // Widget hiển thị địa chỉ và nút Chỉ đường
  Widget _buildAddress(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on, color: AppConstants.primaryColor),
        const SizedBox(height: AppConstants.smallSpacing / 2),
        Text(widget.detail.address, style: GoogleFonts.quicksand(fontSize: 14)),
        const SizedBox(height: AppConstants.smallSpacing / 2),
        GestureDetector(
          onTap: () async {
            // Ưu tiên mở ứng dụng Google Maps bằng URL scheme
            String appUrl;
            String webUrl;
            final lat = widget.detail.geoPoint.latitude;
            final lng = widget.detail.geoPoint.longitude;
            appUrl = 'comgooglemaps://?q=$lat,$lng';
            webUrl =
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

            // Thử mở ứng dụng Google Maps
            if (await canLaunchUrl(Uri.parse(appUrl))) {
              await launchUrl(Uri.parse(appUrl));
            } else {
              // Fallback mở trình duyệt
              if (await canLaunchUrl(Uri.parse(webUrl))) {
                await launchUrl(Uri.parse(webUrl));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Không thể mở bản đồ')),
                );
              }
            }
          },
          child: Text(
            'Chỉ đường',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  // Widget hiển thị tiện ích
  Widget _buildExtensions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tiện ích:",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        widget.detail.extensions.isEmpty
            ? const Text('Không có tiện ích', style: TextStyle(fontSize: 14))
            : Wrap(
                spacing: AppConstants.smallSpacing,
                children: widget.detail.extensions
                    .map(
                      (e) => _tagChip(
                        e,
                        AppColors.elementSecondary,
                        textColor: Colors.black,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  // Widget hiển thị chi phí khác
  Widget _buildFees() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Chi phí khác:",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        widget.detail.fees.isEmpty
            ? const Text(
                'Không có chi phí khác',
                style: TextStyle(fontSize: 14),
              )
            : Column(
                children: widget.detail.fees.map((fee) {
                  return _costRow(
                    fee['name'] ?? 'Không xác định',
                    '${formatVND(fee['price'] ?? 0)}đ/${fee['unit'] ?? ''}',
                  );
                }).toList(),
              ),
      ],
    );
  }

  // Widget hiển thị ghi chú
  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ghi chú:",
          style: GoogleFonts.quicksand(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.smallSpacing),
        widget.detail.note.isEmpty
            ? const Text('Không có ghi chú', style: TextStyle(fontSize: 14))
            : Column(
                children: widget.detail.note
                    .map(
                      (note) => Padding(
                        padding: const EdgeInsets.only(
                          top: AppConstants.smallSpacing / 4,
                          bottom: AppConstants.smallSpacing / 4,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("• "),
                            Expanded(
                              child: Text(
                                note,
                                style: GoogleFonts.quicksand(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  // Widget tạo chip cho tiện ích và hoa hồng
  Widget _tagChip(
    String label,
    Color bgColor, {
    Color textColor = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.chipBorderRadius),
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // Widget tạo hàng cho chi phí
  Widget _costRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppConstants.smallSpacing / 4,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.quicksand(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: GoogleFonts.quicksand(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
