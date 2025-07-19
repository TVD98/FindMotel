import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

class FirebaseStorageService {
  Future<String?> _uploadFile(File file, String folder) async {
    try {
      final String fileName = p.basename(file.path);
      final String destination =
          '$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final Reference storageRef = FirebaseStorage.instance.ref().child(
        destination,
      );

      final UploadTask uploadTask = storageRef.putFile(file);

      final TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<String?> uploadImage(String filePath) async {
    try {
      if (filePath.startsWith('http')) {
        return filePath;
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          print('File không tồn tại: $filePath');
          return null;
        }

        return _uploadFile(file, 'images');
      }
    } catch (e) {
      print('Lỗi upload ảnh: $e');
      return null;
    }
  }

  Future<List<String>> uploadImages(List<String> filePaths) async {
    final List<String> uploadedUrls = [];

    for (final filePath in filePaths) {
      final url = await uploadImage(filePath);
      if (url != null) {
        uploadedUrls.add(url);
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
