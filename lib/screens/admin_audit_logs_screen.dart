import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuditLogsScreen extends StatelessWidget {
  const AdminAuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Activity & Audit Trail'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('audit_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No admin activity logged yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final dateStr = data['timestamp'] != null && data['timestamp'] is Timestamp
                  ? (data['timestamp'] as Timestamp).toDate().toString().substring(0, 16)
                  : 'Just Now';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.history, color: Colors.white, size: 20),
                  ),
                  title: Text(
                    data['actionTitle'] ?? 'Action Performed',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text('${data['details']}\nBy: ${data['adminEmail']}'),
                  trailing: Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}