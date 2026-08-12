import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('ACP Announcements'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('announcements')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 10),
                    Text(
                      'Error loading announcements:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign_outlined, color: Colors.grey, size: 60),
                  SizedBox(height: 10),
                  Text(
                    'No announcements available right now.',
                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              // Timestamp handling
              String dateStr = '';
              if (data['createdAt'] != null && data['createdAt'] is Timestamp) {
                final DateTime date = (data['createdAt'] as Timestamp).toDate();
                dateStr = '${date.day}/${date.month}/${date.year}';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.campaign, color: Colors.amber, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              data['title'] ?? 'Announcement',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkGreen,
                              ),
                            ),
                          ),
                          if (dateStr.isNotEmpty)
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                        ],
                      ),
                      const Divider(height: 20),
                      Text(
                        data['message'] ?? '',
                        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}