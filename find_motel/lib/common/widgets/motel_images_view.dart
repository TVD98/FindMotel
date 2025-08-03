import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_motel/common/widgets/edit_images_screen.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MotelImagesView extends StatefulWidget {
  final List<String> imageUrls;
  final bool isCanEdit;
  final Function(List<String>)? onImagesChanged;

  const MotelImagesView({
    super.key,
    required this.imageUrls,
    required this.isCanEdit,
    this.onImagesChanged,
  });

  @override
  State<MotelImagesView> createState() => _MotelImagesViewState();
}

class _MotelImagesViewState extends State<MotelImagesView> {
  // Biến trạng thái để lưu trữ URL của ảnh chính hiện tại
  late String _currentMainImage;
  late List<String> _currentImages;

  // Golden Ratio constant
  static const double goldenRatio = 1.6180339887;

  int get _imagesCount => _currentImages.length;

  @override
  void initState() {
    super.initState();
    // Khởi tạo ảnh chính là ảnh đầu tiên trong danh sách (nếu có)

    _currentImages = widget.imageUrls;
    _currentMainImage = widget.imageUrls.isNotEmpty
        ? widget.imageUrls.first
        : '';
  }

  @override
  void didUpdateWidget(covariant MotelImagesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kiểm tra nếu danh sách ảnh từ widget cha đã thay đổi
    if (widget.imageUrls != oldWidget.imageUrls) {
      setState(() {
        _currentImages = widget.imageUrls;
        _currentMainImage = _currentImages.isNotEmpty
            ? _currentImages.first
            : '';
      });
    }
  }

  // Hàm để cập nhật ảnh chính khi ảnh nhỏ được chọn
  void _updateMainImage(String newImage) {
    setState(() {
      _currentMainImage = newImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the full screen width for the main image calculation
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate main image height based on golden ratio
    final double mainImageHeight = screenWidth / goldenRatio;

    // Small image fixed width and calculated height
    const double smallImageWidth = 42.0;
    final double smallImageHeight = smallImageWidth / goldenRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Image (full width, golden ratio height)
        _buildMainImage(screenWidth, mainImageHeight),
        const SizedBox(height: 12),
        // Image Gallery
        _buildImageGallery(smallImageWidth, smallImageHeight),
      ],
    );
  }

  /// Builds the main image widget.
  Widget _buildMainImage(double width, double height) {
    // Nếu không có ảnh, trả về một widget placeholder
    if (_currentMainImage.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(
          Icons.photo_camera_back,
          size: 50,
          color: Colors.grey,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: _getImageWidget(_currentMainImage, width, height),
    );
  }

  /// Builds the horizontal image gallery.
  Widget _buildImageGallery(double itemWidth, double itemHeight) {
    return SizedBox(
      height:
          itemHeight + 10, // Add some padding for the border or visual space
      child: Row(
        children: [
          if (widget.isCanEdit)
            GestureDetector(
              onTap: () => {
                _pushToEditImages(),
              }, // Gọi hàm cập nhật trạng thái cục bộ
              child: Container(
                width: itemWidth,
                margin: const EdgeInsets.only(right: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: SvgPicture.asset(
                  'assets/images/ic_edit_images.svg',
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    AppColors.elementSecondary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          if (widget.imageUrls.isNotEmpty)
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imagesCount,
                itemBuilder: (_, index) {
                  final imageUrl = _currentImages[index];
                  return GestureDetector(
                    onTap: () => _updateMainImage(
                      imageUrl,
                    ), // Gọi hàm cập nhật trạng thái cục bộ
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(
                          color: _currentMainImage == imageUrl
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: _getImageWidget(imageUrl, itemWidth, itemHeight),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _getImageWidget(String url, double width, double height) {
    if (url.isEmpty) {
      return _buildImageDefault(width, height);
    } else {
      return CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorWidget: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.error, color: Colors.grey),
          );
        },
      );
    }
  }

  Widget _buildImageDefault(double width, double height) {
    return Image.asset(
      'assets/images/image_default.png',
      width: width,
      height: height,
    );
  }

  void _pushToEditImages() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageDisplayScreen(initialImages: widget.imageUrls),
      ),
    );
    if (result is List<String>) {
      widget.onImagesChanged?.call(result);
      setState(() {
        _currentImages = result;
        _currentMainImage = result.isNotEmpty ? result.first : '';
      });
    }
  }
}
