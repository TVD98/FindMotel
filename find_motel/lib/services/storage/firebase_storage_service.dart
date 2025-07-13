import 'dart:io';

class FirebaseStorageService {
  /// Upload một ảnh lên Firebase Storage
  /// Trả về URL của ảnh đã upload hoặc null nếu có lỗi
  /// Tạm thời trả về path gốc để không lỗi
  Future<String?> uploadImage(String filePath, String folder) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('File không tồn tại: $filePath');
        return null;
      }

      // TODO: Implement Firebase Storage upload
      // Tạm thời trả về path gốc
      return filePath;
    } catch (e) {
      print('Lỗi upload ảnh: $e');
      return null;
    }
  }

  /// Upload nhiều ảnh cùng lúc
  /// Trả về list URL của các ảnh đã upload
  Future<List<String>> uploadImages(
    List<String> filePaths,
    String folder,
  ) async {
    final List<String> uploadedUrls = [];

    for (final filePath in filePaths) {
      // Chỉ upload những ảnh local (không phải URL)
      if (!filePath.startsWith('http')) {
        final url = await uploadImage(filePath, folder);
        if (url != null) {
          uploadedUrls.add(url);
        }
      } else {
        // Giữ lại URL cũ
        uploadedUrls.add(filePath);
      }
    }

    return uploadedUrls;
  }

  /// Xóa ảnh từ Firebase Storage bằng URL
  Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      // TODO: Implement Firebase Storage delete
      // Tạm thời trả về true
      return true;
    } catch (e) {
      print('Lỗi xóa ảnh: $e');
      return false;
    }
  }
}
