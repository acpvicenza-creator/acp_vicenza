import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ExcelExportService {
  // 📊 EXPORT MEMBERS LIST TO EXCEL
  static Future<void> exportMembersToExcel(List<Map<String, dynamic>> membersList) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Registered Members'];
    excel.delete('Sheet1');

    // Header Row
    sheet.appendRow([
      TextCellValue('N. Pratica'),
      TextCellValue('Full Name'),
      TextCellValue('Fiscal Code'),
      TextCellValue('Phone'),
      TextCellValue('Membership Type'),
      TextCellValue('Total Fee (€)'),
      TextCellValue('Application Status'),
      TextCellValue('Payment Status'),
      TextCellValue('Address in Italy'),
    ]);

    // Data Rows
    for (var member in membersList) {
      sheet.appendRow([
        TextCellValue(member['nPratica']?.toString() ?? ''),
        TextCellValue(member['fullName']?.toString() ?? ''),
        TextCellValue(member['fiscalCode']?.toString() ?? ''),
        TextCellValue(member['phone']?.toString() ?? ''),
        TextCellValue(member['membershipType']?.toString() ?? 'Single'),
        TextCellValue(member['totalFee']?.toString() ?? '0'),
        TextCellValue(member['status']?.toString() ?? 'Pending'),
        TextCellValue(member['paymentStatus']?.toString() ?? 'Pending Payment'),
        TextCellValue(member['addressItaly']?.toString() ?? ''),
      ]);
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/ACP_Members_Report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
      await file.writeAsBytes(fileBytes);
      await OpenFile.open(file.path);
    }
  }

  // 💰 EXPORT FINANCIAL LEDGER & EXPENSES TO EXCEL
  static Future<void> exportFinancialLedgerToExcel({
    required List<Map<String, dynamic>> membersList,
    required List<Map<String, dynamic>> expensesList,
  }) async {
    final excel = Excel.createExcel();

    // 1. Sheet: Summary & Reserve
    final Sheet summarySheet = excel['Financial Summary'];
    excel.delete('Sheet1');

    double totalIncome = 0.0;
    for (var m in membersList) {
      if ((m['paymentStatus'] ?? '') == 'Paid') {
        totalIncome += (m['totalFee'] as num?)?.toDouble() ?? 0.0;
      }
    }

    double totalExpenses = 0.0;
    for (var e in expensesList) {
      totalExpenses += (e['amount'] as num?)?.toDouble() ?? 0.0;
    }

    final double netReserve = totalIncome - totalExpenses;

    summarySheet.appendRow([TextCellValue('FINANCIAL SUMMARY - ACP VICENZA')]);
    summarySheet.appendRow([TextCellValue('')]);
    summarySheet.appendRow([TextCellValue('Total Collected (Paid Fees)'), TextCellValue('€${totalIncome.toStringAsFixed(2)}')]);
    summarySheet.appendRow([TextCellValue('Total Spent (Expenses/Repatriations)'), TextCellValue('€${totalExpenses.toStringAsFixed(2)}')]);
    summarySheet.appendRow([TextCellValue('Net Available Reserve Balance'), TextCellValue('€${netReserve.toStringAsFixed(2)}')]);

    // 2. Sheet: Income Transactions
    final Sheet incomeSheet = excel['Income Transactions'];
    incomeSheet.appendRow([
      TextCellValue('N. Pratica'),
      TextCellValue('Member Name'),
      TextCellValue('Payment Method'),
      TextCellValue('Amount (€)'),
      TextCellValue('Status'),
    ]);

    for (var m in membersList) {
      if ((m['paymentStatus'] ?? '') == 'Paid') {
        incomeSheet.appendRow([
          TextCellValue(m['nPratica']?.toString() ?? ''),
          TextCellValue(m['fullName']?.toString() ?? ''),
          TextCellValue(m['paymentMethod']?.toString() ?? 'Online / Bonifico'),
          TextCellValue('€${m['totalFee']?.toString() ?? '0'}'),
          TextCellValue('Paid ✅'),
        ]);
      }
    }

    // 3. Sheet: Expenses Ledger
    final Sheet expenseSheet = excel['Expense Ledger'];
    expenseSheet.appendRow([
      TextCellValue('Description'),
      TextCellValue('Category'),
      TextCellValue('Amount (€)'),
    ]);

    for (var e in expensesList) {
      expenseSheet.appendRow([
        TextCellValue(e['description']?.toString() ?? ''),
        TextCellValue(e['category']?.toString() ?? 'General'),
        TextCellValue('€${e['amount']?.toString() ?? '0'}'),
      ]);
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/ACP_Financial_Ledger_${DateTime.now().millisecondsSinceEpoch}.xlsx');
      await file.writeAsBytes(fileBytes);
      await OpenFile.open(file.path);
    }
  }
}