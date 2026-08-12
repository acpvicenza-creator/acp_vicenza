import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateMemberRegistrationPdf(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    // 🟢 1. LOAD OFFICIAL ACP LOGO FROM ASSETS
    pw.ImageProvider? logoImage;
    try {
      final logoBytes = await rootBundle.load('assets/images/acp_logo.png');
      logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      logoImage = null;
    }

    // 🖊️ 2. LOAD MEMBER SIGNATURE (BASE64 OR RAW BYTES)
    pw.ImageProvider? signatureImage;
    try {
      final String? sigData = data['signatureBase64'] ?? data['signatureData'];
      if (sigData != null && sigData.isNotEmpty) {
        final cleanBase64 = sigData.contains(',') ? sigData.split(',').last : sigData;
        final sigBytes = base64Decode(cleanBase64);
        signatureImage = pw.MemoryImage(sigBytes);
      }
    } catch (_) {
      signatureImage = null;
    }

    // EXTRACT MEMBER DATA
    final String nPratica = data['nPratica'] ?? 'N/A';
    final String fullName = data['fullName'] ?? '';
    final String email = data['email'] ?? 'N/A';
    final String dob = data['dob'] ?? '';
    final String fiscalCode = data['fiscalCode'] ?? '';
    final String gender = data['gender'] ?? 'M';
    final String phone = data['phone'] ?? '';
    final String passport = data['passport'] ?? '';
    final String idCard = data['idCard'] ?? '';
    final String permesso = data['permessoSoggiornoText'] ?? data['permessoSoggiorno'] ?? '';
    final String cittadinanza = data['cittadinanza'] ?? '';
    final String phonePak = data['phonePakistan'] ?? '';
    final String italyAddress = data['addressItaly'] ?? '';
    final String comuneProvincia = data['comuneProvincia'] ?? '';
    final String pakAddress = data['addressPakistan'] ?? '';
    final String fatherName = data['fatherName'] ?? '';

    final List familyMembers = data['familyMembers'] ?? [];

    // DOCUMENT ATTACHMENT STATUS
    final docUrls = data['documentUrls'] as Map<String, dynamic>? ?? {};
    final bool hasCarta = (data['cartaIdentita'] ?? data['cartaIdentitaUrl'] ?? docUrls['cartaIdentita'] ?? '').toString().isNotEmpty;
    final bool hasPassaporto = (data['passaporto'] ?? data['passaportoUrl'] ?? docUrls['passaporto'] ?? '').toString().isNotEmpty;
    final bool hasPermesso = (data['permessoSoggiorno'] ?? data['permessoSoggiornoUrl'] ?? docUrls['permessoSoggiorno'] ?? '').toString().isNotEmpty;
    final bool hasCF = (data['codiceFiscale'] ?? data['codiceFiscaleUrl'] ?? docUrls['codiceFiscale'] ?? '').toString().isNotEmpty;

    const PdfColor darkGreen = PdfColor.fromInt(0xFF043927);
    const PdfColor labelBg = PdfColor.fromInt(0xFFE8F0EC);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(18),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER WITH OFFICIAL LOGO
              pw.Container(
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: darkGreen, width: 1.5),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      width: 60,
                      height: 60,
                      padding: const pw.EdgeInsets.all(2),
                      child: logoImage != null
                          ? pw.Image(logoImage, fit: pw.BoxFit.contain)
                          : pw.Container(
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: darkGreen, width: 1.5),
                        ),
                        child: pw.Center(
                          child: pw.Text('A.C.P.', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: darkGreen)),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Associazione Culturale Comunita Pakistana Di Vicenza',
                            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: darkGreen),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            '3296142116 - 3280452178 - 3202131444',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.Text(
                            'Acpvicenza@gmail.com  |  www.Acpvicenza.it',
                            style: const pw.TextStyle(fontSize: 9),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'MODULO ISCRIZIONE PER IL COMITATO FUNEBRE',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      '(NOTE: Si prega di rispondere a tutte le domande presenti nel modulo)',
                      style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // N. PRATICA BOX
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
                child: pw.Row(
                  children: [
                    pw.Container(
                      width: 110,
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      color: labelBg,
                      child: pw.Text('N. PRATICA:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      child: pw.Text(nPratica, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10.5, color: darkGreen)),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // 👤 DATI DEL RICHIEDENTE GRID TABLE
              pw.Text('DATI DEL RICHIEDENTE / CAPOFAMIGLIA', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
              pw.SizedBox(height: 3),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.8),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.2),
                  1: const pw.FlexColumnWidth(3.2),
                  2: const pw.FlexColumnWidth(2.2),
                  3: const pw.FlexColumnWidth(3.2),
                },
                children: [
                  _buildGridRow('Nome e Cognome', fullName, 'Data di nascita', dob, labelBg),
                  _buildGridRow('Codice Fiscale', fiscalCode, 'Sesso M / F', gender, labelBg),
                  _buildGridRow('Indirizzo Email', email, 'Numero di telefono', phone, labelBg),
                  _buildGridRow('Carta d\'identita', idCard, 'Numero passaporto', passport, labelBg),
                  _buildGridRow('Permesso soggiorno', permesso, 'Telefono in Pakistan', phonePak, labelBg),
                  _buildGridRow('Cittadinanza', cittadinanza, 'Comune / Provincia', comuneProvincia, labelBg),
                  _buildGridRow('Indirizzo in Italia', italyAddress, 'Nome del Padre', fatherName, labelBg),
                  _buildGridRow('Indirizzo in Pakistan', pakAddress, '', '', labelBg),
                ],
              ),

              pw.SizedBox(height: 8),

              // DATI DEI FAMILIARI TABLE
              pw.Text('DATI DEI FAMILIARI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
              pw.SizedBox(height: 3),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey700, width: 0.8),
                columnWidths: {
                  0: const pw.FixedColumnWidth(18),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2.6),
                  4: const pw.FixedColumnWidth(22),
                  5: const pw.FlexColumnWidth(2),
                  6: const pw.FlexColumnWidth(2),
                  7: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: darkGreen),
                    children: [
                      _buildHeaderCell('N.'),
                      _buildHeaderCell('Nome e Cognome'),
                      _buildHeaderCell('Data nascita'),
                      _buildHeaderCell('Codice Fiscale'),
                      _buildHeaderCell('M/F'),
                      _buildHeaderCell('Telefono'),
                      _buildHeaderCell('Passaporto'),
                      _buildHeaderCell('Cittadinanza'),
                    ],
                  ),

                  ...List.generate(6, (index) {
                    if (index < familyMembers.length) {
                      final f = familyMembers[index];
                      return pw.TableRow(
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell(f['fullName'] ?? ''),
                          _buildTableCell(f['dob'] ?? ''),
                          _buildTableCell(f['fiscalCode'] ?? ''),
                          _buildTableCell(f['gender'] ?? ''),
                          _buildTableCell(f['phone'] ?? ''),
                          _buildTableCell(f['passport'] ?? ''),
                          _buildTableCell(f['cittadinanza'] ?? ''),
                        ],
                      );
                    } else {
                      return pw.TableRow(
                        children: [
                          _buildTableCell('${index + 1}'),
                          _buildTableCell(''),
                          _buildTableCell(''),
                          _buildTableCell(''),
                          _buildTableCell(''),
                          _buildTableCell(''),
                          _buildTableCell(''),
                          _buildTableCell(''),
                        ],
                      );
                    }
                  }),
                ],
              ),

              pw.SizedBox(height: 6),

              // DOCUMENTI ALLEGATI
              pw.Text('DOCUMENTI ALLEGATI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
              pw.SizedBox(height: 3),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildCheckboxItem('Copia carta d\'identita', hasCarta),
                  _buildCheckboxItem('Copia passaporto', hasPassaporto),
                  _buildCheckboxItem('Copia permesso di soggiorno', hasPermesso),
                  _buildCheckboxItem('Codice fiscale', hasCF),
                ],
              ),

              pw.SizedBox(height: 6),

              pw.Text(
                'Ho letto tutte le regole e regolamenti del Benefit Committee e concordato. Data: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const pw.TextStyle(fontSize: 7.5),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Vista eletta l\'informativa consegnatami a norma di legge 196/03 Autorizzo il trattamento dei dati personali ai sensi della legge sulla privacy.',
                style: const pw.TextStyle(fontSize: 7.5),
              ),

              pw.Spacer(),

              // 🖊️ SIGNATURE FOOTER BOX WITH DIGITAL SIGNATURE EMBED
              pw.Container(
                padding: const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black, width: 0.8)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Luogo e data: Vicenza, ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Firma: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                        signatureImage != null
                            ? pw.Container(
                          height: 28,
                          width: 90,
                          child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
                        )
                            : pw.Text('_________________________________________', style: const pw.TextStyle(fontSize: 8.5)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.Text(
                  'Associazione Culturale Comunita Pakistana Di Vicenza - Tel: 3280452178 - Email: Acpvicenza@gmail.com',
                  style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'ACP_Dossier_$nPratica.pdf',
    );
  }

  static pw.TableRow _buildGridRow(String label1, String val1, String label2, String val2, PdfColor labelBg) {
    return pw.TableRow(
      children: [
        pw.Container(
          color: labelBg,
          padding: const pw.EdgeInsets.all(3.5),
          child: pw.Text(label1, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(3.5),
          child: pw.Text(val1, style: const pw.TextStyle(fontSize: 7.5)),
        ),
        pw.Container(
          color: labelBg,
          padding: const pw.EdgeInsets.all(3.5),
          child: pw.Text(label2, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(3.5),
          child: pw.Text(val2, style: const pw.TextStyle(fontSize: 7.5)),
        ),
      ],
    );
  }

  static pw.Widget _buildHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 6.5),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 2),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: const pw.TextStyle(fontSize: 6.5),
      ),
    );
  }

  static pw.Widget _buildCheckboxItem(String label, bool isChecked) {
    return pw.Row(
      children: [
        pw.Container(
          width: 9,
          height: 9,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 0.8),
          ),
          child: isChecked
              ? pw.Center(child: pw.Text('✓', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)))
              : pw.SizedBox(),
        ),
        pw.SizedBox(width: 3),
        pw.Text(label, style: const pw.TextStyle(fontSize: 7.5)),
      ],
    );
  }
}