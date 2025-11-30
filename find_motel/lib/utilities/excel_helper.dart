import 'dart:io';
import 'package:find_motel/common/models/motel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ExcelData {
  final String sheetName;
  final List<List<String>> data;

  ExcelData({required this.sheetName, required this.data});
}

class ExcelHelper {
  Future<List<ExcelData>> readExcelFile() async {
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
          List<ExcelData> data = [];

          // Duyệt qua tất cả các bảng (sheets) trong file Excel
          for (var table in excel.tables.keys) {
            var sheet = excel.tables[table];
            if (sheet != null) {
              // Duyệt qua từng hàng trong sheet
              List<List<String>> sheetData = [];
              for (var row in sheet.rows) {
                List<String> rowData = [];
                // Duyệt qua từng ô trong hàng
                for (var cell in row) {
                  // Lấy giá trị của ô và chuyển đổi thành String, nếu null thì là chuỗi rỗng
                  rowData.add(cell?.value?.toString() ?? '');
                }
                sheetData.add(rowData);
              }
              data.add(ExcelData(sheetName: table, data: sheetData));
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

  /// Lấy thư mục lưu file của app (tạo nếu chưa có)
  Future<Directory> _getAppExportDirectory() async {
    final Directory baseDir;
    if (Platform.isIOS) {
      // iOS: Dùng Documents directory (có thể truy cập qua Files app)
      baseDir = await getApplicationDocumentsDirectory();
    } else {
      // Android: Dùng external storage để user có thể truy cập dễ dàng
      final externalDir = await getExternalStorageDirectory();
      baseDir = externalDir ?? await getApplicationDocumentsDirectory();
    }

    // Tạo thư mục FindMotel
    final appDir = Directory('${baseDir.path}/FindMotel');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  Future<String> overwriteExcelFile(
    List<List<String>> newData, {
    String excelFilePath = 'assets/files/template.xlsx',
    int startRow = 2,
    bool openAfterSave = true,
  }) async {
    try {
      // 1. Đọc file Excel từ thư mục assets
      ByteData data = await rootBundle.load(excelFilePath);
      var bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
      var excel = Excel.decodeBytes(bytes);

      // 2. Chọn sheet cần ghi đè
      String sheetName = excel.getDefaultSheet()!;
      var sheet = excel.tables[sheetName]!;

      // 3. Ghi dữ liệu mới
      for (int rowIndex = startRow; rowIndex < newData.length; rowIndex++) {
        List<String> rowData = newData[rowIndex];
        for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
          var cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex,
            ),
          );
          cell.value = rowData[colIndex];
        }
      }

      // 4. Lưu file Excel vào thư mục app
      final appDir = await _getAppExportDirectory();
      final fileName =
          'motels_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${appDir.path}/$fileName';

      var newFile = File(filePath);
      await newFile.writeAsBytes(excel.save()!);

      // 5. Mở file sau khi lưu
      if (openAfterSave && !kIsWeb) {
        await OpenFilex.open(filePath);
      }

      return filePath;
    } catch (e) {
      return 'Đã xảy ra lỗi khi xuất file: $e';
    }
  }

  /// Xuất danh sách motels ra file Excel mới, lưu vào thư mục documents của thiết bị
  Future<String> exportMotelsToExcel(List<Motel> motels) async {
    try {
      // Dữ liệu
      List<List<String>> data = [];
      for (final index in motels.indexed) {
        final motel = index.$2;
        final mapData = motel.getRowData();
        List<String> rowData = [
          index.$1.toString(),
          mapData['number'] ?? '',
          mapData['street'] ?? '',
          mapData['ward'] ?? '',
          mapData['district'] ?? '',
          mapData['type'] ?? '',
          mapData['roomCode'] ?? '',
          mapData['price'] ?? '',
          mapData['texture'] ?? '',
          mapData['elevator'] ?? '',
          mapData['commission'] ?? '',
          mapData['electricity'] ?? '',
          mapData['water'] ?? '',
          mapData['other'] ?? '',
          mapData['car'] ?? '',
          mapData['note'] ?? '',
          mapData['images'] ?? '',
          mapData['location'] ?? '',
          mapData['phone_numbers'] ?? '',
        ];
        data.add(rowData);
      }

      return await overwriteExcelFile(data);
    } catch (e) {
      return 'Đã xảy ra lỗi khi xuất file Excel: $e';
    }
  }
}
