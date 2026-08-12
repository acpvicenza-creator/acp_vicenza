import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'member_card_screen.dart';
import 'payment_screen.dart';
import 'death_emergency_tracker_screen.dart';
import 'emergency_fund_appeal_screen.dart';
import '../services/renewal_service.dart';
import '../widgets/renewal_banner_widget.dart';

class MemberDashboardScreen extends StatefulWidget {
  final String memberDocId;
  const MemberDashboardScreen({super.key, required this.memberDocId});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  @override
  void initState() {
    super.initState();
    RenewalService.checkAndApplyAnnualRenewals();
  }

  void _openOnlinePaymentPage(Map<String, dynamic> data) {
    final double totalFee = (data['totalFee'] ?? 80.0).toDouble();
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Center(
                  child: Text(
                    'COORDINATE BANCARIE',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF043927),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Associazione Culturale Comunità Pakistana di Vicenza',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
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
                      const Text('Intestatario del conto:',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const Text(
                        bankHolder,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF043927),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('IBAN:',
                                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                                SelectableText(
                                  iban,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20, color: Color(0xFF043927)),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: iban.replaceAll(' ', '')));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('IBAN copied to clipboard!')),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('BIC / SWIFT:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const Text(bic, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      const Text('Filiale:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const Text(
                        'Cassa di Risparmio di Bolzano SpA\nFiliale 130 Vicenza - Via Alberto Franchetti 1',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade800),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Nella causale indicare:',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Causale: ${data['fullName']} - ${data['nPratica']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF043927),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Importo da Versare:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '€${totalFee.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF043927),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF043927),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _processPayment(ctx, 'Bonifico Bancario'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('I Have Sent the Bonifico'),
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF043927),
                      side: const BorderSide(color: Color(0xFF043927)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            memberName: data['fullName'] ?? '',
                            praticaNumber: data['nPratica'] ?? '',
                            amount: totalFee,
                            registrationData: data,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.credit_card, size: 18),
                    label: const Text('Pay via Credit Card / Digital Wallet'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processPayment(BuildContext bctx, String method) async {
    Navigator.pop(bctx);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await FirebaseFirestore.instance.collection('members').doc(widget.memberDocId).update({
      'paymentStatus': 'Payment Submitted (Pending Verification)',
      'paidAt': FieldValue.serverTimestamp(),
      'paymentMethod': method,
    });

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Bonifico Confirmation Submitted!'),
        content: const Text(
          'Thank you! Admin will verify your Bonifico Bancario and activate your digital membership card.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildPaymentRequiredBanner(BuildContext context, Map<String, dynamic> memberData) {
    final String status = memberData['status'] ?? '';
    final String paymentStatus = memberData['paymentStatus'] ?? '';

    if (status == 'Approved' && (paymentStatus == 'Payment Required' || paymentStatus == 'Pending Payment')) {
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade800),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Application Approved! 🎉',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Please complete your annual membership fee payment to activate your Digital Card.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF043927),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        memberName: memberData['fullName'] ?? '',
                        praticaNumber: memberData['nPratica'] ?? '',
                        amount: (memberData['totalFee'] as num?)?.toDouble() ?? 80.0,
                        registrationData: memberData,
                      ),
                    ),
                  );
                },
                child: const Text('Pay Now / Complete Registration'),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 📄 SUBMITTED DOCUMENTS CARD (WITH FRONT & BACK SUPPORT)
  Widget _buildSubmittedDocumentsCard(Map<String, dynamic> data) {
    final docUrls = data['documentUrls'] as Map<String, dynamic>? ?? {};

    final bool hasCartaFront = (docUrls['cartaIdentitaFront'] ?? data['cartaIdentitaFront'] ?? '').toString().isNotEmpty;
    final bool hasCartaBack = (docUrls['cartaIdentitaBack'] ?? data['cartaIdentitaBack'] ?? '').toString().isNotEmpty;
    final bool hasCartaOld = (docUrls['cartaIdentita'] ?? data['cartaIdentita'] ?? '').toString().isNotEmpty;

    final bool hasPakIdFront = (docUrls['pakIdCardFront'] ?? data['pakIdCardFront'] ?? '').toString().isNotEmpty;
    final bool hasPakIdBack = (docUrls['pakIdCardBack'] ?? data['pakIdCardBack'] ?? '').toString().isNotEmpty;
    final bool hasPakIdOld = (docUrls['pakIdCard'] ?? data['pakIdCard'] ?? '').toString().isNotEmpty;

    final bool hasPermessoFront = (docUrls['permessoSoggiornoFront'] ?? data['permessoSoggiornoFront'] ?? '').toString().isNotEmpty;
    final bool hasPermessoBack = (docUrls['permessoSoggiornoBack'] ?? data['permessoSoggiornoBack'] ?? '').toString().isNotEmpty;
    final bool hasPermessoOld = (docUrls['permessoSoggiorno'] ?? data['permessoSoggiorno'] ?? '').toString().isNotEmpty;

    final bool hasPassaporto = (docUrls['passaporto'] ?? data['passaporto'] ?? '').toString().isNotEmpty;
    final bool hasCF = (docUrls['codiceFiscale'] ?? data['codiceFiscale'] ?? '').toString().isNotEmpty;

    final bool hasDocs = hasCartaFront ||
        hasCartaBack ||
        hasCartaOld ||
        hasPakIdFront ||
        hasPakIdBack ||
        hasPakIdOld ||
        hasPermessoFront ||
        hasPermessoBack ||
        hasPermessoOld ||
        hasPassaporto ||
        hasCF;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Submitted Documents',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF043927),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock, size: 12, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Locked / Read-Only',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            if (!hasDocs)
              const Text(
                'No documents uploaded during registration.',
                style: TextStyle(color: Colors.redAccent, fontSize: 12),
              )
            else ...[
              if (hasCartaFront) _docStatusRow('Carta d\'Identità (Front)'),
              if (hasCartaBack) _docStatusRow('Carta d\'Identità (Back)'),
              if (!hasCartaFront && !hasCartaBack && hasCartaOld) _docStatusRow('Carta d\'Identità'),

              if (hasPakIdFront) _docStatusRow('Pakistan ID Card (Front)'),
              if (hasPakIdBack) _docStatusRow('Pakistan ID Card (Back)'),
              if (!hasPakIdFront && !hasPakIdBack && hasPakIdOld) _docStatusRow('Pakistan ID Card (CNIC)'),

              if (hasPermessoFront) _docStatusRow('Permesso di Soggiorno (Front)'),
              if (hasPermessoBack) _docStatusRow('Permesso di Soggiorno (Back)'),
              if (!hasPermessoFront && !hasPermessoBack && hasPermessoOld) _docStatusRow('Permesso di Soggiorno'),

              if (hasPassaporto) _docStatusRow('Passaporto'),
              if (hasCF) _docStatusRow('Codice Fiscale'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _docStatusRow(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
            ],
          ),
          const Text(
            'Attached ✅',
            style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showEditRequestDialog(Map<String, dynamic> currentData) {
    final phoneCtrl = TextEditingController(text: currentData['phone'] ?? '');
    final addressCtrl = TextEditingController(text: currentData['addressItaly'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Profile Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'New Phone Number', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'New Address in Italy', prefixIcon: Icon(Icons.home)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF043927),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);

              await FirebaseFirestore.instance.collection('profile_edit_requests').add({
                'memberDocId': widget.memberDocId,
                'memberName': currentData['fullName'] ?? 'Member',
                'requestedPhone': phoneCtrl.text.trim(),
                'requestedAddress': addressCtrl.text.trim(),
                'status': 'PENDING',
                'createdAt': FieldValue.serverTimestamp(),
              });

              nav.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Profile update request sent to Admin for approval! ✅')),
              );
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(Map<String, dynamic> currentData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account Request', style: TextStyle(color: Colors.red)),
        content: const Text(
          'Are you sure you want to request account deletion?\n\n'
              'According to ACP Vicenza rules, your profile will be submitted for admin review and removed from active membership.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);

              await FirebaseFirestore.instance.collection('account_deletion_requests').add({
                'memberDocId': widget.memberDocId,
                'memberName': currentData['fullName'] ?? 'Member',
                'nPratica': currentData['nPratica'] ?? '',
                'status': 'PENDING_DELETION',
                'requestedAt': FieldValue.serverTimestamp(),
              });

              await FirebaseFirestore.instance.collection('members').doc(widget.memberDocId).update({
                'deletionRequested': true,
              });

              nav.pop();
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted. Admin will process it shortly.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Confirm Delete Request'),
          ),
        ],
      ),
    );
  }

  void _addNewBornDialog(Map<String, dynamic> currentData) {
    final nameCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    final cfCtrl = TextEditingController();
    String gender = 'M';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Born Baby'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Baby Name *')),
                TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: 'DOB (DD/MM/YYYY) *')),
                TextField(controller: cfCtrl, decoration: const InputDecoration(labelText: 'Codice Fiscale')),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Gender: '),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Male (M)'),
                      selected: gender == 'M',
                      selectedColor: const Color(0xFF043927),
                      labelStyle: TextStyle(
                        color: gender == 'M' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) setDialogState(() => gender = 'M');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Female (F)'),
                      selected: gender == 'F',
                      selectedColor: const Color(0xFF043927),
                      labelStyle: TextStyle(
                        color: gender == 'F' ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) setDialogState(() => gender = 'F');
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || dobCtrl.text.isEmpty) return;

                  final nav = Navigator.of(ctx);
                  final messenger = ScaffoldMessenger.of(context);

                  List family = List.from(currentData['familyMembers'] ?? []);
                  family.add({
                    'fullName': nameCtrl.text.trim(),
                    'dob': dobCtrl.text.trim(),
                    'fiscalCode': cfCtrl.text.trim(),
                    'gender': gender,
                    'relation': 'New Born Child',
                  });

                  await FirebaseFirestore.instance.collection('members').doc(widget.memberDocId).update({
                    'familyMembers': family,
                  });

                  nav.pop();
                  messenger.showSnackBar(const SnackBar(content: Text('New Born Baby added!')));
                },
                child: const Text('Add Baby'),
              )
            ],
          );
        },
      ),
    );
  }

  void _addWifeDialog(Map<String, dynamic> currentData) {
    final nameCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    final cfCtrl = TextEditingController();
    final passportCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Wife (Family Addition)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Wife Name *')),
            TextField(controller: dobCtrl, decoration: const InputDecoration(labelText: 'DOB (DD/MM/YYYY) *')),
            TextField(controller: cfCtrl, decoration: const InputDecoration(labelText: 'Codice Fiscale *')),
            TextField(controller: passportCtrl, decoration: const InputDecoration(labelText: 'Passport Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || cfCtrl.text.isEmpty) return;

              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);

              List family = List.from(currentData['familyMembers'] ?? []);
              family.add({
                'fullName': nameCtrl.text.trim(),
                'dob': dobCtrl.text.trim(),
                'fiscalCode': cfCtrl.text.trim(),
                'passport': passportCtrl.text.trim(),
                'gender': 'F',
                'relation': 'Wife',
              });

              await FirebaseFirestore.instance.collection('members').doc(widget.memberDocId).update({
                'familyMembers': family,
                'membershipType': 'Family',
                'annualFee': 120.0,
                'totalFee': 140.0,
              });

              nav.pop();
              messenger.showSnackBar(const SnackBar(content: Text('Wife added & Plan updated to Family!')));
            },
            child: const Text('Add Wife'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('members').doc(widget.memberDocId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>?;

        if (data == null) {
          return const Scaffold(body: Center(child: Text('Member profile not found.')));
        }

        final String status = data['status'] ?? 'Pending Approval';
        final String paymentStatus = data['paymentStatus'] ?? 'Pending Payment';
        final List family = data['familyMembers'] ?? [];
        final double totalFee = (data['totalFee'] ?? 80.0).toDouble();

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          appBar: AppBar(
            title: const Text('Member Portal'),
            backgroundColor: darkGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.volunteer_activism, color: Colors.amberAccent),
                tooltip: 'Emergency Appeals & Sadqa',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmergencyFundAppealScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.emergency, color: Colors.redAccent),
                tooltip: 'Emergency Death SOS & Repatriation Tracker',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeathEmergencyTrackerScreen(memberData: data),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red.shade200),
                  ),
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.emergency_outlined, color: Colors.white),
                    ),
                    title: const Text(
                      'Emergency Death SOS & Legal Tracker',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.red),
                    ),
                    subtitle: const Text(
                      'Report death case or track live repatriation steps & Janazah.',
                      style: TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DeathEmergencyTrackerScreen(memberData: data),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                RenewalBannerWidget(
                  memberData: data,
                  onPayPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentScreen(
                          memberName: data['fullName'] ?? '',
                          praticaNumber: data['nPratica'] ?? '',
                          amount: totalFee,
                          registrationData: data,
                        ),
                      ),
                    );
                  },
                ),

                if (status == 'Deceased')
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.brightness_3, color: Colors.amber, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Member Record Marked as Deceased. Funeral repatriation case active.',
                                    style: TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DeathEmergencyTrackerScreen(memberData: data),
                                ),
                              );
                            },
                            icon: const Icon(Icons.track_changes, size: 16),
                            label: const Text(
                              'View Live Repatriation Steps & Janazah Info',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildPaymentRequiredBanner(context, data),

                Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: status == 'Deceased' ? Colors.grey.shade900 : darkGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'N. PRATICA: ${data['nPratica'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${data['fullName'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'CF: ${data['fiscalCode'] ?? ''}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          const Divider(color: Colors.white24, height: 20),

                          Row(
                            children: [
                              const Text('App Status: ', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              Flexible(
                                child: Text(
                                  status == 'Deceased' ? '🪦 Deceased' : status,
                                  style: TextStyle(
                                    color: status == 'Approved'
                                        ? Colors.greenAccent
                                        : (status == 'Deceased' ? Colors.redAccent : Colors.orangeAccent),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Payment: ', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              Flexible(
                                child: Text(
                                  paymentStatus,
                                  style: TextStyle(
                                    color: paymentStatus == 'Paid' ? Colors.greenAccent : Colors.amberAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      if (status == 'Approved' && paymentStatus == 'Paid')
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: SizedBox(
                            width: 90,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MemberCardScreen(memberData: data),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.qr_code, size: 14),
                              label: const Text('Digital Card', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                if (status == 'Approved' && paymentStatus != 'Paid')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade400),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Application Approved by Admin!',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please complete your annual membership fee payment (€${totalFee.toStringAsFixed(0)}) via Bonifico Bancario or Credit Card.',
                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: darkGreen,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _openOnlinePaymentPage(data),
                            icon: const Icon(Icons.account_balance),
                            label: Text('View Coordinate Bancarie (€${totalFee.toStringAsFixed(0)})'),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (status != 'Approved' && status != 'Deceased')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.hourglass_top, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your application is under review by ACP Admin. Coordinate Bancarie for payment will open once approved.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Family Members',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen),
                    ),
                    if (status != 'Deceased')
                      PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'baby') _addNewBornDialog(data);
                          if (val == 'wife') _addWifeDialog(data);
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'baby', child: Text('👶 Add New Born Baby')),
                          const PopupMenuItem(value: 'wife', child: Text('💍 Add Wife (If Married)')),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: darkGreen, borderRadius: BorderRadius.circular(8)),
                          child: const Row(
                            children: [
                              Icon(Icons.add, color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text('Update Family', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                if (family.isEmpty)
                  const Text('No family members added.', style: TextStyle(color: Colors.grey))
                else
                  ...family.map((f) => Card(
                    child: ListTile(
                      title: Text('${f['fullName']} (${f['gender']})'),
                      subtitle: Text(
                        'DOB: ${f['dob']} ${f['relation'] != null ? '| ${f['relation']}' : ''}',
                      ),
                    ),
                  )),

                const SizedBox(height: 20),
                const Text(
                  'Profile Information & Options',
                  style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      ListTile(title: const Text('Phone Number'), subtitle: Text(data['phone'] ?? 'N/A')),
                      ListTile(title: const Text('Address in Italy'), subtitle: Text(data['addressItaly'] ?? 'N/A')),
                      ListTile(title: const Text('Membership Fee Total'), subtitle: Text('€${data['totalFee'] ?? '0'}')),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _buildSubmittedDocumentsCard(data),

                const SizedBox(height: 16),

                if (status != 'Deceased') ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkGreen,
                        side: const BorderSide(color: darkGreen),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showEditRequestDialog(data),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text(
                        'Request Profile Details Update',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => _showDeleteAccountDialog(data),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text(
                        'Delete My Account (Privacy Request)',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}