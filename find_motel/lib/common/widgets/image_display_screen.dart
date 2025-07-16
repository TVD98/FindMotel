import 'package:cached_network_image/cached_network_image.dart';
import 'package:find_motel/common/widgets/common_app_bar.dart';
import 'package:find_motel/common/widgets/custom_button.dart';
import 'package:find_motel/extensions/string_extensions.dart';
import 'package:find_motel/managers/app_data_manager.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

// Đặt một hằng số cho placeholder
const String _kAddImagePlaceholder = 'ADD_IMAGE_PLACEHOLDER';

class ImageDisplayScreen extends StatefulWidget {
  final List<String> initialImages;

  const ImageDisplayScreen({super.key, required this.initialImages});

  @override
  State<ImageDisplayScreen> createState() => _ImageDisplayScreenState();
}

class _ImageDisplayScreenState extends State<ImageDisplayScreen> {
  late List<String> _currentImages;
  late List<String> _initialImages;
  late bool _isEnableGallery;
  late bool _isEnableLink;

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<String> get finalImageUrls {
    // Tạo một bản sao để tránh sửa đổi trực tiếp _currentImages
    final List<String> result = List.from(_currentImages);
    // Loại bỏ placeholder "ADD_IMAGE_PLACEHOLDER" khỏi danh sách cuối cùng
    result.removeWhere((url) => url == _kAddImagePlaceholder);
    return result;
  }

  @override
  void initState() {
    super.initState();

    _initialImages = widget.initialImages;
    // Khởi tạo _currentImages với placeholder ở đầu
    _currentImages = [_kAddImagePlaceholder, ...List.from(_initialImages)];

    final importImagesOptions = AppDataManager().importImagesOptions;
    _isEnableGallery = importImagesOptions?.gallery ?? false;
    _isEnableLink = importImagesOptions?.link ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Chỉnh sửa ảnh'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 100.0),
            child: ReorderableGridView.builder(
              itemCount: _currentImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 cột ảnh
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final item = _currentImages[index];

                // Nếu là placeholder, hiển thị ô "Thêm ảnh"
                if (item == _kAddImagePlaceholder) {
                  return Card(
                    key: ValueKey(item), // Quan trọng: key vẫn phải duy nhất
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      // Dùng InkWell để tạo hiệu ứng chạm
                      onTap:
                          _showAddImageOptions, // Khi chạm vào, mở thư viện ảnh
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            Text(
                              'Thêm ảnh',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Nếu không phải placeholder, hiển thị ảnh thông thường
                  final imageUrl = item;
                  return Card(
                    key: ValueKey(imageUrl),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) {
                            print('Lỗi tải ảnh: $error cho URL: $url');
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                // Xóa ảnh thực sự (không phải placeholder)
                                _currentImages.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  // Ngăn không cho ô "Thêm ảnh" di chuyển
                  if (oldIndex == 0) {
                    return; // Không làm gì nếu người dùng cố gắng kéo ô đầu tiên
                  }

                  // Điều chỉnh newIndex nếu nó cố gắng chèn vào vị trí 0
                  if (newIndex == 0) {
                    newIndex = 1; // Luôn chèn sau ô "Thêm ảnh"
                  }

                  // Logic sắp xếp lại ảnh còn lại
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = _currentImages.removeAt(oldIndex);
                  _currentImages.insert(newIndex, item);
                });
              },
            ),
          ),
          // Phần cố định: Hai nút ở dưới cùng
          Positioned(
            left: 0,
            right: 0,
            bottom: 20, // Cố định ở dưới cùng
            child: Container(
              // Có thể dùng Container để thêm padding/margin hoặc màu nền
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor, // Màu nền trùng với Scaffold
              padding: const EdgeInsets.all(8.0),
              child: _buildActionButtons(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: CustomButton(
              title: 'Hoàn tác',
              textColor: AppColors.primary,
              backgroundColor: AppColors.onPrimary,
              strokeColor: AppColors.strokeLight,
              radius: 4.0,
              onPressed: () {
                _clearChanges();
              },
            ),
          ),
        ),
        const SizedBox(width: 36),
        Expanded(
          child: SizedBox(
            height: 38,
            child: CustomButton(
              title: 'Lưu',
              textColor: AppColors.onPrimary,
              backgroundColor: AppColors.primary,
              strokeColor: AppColors.strokeLight,
              radius: 4.0,
              onPressed: () {
                Navigator.pop(context, finalImageUrls);
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- Hàm mới để hiển thị dialog tùy chọn thêm ảnh ---
  void _showAddImageOptions() {
    if (_isEnableGallery && !_isEnableLink) {
      _pickImageFromGallery();
    } else if (!_isEnableGallery && _isEnableLink) {
      _showPasteLinkDialog();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Thêm ảnh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Chọn từ Thư viện',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.elementSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // Đóng dialog
                    _pickImageFromGallery(); // Gọi hàm chọn ảnh từ thư viện
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.link, color: AppColors.primary),
                  title: const Text(
                    'Dán liên kết ảnh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.elementSecondary,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // Đóng dialog
                    _showPasteLinkDialog(); // Gọi hàm hiển thị dialog dán link
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  // --- Hàm chọn ảnh từ thư viện (trước đây là _pickImage) ---
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageUrl = await _uploadImageToFirebase(File(image.path));
      if (imageUrl != null) {
        _addImageToList(imageUrl);
      }
    }
  }

  // --- Hàm hiển thị dialog để dán liên kết ảnh ---
  void _showPasteLinkDialog() {
    String? pastedLink;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Dán liên kết ảnh',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          content: TextField(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.elementPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'Nhập URL ảnh vào đây',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              pastedLink = value;
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 90,
                  height: 38,
                  child: CustomButton(
                    title: 'Hủy',
                    textColor: AppColors.primary,
                    backgroundColor: AppColors.onPrimary,
                    strokeColor: AppColors.strokeLight,
                    radius: 4.0,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 90,
                  height: 38,
                  child: CustomButton(
                    title: 'Thêm',
                    textColor: AppColors.onPrimary,
                    backgroundColor: AppColors.primary,
                    strokeColor: AppColors.strokeLight,
                    radius: 4.0,
                    onPressed: () {
                      if (pastedLink != null && pastedLink!.isNotEmpty) {
                        _addImageToList(pastedLink!.toImageUrl());
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vui lòng nhập một liên kết hợp lệ.'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // --- Hàm chung để thêm URL ảnh vào danh sách ---
  void _addImageToList(String imageUrl) {
    setState(() {
      _currentImages.add(imageUrl);
    });
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final String fileName =
          'images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
      final Reference ref = _storage.ref().child(fileName);
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Lỗi khi tải ảnh lên: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    setState(() {
      _initialImages = List.from(_currentImages);
    });
    print('Thứ tự ảnh đã lưu: $_currentImages');
  }

  void _clearChanges() {
    setState(() {
      _currentImages = [_kAddImagePlaceholder, ...List.from(_initialImages)];
    });
  }
}
