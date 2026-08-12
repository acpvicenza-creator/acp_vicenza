import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddDeathAlertScreen extends StatefulWidget {
  const AdminAddDeathAlertScreen({super.key});

  @override
  State<AdminAddDeathAlertScreen> createState() => _AdminAddDeathAlertScreenState();
}

class _AdminAddDeathAlertScreenState extends State<AdminAddDeathAlertScreen> {
  final _deceasedNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _janazahTimeCtrl = TextEditingController();
  final _janazahLocationCtrl = TextEditingController();
  final _googleMapsUrlCtrl = TextEditingController();
  final _additionalNotesCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _publishDeathAlert() async {
    if (_deceasedNameCtrl.text.trim().isEmpty ||
        _janazahTimeCtrl.text.trim().isEmpty ||
        _janazahLocationCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields (*)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Deactivate previous active alerts
      final activeAlerts = await FirebaseFirestore.instance
          .collection('death_alerts')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in activeAlerts.docs) {
        await doc.reference.update({'isActive': false});
      }

      // Publish New Emergency Alert
      await FirebaseFirestore.instance.collection('death_alerts').add({
        'deceasedName': _deceasedNameCtrl.text.trim(),
        'age': _ageCtrl.text.trim(),
        'janazahTime': _janazahTimeCtrl.text.trim(),
        'janazahLocation': _janazahLocationCtrl.text.trim(),
        'googleMapsUrl': _googleMapsUrlCtrl.text.trim(),
        'additionalNotes': _additionalNotesCtrl.text.trim(),
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Janazah Emergency Alert Broadcasted Successfully! 🔴'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFC62828);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Death / Janazah Alert'),
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: primaryRed, size: 30),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Emergency Notification Alert\nThis will trigger an urgent top banner alert across all member apps.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_deceasedNameCtrl, 'Marhoom / Deceased Full Name *', icon: Icons.person),
            _buildTextField(_ageCtrl, 'Age (Umarr)', icon: Icons.cake, keyboardType: TextInputType.number),
            _buildTextField(_janazahTimeCtrl, 'Janazah Date & Time (e.g. Today after Asr 17:30) *', icon: Icons.access_time),
            _buildTextField(_janazahLocationCtrl, 'Janazah Location / Cemetery Address *', icon: Icons.location_on),
            _buildTextField(_googleMapsUrlCtrl, 'Google Maps Link (Optional for Direct Navigation)', icon: Icons.map),
            _buildTextField(_additionalNotesCtrl, 'Additional Information / Family Contact', icon: Icons.note_add, maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _publishDeathAlert,
                icon: const Icon(Icons.campaign),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Broadcast Emergency Alert Now', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {required IconData icon, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFFC62828)),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}