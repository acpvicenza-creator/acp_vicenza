import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeathAlertBannerWidget extends StatelessWidget {
  const DeathAlertBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('death_alerts')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink(); // No emergency alert currently active
        }

        final alertData = snapshot.data!.docs.first.data() as Map<String, dynamic>;

        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.error, color: Colors.amber, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'JANAZAH EMERGENCY ALERT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 16),
              Text(
                'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber.shade200),
              ),
              const SizedBox(height: 6),
              Text(
                'Marhoom: ${alertData['deceasedName'] ?? ''}'
                    '${(alertData['age'] ?? '').toString().isNotEmpty ? " (${alertData['age']} Yrs)" : ""}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Timing: ${alertData['janazahTime'] ?? ''}',
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Location: ${alertData['janazahLocation'] ?? ''}',
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
              if ((alertData['additionalNotes'] ?? '').toString().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Note: ${alertData['additionalNotes']}',
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.white70),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}