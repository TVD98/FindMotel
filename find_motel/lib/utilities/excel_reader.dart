import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

class ExcelReader {
  Future<List<List<String>>> readExcelFile() async {
    try {
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (pickedFile != null) {
        // Lấy PlatformFile đầu tiên từ kết quả
        PlatformFile file = pickedFile.files.first;
        Uint8List? bytes; // Khai báo biến bytes để lưu trữ dữ liệu file

        if (kIsWeb) {
          // --- Xử lý trên WEB ---
          // Trên web, dữ liệu file được cung cấp trực tiếp dưới dạng bytes.
          if (file.bytes != null) {
            bytes = file.bytes;
          } else {
            print("Lỗi: Không đọc được dữ liệu byte của file trên web.");
            return [];
          }
        } else {
          // --- Xử lý trên MOBILE / DESKTOP ---
          // Trên mobile/desktop, có đường dẫn file.
          if (file.path != null) {
            var pickedFlutterFile = File(file.path!);
            bytes = await pickedFlutterFile.readAsBytes();
          } else {
            print("Lỗi: Không có đường dẫn file trên mobile/desktop.");
            return [];
          }
        }

        // Nếu đã có dữ liệu bytes (dù từ web hay mobile/desktop)
        if (bytes != null) {
          var excel = Excel.decodeBytes(bytes);
          List<List<String>> data = [];

          // Duyệt qua tất cả các bảng (sheets) trong file Excel
          for (var table in excel.tables.keys) {
            var sheet = excel.tables[table];
            if (sheet != null) {
              // Duyệt qua từng hàng trong sheet
              for (var row in sheet.rows) {
                List<String> rowData = [];
                // Duyệt qua từng ô trong hàng
                for (var cell in row) {
                  // Lấy giá trị của ô và chuyển đổi thành String, nếu null thì là chuỗi rỗng
                  rowData.add(cell?.value?.toString() ?? '');
                }
                data.add(rowData); // Thêm hàng dữ liệu vào danh sách
              }
              // Nếu bạn chỉ muốn đọc sheet đầu tiên, có thể thêm break ở đây
              break;
            }
          }
          return data;
        } else {
          print("Lỗi chung: Không lấy được dữ liệu file.");
          return [];
        }
      } else {
        // Người dùng đã hủy chọn file
        print("Người dùng đã hủy chọn file.");
        return [];
      }
    } catch (e) {
      // Xử lý bất kỳ lỗi nào xảy ra trong quá trình chọn hoặc đọc file
      print('Lỗi khi đọc file Excel: $e');
      return [];
    }
  }
}
