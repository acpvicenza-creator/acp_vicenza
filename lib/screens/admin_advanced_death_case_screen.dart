import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/audit_log_service.dart';

class AdminAdvancedDeathCaseScreen extends StatefulWidget {
  const AdminAdvancedDeathCaseScreen({super.key});

  @override
  State<AdminAdvancedDeathCaseScreen> createState() => _AdminAdvancedDeathCaseScreenState();
}

class _AdminAdvancedDeathCaseScreenState extends State<AdminAdvancedDeathCaseScreen> {
  final _praticaCtrl = TextEditingController();
  final _deceasedNameCtrl = TextEditingController();
  final _funeralAgencyCostCtrl = TextEditingController(text: '3500');
  final _consulateCostCtrl = TextEditingController(text: '300');
  final _airCargoCostCtrl = TextEditingController(text: '1400');
  final _companionTicketCtrl = TextEditingController(text: '800');
  final _janazaTimeCtrl = TextEditingController();
  final _janazaLocationCtrl = TextEditingController();
  final _mapsUrlCtrl = TextEditingController();

  int _selectedStep = 1;

  @override
  void dispose() {
    _praticaCtrl.dispose();
    _deceasedNameCtrl.dispose();
    _funeralAgencyCostCtrl.dispose();
    _consulateCostCtrl.dispose();
    _airCargoCostCtrl.dispose();
    _companionTicketCtrl.dispose();
    _janazaTimeCtrl.dispose();
    _janazaLocationCtrl.dispose();
    _mapsUrlCtrl.dispose();
    super.dispose();
  }

  double get _totalExpense {
    final c1 = double.tryParse(_funeralAgencyCostCtrl.text) ?? 0;
    final c2 = double.tryParse(_consulateCostCtrl.text) ?? 0;
    final c3 = double.tryParse(_airCargoCostCtrl.text) ?? 0;
    final c4 = double.tryParse(_companionTicketCtrl.text) ?? 0;
    return c1 + c2 + c3 + c4;
  }

  Future<void> _saveDeathCase() async {
    final String nPratica = _praticaCtrl.text.trim().toUpperCase();
    final String name = _deceasedNameCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    if (nPratica.isEmpty || name.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter N. Pratica and Deceased Name')),
      );
      return;
    }

    if (_totalExpense > 6000.0) {
      messenger.showSnackBar(
        SnackBar(content: Text('Warning: Total Expense (€$_totalExpense) exceeds the official €6,000 Cap!')),
      );
    }

    // 1. Save Case Log in Firestore
    await FirebaseFirestore.instance.collection('death_cases').add({
      'nPratica': nPratica,
      'deceasedName': name,
      'agencyCost': double.tryParse(_funeralAgencyCostCtrl.text) ?? 0,
      'consulateCost': double.tryParse(_consulateCostCtrl.text) ?? 0,
      'cargoCost': double.tryParse(_airCargoCostCtrl.text) ?? 0,
      'companionTicketCost': double.tryParse(_companionTicketCtrl.text) ?? 0,
      'totalSpent': _totalExpense,
      'maxCap': 6000.0,
      'step': _selectedStep,
      'janazaTime': _janazaTimeCtrl.text.trim(),
      'janazaLocation': _janazaLocationCtrl.text.trim(),
      'janazaMapsUrl': _mapsUrlCtrl.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Update Member Record
    final memberQuery = await FirebaseFirestore.instance.collection('members').where('nPratica', isEqualTo: nPratica).get();
    if (memberQuery.docs.isNotEmpty) {
      await memberQuery.docs.first.reference.update({
        'status': 'Deceased',
        'repatriationStep': _selectedStep,
        'janazaTime': _janazaTimeCtrl.text.trim(),
        'janazaLocation': _janazaLocationCtrl.text.trim(),
        'janazaMapsUrl': _mapsUrlCtrl.text.trim(),
      });
    }

    // 3. Post to Ledger Expenses
    await FirebaseFirestore.instance.collection('expenses').add({
      'description': 'Funeral Repatriation: $name ($nPratica)',
      'amount': _totalExpense,
      'category': 'Funeral Repatriation',
      'date': FieldValue.serverTimestamp(),
    });

    await AuditLogService.logAction(
      actionTitle: 'Repatriation Case Logged',
      details: 'Logged €$_totalExpense for $name ($nPratica) at Step $_selectedStep',
    );

    messenger.showSnackBar(
      const SnackBar(content: Text('Repatriation Case & Schedule Updated! ✅'), backgroundColor: Colors.green),
    );
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Funeral Case & €6,000 Cap'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Case Identifiers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(controller: _praticaCtrl, decoration: const InputDecoration(labelText: 'N. Pratica *', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _deceasedNameCtrl, decoration: const InputDecoration(labelText: 'Deceased Name *', border: OutlineInputBorder())),

            const SizedBox(height: 20),
            const Text('Repatriation Progress Step (Live Tracker)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _selectedStep,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 1, child: Text('1. Medical Death Certificate Done')),
                DropdownMenuItem(value: 2, child: Text('2. Comune Clearance & Sigillo Done')),
                DropdownMenuItem(value: 3, child: Text('3. Pakistan Consulate NOC Done')),
                DropdownMenuItem(value: 4, child: Text('4. Air Cargo & Ticket Booked')),
                DropdownMenuItem(value: 5, child: Text('5. Case Completed & Handed Over')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedStep = v);
              },
            ),

            const SizedBox(height: 20),
            const Text('Expense Disbursement (€6,000 Official Cap Breakdown)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _funeralAgencyCostCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Funeral Agency (Pompe Funebri) €', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _consulateCostCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Embassy / Legal Stamp Fee €', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _airCargoCostCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Air Cargo Box Fee €', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _companionTicketCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Companion Flight Ticket (Rule 5) €', border: OutlineInputBorder()),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _totalExpense > 6000 ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _totalExpense > 6000 ? Colors.red : Colors.green),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Disbursement:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '€${_totalExpense.toStringAsFixed(2)} / €6,000.00',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _totalExpense > 6000 ? Colors.red : Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text('Namaz-e-Janazah Community Broadcast Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(controller: _janazaTimeCtrl, decoration: const InputDecoration(labelText: 'Date & Time (e.g. 14 Aug, 18:30)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _janazaLocationCtrl, decoration: const InputDecoration(labelText: 'Masjid Name & Address', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _mapsUrlCtrl, decoration: const InputDecoration(labelText: 'Google Maps Link', border: OutlineInputBorder())),

            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white),
                onPressed: _saveDeathCase,
                icon: const Icon(Icons.save),
                label: const Text('Update Repatriation Case & Notify Members'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}