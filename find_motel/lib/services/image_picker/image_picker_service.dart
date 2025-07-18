import 'package:find_motel/services/image_picker/image_source_option.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:find_motel/theme/app_colors.dart';
import 'package:find_motel/common/widgets/custom_button.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final BuildContext context;
  final Function(List<String> imageUrl) addImagesToList;
  final List<ImageSourceOption> options;

  bool get _isEnableGallery => options.contains(ImageSourceOption.gallery);
  bool get _isEnableLink => options.contains(ImageSourceOption.link);

  ImagePickerService({
    required this.context,
    required this.addImagesToList,
    this.options = ImageSourceOption.values,
  });

  Future<void> showAddImageOptions() async {
    if (_isEnableGallery && !_isEnableLink) {
      // Chỉ cho phép chọn từ thư viện
      await _pickImageFromGallery();
    } else if (!_isEnableGallery && _isEnableLink) {
      // Chỉ cho phép dán liên kết
      await _showPasteLinkDialog();
    } else {
      // Hiển thị dialog chọn cả hai tùy chọn
      await showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
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
                    Navigator.of(dialogContext).pop();
                    _pickImageFromGallery();
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
                    Navigator.of(dialogContext).pop();
                    _showPasteLinkDialog();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }

  /// Chọn ảnh từ thư viện và upload.
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageUrl = image.path;
      addImagesToList([imageUrl]);
    }
  }

  /// Hiển thị dialog cho phép người dùng dán liên kết ảnh.
  Future<void> _showPasteLinkDialog() async {
    String? pastedLink;
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
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
                      Navigator.pop(dialogContext);
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
                        addImagesToList([pastedLink!]);
                        Navigator.of(dialogContext).pop();
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
}
