import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelExporter {
  static Future<void> exportMembersToExcel(List<QueryDocumentSnapshot> docs) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['ACP Members Ledger'];
    excel.delete('Sheet1'); // Remove default sheet

    // Header Row
    List<String> headers = [
      'N. Pratica',
      'Full Name',
      'Fiscal Code',
      'Phone',
      'Membership Type',
      'Annual Fee (€)',
      'Registration Fee (€)',
      'Total Fee (€)',
      'App Status',
      'Payment Status',
      'Registration Date'
    ];

    sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Data Rows
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Safe Timestamp parsing
      String createdAt = 'N/A';
      if (data['createdAt'] != null) {
        if (data['createdAt'] is Timestamp) {
          createdAt = (data['createdAt'] as Timestamp).toDate().toString().split(' ')[0];
        } else if (data['createdAt'] is String) {
          createdAt = (data['createdAt'] as String).split('T')[0];
        }
      }

      sheetObject.appendRow([
        TextCellValue(data['nPratica'] ?? ''),
        TextCellValue(data['fullName'] ?? ''),
        TextCellValue(data['fiscalCode'] ?? ''),
        TextCellValue(data['phone'] ?? ''),
        TextCellValue(data['membershipType'] ?? 'Single'),
        DoubleCellValue((data['annualFee'] as num?)?.toDouble() ?? 0.0),
        DoubleCellValue((data['registrationFee'] as num?)?.toDouble() ?? 0.0),
        DoubleCellValue((data['totalFee'] as num?)?.toDouble() ?? 0.0),
        TextCellValue(data['status'] ?? 'Pending'),
        TextCellValue(data['paymentStatus'] ?? 'Pending'),
        TextCellValue(createdAt),
      ]);
    }

    // Save and Share File
    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/ACP_Financial_Ledger_${DateTime.now().millisecondsSinceEpoch}.xlsx";
    final fileBytes = excel.save();

    if (fileBytes != null) {
      final file = File(filePath);
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes);

      // Native system share dialog
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'ACP Vicenza Financial Ledger (.xlsx)',
      );
    }
  }
}