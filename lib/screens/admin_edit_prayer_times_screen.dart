import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditPrayerTimesScreen extends StatefulWidget {
  const AdminEditPrayerTimesScreen({super.key});

  @override
  State<AdminEditPrayerTimesScreen> createState() => _AdminEditPrayerTimesScreenState();
}

class _AdminEditPrayerTimesScreenState extends State<AdminEditPrayerTimesScreen> {
  final _fajrController = TextEditingController();
  final _dhuhrController = TextEditingController();
  final _asrController = TextEditingController();
  final _maghribController = TextEditingController();
  final _ishaController = TextEditingController();
  final _jumuahController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTimes();
  }

  Future<void> _loadCurrentTimes() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('settings').doc('prayer_times').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _fajrController.text = data['Fajr'] ?? '';
          _dhuhrController.text = data['Dhuhr'] ?? '';
          _asrController.text = data['Asr'] ?? '';
          _maghribController.text = data['Maghrib'] ?? '';
          _ishaController.text = data['Isha'] ?? '';
          _jumuahController.text = data['Jumuah'] ?? '';
        });
      }
    } catch (_) {}
  }

  Future<void> _savePrayerTimes() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('settings').doc('prayer_times').set({
        'Fajr': _fajrController.text.trim(),
        'Dhuhr': _dhuhrController.text.trim(),
        'Asr': _asrController.text.trim(),
        'Maghrib': _maghribController.text.trim(),
        'Isha': _ishaController.text.trim(),
        'Jumuah': _jumuahController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prayer times updated successfully! ✅'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Prayer Times (Admin)'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Daily Namaz & Jumuah Timings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen),
            ),
            const Text('Enter time format (e.g. 05:15 AM or 13:30)', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildTimeInput(_fajrController, 'Fajr Time'),
            _buildTimeInput(_dhuhrController, 'Dhuhr Time'),
            _buildTimeInput(_asrController, 'Asr (Hanafi) Time'),
            _buildTimeInput(_maghribController, 'Maghrib Time'),
            _buildTimeInput(_ishaController, 'Isha Time'),
            _buildTimeInput(_jumuahController, 'Jumuah Time'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _savePrayerTimes,
                icon: const Icon(Icons.save),
                label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Timings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInput(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.access_time, color: Color(0xFF043927)),
        ),
      ),
    );
  }
}