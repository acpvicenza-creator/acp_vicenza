import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddAnnouncementScreen extends StatefulWidget {
  const AdminAddAnnouncementScreen({super.key});

  @override
  State<AdminAddAnnouncementScreen> createState() => _AdminAddAnnouncementScreenState();
}

class _AdminAddAnnouncementScreenState extends State<AdminAddAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  Future<void> _publishAnnouncement() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both title and message')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Save announcement in Firestore
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': title,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Announcement published successfully! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to publish: $e'), backgroundColor: Colors.red),
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
        title: const Text('Broadcast Announcement'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Announcement to All Members',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen),
            ),
            const Text(
              'This will instantly show up on the announcements screen for all users.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Announcement Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Announcement Message *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _publishAnnouncement,
                icon: const Icon(Icons.campaign),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Publish Announcement', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}