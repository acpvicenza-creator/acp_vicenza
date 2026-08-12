import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class DeathEmergencyTrackerScreen extends StatefulWidget {
  final Map<String, dynamic> memberData;
  const DeathEmergencyTrackerScreen({super.key, required this.memberData});

  @override
  State<DeathEmergencyTrackerScreen> createState() => _DeathEmergencyTrackerScreenState();
}

class _DeathEmergencyTrackerScreenState extends State<DeathEmergencyTrackerScreen> {
  bool _isSendingAlert = false;

  Future<void> _sendEmergencyAlert() async {
    setState(() => _isSendingAlert = true);
    final String memberName = widget.memberData['fullName'] ?? 'Member';
    final String nPratica = widget.memberData['nPratica'] ?? 'N/A';
    final String phone = widget.memberData['phone'] ?? '';

    try {
      await FirebaseFirestore.instance.collection('death_sos_alerts').add({
        'nPratica': nPratica,
        'memberName': memberName,
        'contactPhone': phone,
        'status': 'EMERGENCY_REPORTED',
        'reportedAt': FieldValue.serverTimestamp(),
      });

      // Update Member Status in system
      final query = await FirebaseFirestore.instance
          .collection('members')
          .where('nPratica', isEqualTo: nPratica)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'status': 'Deceased',
          'repatriationStep': 1,
        });
      }

      // Trigger Direct WhatsApp SOS to Executive Admin Hotline
      const String adminPhone = "+393400000000"; // 👈 Official ACP Hotline Number
      final String alertMsg = Uri.encodeComponent(
        "🚨 *EMERGENCY DEATH NOTIFICATION (ACP VICENZA)* 🚨\n\n"
            "Name: $memberName\n"
            "N. Pratica: $nPratica\n"
            "Family Contact: $phone\n\n"
            "Urgent funeral/repatriation assistance required under ACP Rules.",
      );
      final Uri whatsappUrl = Uri.parse("whatsapp://send?phone=$adminPhone&text=$alertMsg");

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS Alert sent to ACP Emergency Committee! ✅'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reporting SOS: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingAlert = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);
    final String nPratica = widget.memberData['nPratica'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Funeral & Repatriation Tracker'),
        backgroundColor: Colors.red.shade900,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('members')
            .where('nPratica', isEqualTo: nPratica)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.docs.isNotEmpty
              ? snapshot.data!.docs.first.data() as Map<String, dynamic>
              : widget.memberData;

          final int step = data['repatriationStep'] ?? 0;
          final String status = data['status'] ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🚨 SOS BUTTON (Agar pehle report nahi hua)
                if (status != 'Deceased') ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Emergency Death Intimation (SOS)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pressing this button will instantly alert the ACP Funeral Committee and initiate emergency protocols.',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _isSendingAlert ? null : _sendEmergencyAlert,
                            icon: const Icon(Icons.notifications_active),
                            label: Text(_isSendingAlert ? 'Transmitting SOS...' : 'REPORT DEATH / SOS ALERT'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 🕋 CONDOLENCE HEADER
                const Center(
                  child: Text(
                    'إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkGreen),
                  ),
                ),
                const SizedBox(height: 15),

                // 📋 LIVE REPATRIATION STEP PROGRESS TRACKER
                const Text(
                  'Repatriation & Legal Case Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                _buildStepTile(1, 'Medical Death Certificate', 'Certificato di Morte from Hospital/Doctor', step >= 1),
                _buildStepTile(2, 'Comune Clearance & Nulla Osta', 'Municipal transport clearance and seal (Sigillo)', step >= 2),
                _buildStepTile(3, 'Pakistan Consulate NOC & Passport Pass', 'Consular clearance certificate for repatriation', step >= 3),
                _buildStepTile(4, 'Air Cargo & Companion Flight Booking', 'Airway bill (AWB) and attendant ticket reserved', step >= 4),
                _buildStepTile(5, 'Arrival / Burial Handover', 'Repatriated to Pakistan or local burial completed', step >= 5),

                const SizedBox(height: 20),

                // 📍 JANAZAH TIMINGS BOX
                if ((data['janazaLocation'] ?? '').toString().isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.mosque, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Namaz-e-Janazah Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('• Time: ${data['janazaTime'] ?? 'TBD'}'),
                        Text('• Location: ${data['janazaLocation'] ?? 'TBD'}'),
                        if ((data['janazaMapsUrl'] ?? '').toString().isNotEmpty)
                          TextButton.icon(
                            onPressed: () async => launchUrl(Uri.parse(data['janazaMapsUrl']), mode: LaunchMode.externalApplication),
                            icon: const Icon(Icons.navigation, size: 16),
                            label: const Text('Open in Google Maps'),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepTile(int stepIndex, String title, String subtitle, bool isDone) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isDone ? Colors.green : Colors.grey.shade300),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDone ? Colors.green : Colors.grey.shade200,
          child: Icon(
            isDone ? Icons.check : Icons.hourglass_top,
            color: isDone ? Colors.white : Colors.grey,
            size: 18,
          ),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDone ? Colors.black : Colors.grey.shade700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: Text(
          isDone ? 'Completed ✅' : 'Pending ⏳',
          style: TextStyle(color: isDone ? Colors.green : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}