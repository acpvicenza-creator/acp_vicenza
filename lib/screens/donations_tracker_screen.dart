import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'payment_screen.dart';

class DonationsTrackerScreen extends StatefulWidget {
  final Map<String, dynamic>? memberData;

  const DonationsTrackerScreen({super.key, this.memberData});

  @override
  State<DonationsTrackerScreen> createState() => _DonationsTrackerScreenState();
}

class _DonationsTrackerScreenState extends State<DonationsTrackerScreen> {
  final _amountCtrl = TextEditingController(text: '50');
  final _donorNameCtrl = TextEditingController();
  final _donorPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _donationType = 'General Sadaqah / Chanda';
  bool _isGeneratingReceipt = false;

  final List<String> _donationTypes = [
    'General Sadaqah / Chanda',
    'Emergency Funeral Fund Support',
    'Masjid Maintenance Fund',
    'Needy Family Assistance',
    'Zakat',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.memberData != null) {
      _donorNameCtrl.text = widget.memberData!['fullName'] ?? '';
      _donorPhoneCtrl.text = widget.memberData!['phone'] ?? '';
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _donorNameCtrl.dispose();
    _donorPhoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateDonationPdfReceipt({
    required String receiptNo,
    required String donorName,
    required double amount,
    required String category,
    required String paymentMethod,
  }) async {
    setState(() => _isGeneratingReceipt = true);
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  color: const PdfColor.fromInt(0xFF043927),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'ACP VICENZA - SADAQAH / DONATION RECEIPT',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'CONFIRMED ✅',
                        style: pw.TextStyle(color: PdfColors.amber, fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.TableHelper.fromTextArray(
                  headers: ['Details', 'Information'],
                  data: [
                    ['Receipt Number', receiptNo],
                    ['Donor Name', donorName],
                    ['Donation Category', category],
                    ['Amount Donated', '€${amount.toStringAsFixed(2)}'],
                    ['Payment Method', paymentMethod],
                    ['Issue Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF043927)),
                  cellPadding: const pw.EdgeInsets.all(8),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                ),

                pw.SizedBox(height: 25),
                pw.Text(
                  'May Allah accept your generous donation and bless your earnings with Barakah. (JazakAllah Khair)',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Associazione Culturale Comunità Pakistana Di Vicenza - Via R. Fabiani 47, Vicenza',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'ACP_Donation_$receiptNo.pdf',
      );
    } catch (_) {} finally {
      if (mounted) setState(() => _isGeneratingReceipt = false);
    }
  }

  void _openBankDetailsModal() {
    const String iban = "IT42 H060 4511 8000 0000 5006 673";
    const String bic = "CRBZIT2B130";
    const String bankHolder = "COMUNITÀ PAKISTANA DI VICENZA APS";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  'COORDINATE BANCARIE (DONAZIONI)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF043927)),
                ),
              ),
              const Divider(height: 25),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF043927)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Intestatario del conto:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const Text(bankHolder, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF043927))),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('IBAN:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              SelectableText(iban, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20, color: Color(0xFF043927)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: iban.replaceAll(' ', '')));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('IBAN copied!')));
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('BIC / SWIFT:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const Text(bic, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: const Text(
                  'Causale: Donazione Volontaria / Sadaqah',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF043927)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Sadaqah & Voluntary Fund'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER BANNER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.volunteer_activism, color: Colors.amber, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Support Fund',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Contribute voluntarily towards emergency repatriation, welfare & local needs.',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text('Contribution Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkGreen)),
            const SizedBox(height: 10),

            TextField(
              controller: _donorNameCtrl,
              decoration: const InputDecoration(labelText: 'Donor Name *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _donorPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Donation Amount (€) *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.euro)),
            ),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              initialValue: _donationType,
              decoration: const InputDecoration(labelText: 'Donation Purpose / Category', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category)),
              items: _donationTypes.map((t) {
                return DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _donationType = val);
              },
            ),

            const SizedBox(height: 20),

            // 💳 1. PAY DIRECTLY VIA STRIPE / CARD
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white),
                icon: const Icon(Icons.credit_card),
                label: const Text('Donate via Card / Online Wallet'),
                onPressed: () {
                  final amt = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
                  final donorName = _donorNameCtrl.text.trim();
                  final messenger = ScaffoldMessenger.of(context);

                  if (donorName.isEmpty || amt <= 0) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Please enter donor name and valid amount.')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        memberName: donorName,
                        praticaNumber: 'DONATION-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        amount: amt,
                        registrationData: {
                          'fullName': donorName,
                          'phone': _donorPhoneCtrl.text.trim(),
                          'donationCategory': _donationType,
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 🏦 2. BONIFICO BANCARIO DETAILS BUTTON
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: darkGreen,
                  side: const BorderSide(color: darkGreen),
                ),
                onPressed: _openBankDetailsModal,
                icon: const Icon(Icons.account_balance, size: 18),
                label: const Text('View Bank Account (Bonifico Details)'),
              ),
            ),

            const SizedBox(height: 10),

            // 📄 3. RECEIPT GENERATOR
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton.icon(
                onPressed: _isGeneratingReceipt
                    ? null
                    : () {
                  final amt = double.tryParse(_amountCtrl.text.trim()) ?? 50.0;
                  final donorName = _donorNameCtrl.text.trim().isNotEmpty ? _donorNameCtrl.text.trim() : 'Anonymous Donor';
                  final receiptNo = 'ACP-DON-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                  _generateDonationPdfReceipt(
                    receiptNo: receiptNo,
                    donorName: donorName,
                    amount: amt,
                    category: _donationType,
                    paymentMethod: 'Bank Transfer / Online',
                  );
                },
                icon: _isGeneratingReceipt
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.receipt_long, color: darkGreen),
                label: const Text('Generate Donation PDF Receipt', style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}