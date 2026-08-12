import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptGeneratorService {
  static Future<void> generateReceiptPdf(Map<String, dynamic> memberData) async {
    final pdf = pw.Document();

    final String name = memberData['fullName'] ?? 'Member';
    final String nPratica = memberData['nPratica'] ?? 'N/A';
    final String fiscalCode = memberData['fiscalCode'] ?? 'N/A';
    final String phone = memberData['phone'] ?? 'N/A';
    final String plan = memberData['membershipType'] ?? 'Single';
    final double amount = (memberData['totalFee'] as num?)?.toDouble() ?? 80.0;
    final now = DateTime.now();
    final String issueDate = '${now.day}/${now.month}/${now.year}';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                color: const PdfColor.fromInt(0xFF043927),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ACP VICENZA - OFFICIAL RECEIPT',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'PAID',
                      style: pw.TextStyle(
                        color: PdfColors.amber,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Table Details
              pw.TableHelper.fromTextArray(
                headers: ['Field', 'Details'],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 11,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF043927),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                cellStyle: const pw.TextStyle(fontSize: 10),
                data: [
                  ['N. Pratica', nPratica],
                  ['Member Name', name],
                  ['Fiscal Code', fiscalCode],
                  ['Contact Phone', phone],
                  ['Membership Plan', plan],
                  ['Total Amount Received', 'EUR ${amount.toStringAsFixed(2)}'],
                  ['Payment Status', 'CONFIRMED & ACTIVE'],
                  ['Issue Date', issueDate],
                ],
              ),

              pw.SizedBox(height: 25),

              pw.Text(
                'This document serves as an official proof of payment for the ACP Vicenza Benefit/Funeral Committee.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Associazione Culturale Comunita Pakistana Di Vicenza - Via R. Fabiani 47, Vicenza',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'ACP_Receipt_$nPratica.pdf',
    );
  }
}