import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class ExcelReaderPage extends StatefulWidget {
  const ExcelReaderPage({super.key});

  @override
  State<ExcelReaderPage> createState() => _ExcelReaderPageState();
}

class _ExcelReaderPageState extends State<ExcelReaderPage> {
  List<List<String>> _excelData = [];

  Future<void> _pickAndReadExcelFile() async {
    try {
      // Mở file picker để chọn file Excel
      FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        allowMultiple: false,
      );

      if (pickedFile != null) {
        // Lấy đường dẫn file
        String filePath = pickedFile.files.single.path!;
        // Đọc dữ liệu từ file
        var file = File(filePath);
        var bytes = await file.readAsBytes();

        // Đọc file Excel
        var excel = Excel.decodeBytes(bytes);
        List<List<String>> data = [];

        // Duyệt qua các sheet
        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          // Duyệt qua các hàng
          for (var row in sheet!.rows) {
            List<String> rowData = [];
            // Duyệt qua các ô, lọc giá trị null
            for (var cell in row) {
              rowData.add(cell?.value?.toString() ?? '');
            }
            data.add(rowData);
          }
        }

        // Cập nhật dữ liệu lên giao diện
        setState(() {
          _excelData = data;
        });
      }
    } catch (e) {
      print('Lỗi khi đọc file Excel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đọc File Excel')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickAndReadExcelFile,
            child: const Text('Chọn và Đọc File Excel'),
          ),
          Expanded(
            child: _excelData.isEmpty
                ? const Center(child: Text('Chưa có dữ liệu'))
                : ListView.builder(
                    itemCount: _excelData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_excelData[index].join(', ')),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
