import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddEventScreen extends StatefulWidget {
  const AdminAddEventScreen({super.key});

  @override
  State<AdminAddEventScreen> createState() => _AdminAddEventScreenState();
}

class _AdminAddEventScreenState extends State<AdminAddEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isLoading = false;

  Future<void> _publishEventAndNotify() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final date = _dateController.text.trim();
    final location = _locationController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Event Title and Description')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Save Event in Firestore
      await FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'description': description,
        'date': date,
        'location': location,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 2. Add to Notifications Collection for Member App Bell Icon Alert
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': '🎉 New Event: $title',
        'body': description,
        'date': date,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event Published & Notification Broadcasted to Members!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish event: $e'), backgroundColor: Colors.red),
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
        title: const Text('Add New Event'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Publish Event & Send Notification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGreen),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Event Date (e.g. 15 Aug 2026)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location / Venue',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Event Description & Details *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _publishEventAndNotify,
                icon: const Icon(Icons.campaign),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Publish & Send Push Notification', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}