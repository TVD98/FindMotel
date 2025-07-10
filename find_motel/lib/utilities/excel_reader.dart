import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExcelReader {
  Future<List<List<String>>> readExcelFile() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );

    if (pickedFile != null) {
      String filePath = pickedFile.files.single.path!;
      var file = File(filePath);
      var bytes = await file.readAsBytes();

      var excel = Excel.decodeBytes(bytes);
      List<List<String>> data = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        for (var row in sheet!.rows) {
          List<String> rowData = [];
          for (var cell in row) {
            rowData.add(cell?.value?.toString() ?? '');
          }
          data.add(rowData);
        }
      }

      return data;
    }
    return [];
  }
}
