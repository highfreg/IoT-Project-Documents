import 'dart:io';
import 'package:sdp_1/main_page_socket.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';


class ExcelExporter {
  // Function to export list of DataModel to Excel
  static Future<String> exportToExcel(List<DataModel> dataList) async {
    var excel = Excel.createExcel(); // Create new Excel document
    Sheet sheetObject = excel['Sheet1']; // Create sheet

    // Sütun başlıklarını ekle
  sheetObject.appendRow([
    TextCellValue("ID"),
    TextCellValue("Device 1 ID"),
    TextCellValue("Device 1 Current (A)"),
    TextCellValue("Device 1 Power (W)"),
    TextCellValue("Device 2 ID"),
    TextCellValue("Device 2 Current (A)"),
    TextCellValue("Device 2 Power (W)"),
    TextCellValue("Timestamp")
  ]);

  // Her bir DataModel satırını tabloya ekle
  for (var data in dataList) {
    sheetObject.appendRow([
      TextCellValue(data.id.toString()), // int değerini stringe çevir
      TextCellValue(data.device1DeviceId), // Cihaz ID'si
      TextCellValue(data.device1Current.toString()), // double değerini stringe çevir
      TextCellValue(data.device1Power.toString()), // double değerini stringe çevir
      TextCellValue(data.device2DeviceId), // Cihaz ID'si
      TextCellValue(data.device2Current.toString()), // double değerini stringe çevir
      TextCellValue(data.device2Power.toString()), // double değerini stringe çevir
      TextCellValue(data.timestamp.toIso8601String()) // ISO formatında tarih
    ]);
  }
    // Request permission to write file (required for Android/iOS)
    try {
      // Save the file
      var directory =
          await getExternalStorageDirectory(); // Get the external directory
      // Append timestamp to filename for uniqueness
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String outputFile =
          '${directory!.path}/data_export_$timestamp.xlsx'; // File path
      var fileBytes = excel.save();

      // Write Excel to file
      File(outputFile)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes!);

      return 'Excel file exported to $outputFile'; // Return success message
    } catch (e) {
      return 'Error exporting Excel file: $e'; // Handle export error
    }
  }
}
