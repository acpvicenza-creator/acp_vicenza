import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_screen.dart';

class EmergencyFundAppealScreen extends StatelessWidget {
  const EmergencyFundAppealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Relief & Funeral Appeals'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('emergency_appeals').where('isActive', isEqualTo: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final appeals = snapshot.data!.docs;

          if (appeals.isEmpty) {
            return const Center(
              child: Text('No active emergency appeal campaigns at this time.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appeals.length,
            itemBuilder: (context, index) {
              final data = appeals[index].data() as Map<String, dynamic>;
              final double target = (data['targetAmount'] ?? 6000.0).toDouble();
              final double collected = (data['collectedAmount'] ?? 0.0).toDouble();
              final double progress = (collected / target).clamp(0.0, 1.0);

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title'] ?? 'Emergency Case', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkGreen)),
                      const SizedBox(height: 6),
                      Text(data['description'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progress, color: Colors.green, minHeight: 8),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Raised: €${collected.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                          Text('Target: €${target.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  memberName: 'Emergency Donation',
                                  praticaNumber: data['appealId'] ?? 'APPEAL-DONATION',
                                  amount: 20.0,
                                  registrationData: data,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.volunteer_activism),
                          label: const Text('Contribute (€20 Voluntary)'),
                        ),
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