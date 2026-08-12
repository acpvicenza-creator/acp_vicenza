import 'package:flutter/material.dart';

class RenewalBannerWidget extends StatelessWidget {
  final Map<String, dynamic> memberData;
  final VoidCallback onPayPressed;

  const RenewalBannerWidget({
    super.key,
    required this.memberData,
    required this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final String paymentStatus = memberData['paymentStatus'] ?? 'Pending Payment';
    final bool isPaid = paymentStatus == 'Paid';

    if (isPaid) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade800, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Annual Fee Overdue / Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Renew by 31st March to keep Funeral Benefit Card active.',
                  style: TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: onPayPressed,
            child: const Text('Pay Dues', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}