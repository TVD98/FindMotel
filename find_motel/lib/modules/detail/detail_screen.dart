// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:find_motel/common/models/deal.dart';
import 'package:find_motel/common/models/motel.dart';
import 'package:find_motel/common/models/user_profile.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/modules/deal_manager/screens/deal_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/modules/modtel_manager/screen/edit_motel_screen.dart'; // Thêm import này
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_bloc.dart';
import 'package:find_motel/modules/home_page/bloc/home_page_event.dart';
import 'package:find_motel/common/constants/app_extensions.dart';

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
  final bool isBottomSheet; // Add this parameter

  const RoomDetailScreen({
    super.key,
    required this.detail,
    this.isBottomSheet = true, // Default to bottom sheet
  });

  @override
  _RoomDetailScreenState createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late String _currentMainImage; // Lưu trữ mainImage hiện tại
  bool _needsReload = false; // Track whether we need to reload data

  Deal get _deal => Deal(
    id: '',
    name: '',
    phone: '',
    price: widget.detail.price,
    schedule: DateTime.now(),
    saleId: AppDataManager().currentUserProfile?.email ?? '',
    motelId: widget.detail.id,
    motelName: widget.detail.name,
  );

  bool get _isCanEdit =>
      AppDataManager().currentUserProfile?.role == UserRole.admin;

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
    // Extract content into a separate method
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );

    // Return different layouts based on isBottomSheet
    if (widget.isBottomSheet) {
      return Container(
        // Thêm overlay mờ cho bottom sheet
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5)),
        child: DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.5, 0.75, 0.9],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: SafeArea(
                bottom: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.padding),
                  child: content,
                ),
              ),
            );
          },
        ),
      );
    }

    // Normal view
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.detail.name,
        leadingAsset: 'assets/images/ic_back.svg',
        leadingIconColor: Colors.white,
        onLeadingPressed: () => Navigator.pop(context, _needsReload),
        // Chỉ hiển thị actions khi không phải bottom sheet
        actions: widget.isBottomSheet
            ? null
            : [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DealDetailScreen(deal: _deal),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.calendar_month,
                    color: AppColors.headerLineOnPrimary,
                  ),
                ),
                if (_isCanEdit)
                  IconButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditMotelScreen(motel: widget.detail),
                        ),
                      );

                      // Nếu có kết quả trả về (true = đã save thành công), reload data
                      if (result == true) {
                        _needsReload = true;
                        // Trigger reload HomePageBloc
                        if (context.mounted) {
                          // Import để access HomePageBloc
                          try {
                            context.read<HomePageBloc>().add(LoadMotels());
                          } catch (e) {
                            // Handle case where HomePageBloc is not available
                            print('HomePageBloc not found: $e');
                          }
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.edit, // Đổi icon thành icon edit
                      color: Colors.white, // Đổi thành màu trắng
                    ),
                  ),
              ],
      ),
      body: SafeArea(
        bottom: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.padding),
          child: content,
        ),
      ),
    );
  }

  // Widget hiển thị ảnh chính
  Widget _buildMainImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: _currentMainImage.startsWith('http')
          ? Image.network(
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
            )
          : Image.file(
              File(_currentMainImage),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
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
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
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
                            )
                          : Image.file(
                              File(imageUrl),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
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
                runSpacing: AppConstants.smallSpacing,
                children: AppExtensions.allExtensions
                    .where(
                      (extension) =>
                          widget.detail.extensions.contains(extension),
                    )
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(44),
                        ),
                        child: Text(
                          e,
                          style: GoogleFonts.quicksand(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
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
