import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfReceiptService {
  static Future<void> generateAndShareReceipt({
    required String memberName,
    required String memberId,
    required double amount,
    required String paymentType,
    required String transactionId,
    required String validUntil,
  }) async {
    final pdf = pw.Document();

    // App assets se logo load karein (ensure icon exist in assets)
    Uint8List? logoBytes;
    try {
      final logoData = await rootBundle.load('assets/images/logo.png');
      logoBytes = logoData.buffer.asUint8List();
    } catch (_) {}

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blueGrey900, width: 2),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with Logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    if (logoBytes != null)
                      pw.Image(pw.MemoryImage(logoBytes), width: 70, height: 70)
                    else
                      pw.Text('ACP', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('ASSOCIAZIONE CULTURALE PACHISTANA', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text('Vicenza (VI), Italy | CF: 95140650241', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        pw.Text('Official Death Committee Fund', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                pw.SizedBox(height: 15),

                // Receipt Badge
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: pw.BoxDecoration(color: PdfColors.blue900, borderRadius: pw.BorderRadius.circular(6)),
                    child: pw.Text('OFFICIAL PAYMENT RECEIPT', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 13)),
                  ),
                ),
                pw.SizedBox(height: 25),

                // Member & Payment Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    _buildRow('Member Name / Nome', memberName, isBold: true),
                    _buildRow('Member ID / N. Pratica', memberId),
                    _buildRow('Payment Purpose / Causale', paymentType),
                    _buildRow('Transaction Ref / ID', transactionId),
                    _buildRow('Issue Date / Data', '13/08/2026'),
                    _buildRow('Valid Until / Scadenza', validUntil),
                    _buildRow('Total Paid / Totale Versato', '€ ${amount.toStringAsFixed(2)}', isBold: true, highlight: true),
                  ],
                ),
                pw.SizedBox(height: 35),

                // Stamp / Signature & QR Code area
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(),
                      data: 'ACP-VERIFY:$memberId:$transactionId',
                      width: 65,
                      height: 65,
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.green800, width: 1.5),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text('VERIFIED & SIGNED', style: pw.TextStyle(color: PdfColors.green800, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('ACP Administration Vicenza', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Print Preview & Direct Share (WhatsApp, Email, AirPrint)
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_$memberId.pdf',
    );
  }

  static pw.TableRow _buildRow(String title, String value, {bool isBold = false, bool highlight = false}) {
    return pw.TableRow(
      decoration: highlight ? const pw.BoxDecoration(color: PdfColors.grey100) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(title, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, color: highlight ? PdfColors.blue900 : PdfColors.black)),
        ),
      ],
    );
  }
}