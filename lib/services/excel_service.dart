import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class ExcelService {
  static Future<void> exportMembersToExcel(List<QueryDocumentSnapshot> docs) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['ACP Members'];
    excel.delete('Sheet1');

    // Header Row
    sheetObject.appendRow([
      TextCellValue('N. Pratica'),
      TextCellValue('Full Name'),
      TextCellValue('Fiscal Code'),
      TextCellValue('Phone'),
      TextCellValue('Membership Type'),
      TextCellValue('Address'),
      TextCellValue('Status'),
      TextCellValue('Payment Status'),
      TextCellValue('Total Fee (€)'),
    ]);

    // Data Rows
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      sheetObject.appendRow([
        TextCellValue(data['nPratica']?.toString() ?? ''),
        TextCellValue(data['fullName']?.toString() ?? ''),
        TextCellValue(data['fiscalCode']?.toString() ?? ''),
        TextCellValue(data['phone']?.toString() ?? ''),
        TextCellValue(data['membershipType']?.toString() ?? ''),
        TextCellValue(data['addressItaly']?.toString() ?? ''),
        TextCellValue(data['status']?.toString() ?? 'Pending'),
        TextCellValue(data['paymentStatus']?.toString() ?? 'Pending'),
        TextCellValue(data['totalFee']?.toString() ?? '80'),
      ]);
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final directory = await getTemporaryDirectory();
      final filePath = "${directory.path}/ACP_Members_Export.xlsx";
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      // Share / Print / Save Excel File
      await Printing.sharePdf(bytes: await file.readAsBytes(), filename: 'ACP_Members_Report.xlsx');
    }
  }
}