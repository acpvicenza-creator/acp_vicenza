import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/member_model.dart';

class ExportService {
  // Master PDF Report Generator
  static Future<void> exportToPdfReport(List<MemberModel> members) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    try {
      final logoData = await rootBundle.load('assets/images/acp_logo.png');
      logoImage = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return [
            // Header Section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                if (logoImage != null)
                  pw.Image(logoImage, height: 40, width: 40)
                else
                  pw.Text(
                    'ACP',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: const PdfColor.fromInt(0xFF043927),
                    ),
                  ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'ACP VICENZA - MEMBERS MASTER LIST',
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF043927),
                      ),
                    ),
                    pw.Text(
                      'Total Members: ${members.length}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1, color: const PdfColor.fromInt(0xFF043927)),
            pw.SizedBox(height: 10),

            // Members Table (Using modern TableHelper)
            pw.TableHelper.fromTextArray(
              headers: ['Name', 'Fiscal Code', 'Phone', 'City', 'Reg Date'],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF043927),
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                ),
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              cellStyle: const pw.TextStyle(fontSize: 9),
              data: members.map((m) {
                return [
                  m.fullName,
                  m.fiscalCode,
                  m.phone,
                  m.city,
                  m.registrationDate.toString().split(' ')[0],
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'ACP_Members_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}