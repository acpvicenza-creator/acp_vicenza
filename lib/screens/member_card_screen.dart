import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MemberCardScreen extends StatelessWidget {
  final Map<String, dynamic> memberData;

  const MemberCardScreen({super.key, required this.memberData});

  Future<void> _exportCardPdf(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final pdf = pw.Document();

    final String name = memberData['fullName'] ?? 'Member';
    final String nPratica = memberData['nPratica'] ?? 'N/A';
    final String fiscalCode = memberData['fiscalCode'] ?? 'N/A';
    final String phone = memberData['phone'] ?? 'N/A';
    final String address = memberData['addressItaly'] ?? 'N/A';
    final String membershipType = memberData['membershipType'] ?? 'Single';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Center(
            child: pw.Container(
              width: 350,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFF043927),
                borderRadius: pw.BorderRadius.circular(16),
              ),
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ACP VICENZA',
                            style: pw.TextStyle(
                              color: PdfColors.amber,
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Digital Membership Card',
                            style: const pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0xFF0C5A32),
                          borderRadius: pw.BorderRadius.circular(6),
                        ),
                        child: pw.Text(
                          'ACTIVE ✅',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.white),
                  pw.SizedBox(height: 8),
                  pw.Text('N. PRATICA: $nPratica', style: pw.TextStyle(color: PdfColors.amber, fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('NAME: $name', style: pw.TextStyle(color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('CODICE FISCALE: $fiscalCode', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text('PHONE: $phone', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text('ADDRESS: $address', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  pw.SizedBox(height: 4),
                  pw.Text('PLAN: $membershipType', style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                  pw.SizedBox(height: 12),
                  pw.Center(
                    child: pw.BarcodeWidget(
                      data: nPratica,
                      barcode: pw.Barcode.qrCode(),
                      width: 70,
                      height: 70,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'ACP_Card_$nPratica.pdf',
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not generate PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);
    final String name = memberData['fullName'] ?? 'Member Name';
    final String nPratica = memberData['nPratica'] ?? 'ACP-2026-XXXX';
    final String fiscalCode = memberData['fiscalCode'] ?? 'N/A';
    final String phone = memberData['phone'] ?? 'N/A';
    final String address = memberData['addressItaly'] ?? 'N/A';
    final String membershipType = memberData['membershipType'] ?? 'Single';
    final String? photoUrl = memberData['photoUrl'];
    final String? signatureBase64 = memberData['signatureBase64'];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Digital Membership Card'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              // 🪪 DIGITAL MEMBERSHIP CARD FRONT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.account_balance, color: Colors.amber, size: 22),
                            ),
                            const SizedBox(width: 8),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ACP VICENZA',
                                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.8),
                                ),
                                Text(
                                  'Comitato Funebre Vicenza',
                                  style: TextStyle(color: Colors.white70, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C5A32),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            'ACTIVE ✅',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Colors.white24, height: 24),

                    // MEMBER INFO WITH PHOTO & QR
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PROFILE PHOTO
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (photoUrl != null && photoUrl.trim().isNotEmpty)
                              ? Image.network(
                            photoUrl,
                            width: 75,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderPhoto(),
                          )
                              : _buildPlaceholderPhoto(),
                        ),
                        const SizedBox(width: 14),

                        // DETAILS
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nPratica,
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'CF: $fiscalCode',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                              Text(
                                'Plan: $membershipType',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                              Text(
                                'Tel: $phone',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ADDRESS
                    Text(
                      'Address: $address',
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                    ),

                    const Divider(color: Colors.white24, height: 20),

                    // BOTTOM ROW (SIGNATURE & QR)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // SIGNATURE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Firma del Titolare:',
                              style: TextStyle(color: Colors.white60, fontSize: 9),
                            ),
                            const SizedBox(height: 4),
                            if (signatureBase64 != null && signatureBase64.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Image.memory(
                                  base64Decode(signatureBase64),
                                  height: 28,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Text('Signed', style: TextStyle(fontSize: 10, color: darkGreen)),
                                ),
                              )
                            else
                              const Text('Signed Digitally ✅', style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),

                        // QR CODE
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: QrImageView(
                            data: nPratica,
                            version: QrVersions.auto,
                            size: 55.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // PDF DOWNLOAD / PRINT BUTTON
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _exportCardPdf(context),
                  icon: const Icon(Icons.print_outlined),
                  label: const Text('Download / Print Membership Card (PDF)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPhoto() {
    return Container(
      width: 75,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, color: Colors.white60, size: 40),
    );
  }
}