import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RenewalService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Automatically evaluates all members and updates status if payment deadline passed
  static Future<void> checkAndApplyAnnualRenewals() async {
    try {
      final now = DateTime.now();

      // 🗓️ Renewal Deadline: 31st March every year
      final cutoffDate = DateTime(now.year, 3, 31);

      // If current date is past 31st March, flag unpaid members as Pending Payment / Overdue
      if (now.isAfter(cutoffDate)) {
        final QuerySnapshot snapshot = await _firestore.collection('members').get();

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final String paymentStatus = data['paymentStatus'] ?? 'Pending Payment';
          final String currentStatus = data['status'] ?? 'Pending Approval';

          // Skip deceased or rejected members
          if (currentStatus == 'Deceased' || currentStatus == 'Rejected') continue;

          // Safe Year Calculation (Prevents auto-revert of newly paid members)
          int? lastPaidYear = data['lastPaidYear'] as int?;

          // If lastPaidYear is missing, fallback to paidAt or createdAt timestamp
          if (lastPaidYear == null) {
            final Timestamp? paidAt = data['paidAt'] as Timestamp?;
            final Timestamp? createdAt = data['createdAt'] as Timestamp?;

            if (paidAt != null) {
              lastPaidYear = paidAt.toDate().year;
            } else if (paymentStatus == 'Paid' && createdAt != null) {
              lastPaidYear = createdAt.toDate().year;
            }
          }

          // If member is already Paid for the current year, ensure field is synced
          if (paymentStatus == 'Paid') {
            if (lastPaidYear == null || lastPaidYear >= now.year) {
              if (data['lastPaidYear'] != now.year) {
                await _firestore.collection('members').doc(doc.id).update({
                  'lastPaidYear': now.year,
                  'isOverdue': false,
                });
              }
              continue; // Current year is paid, do not revert
            }
          }

          // Revert to pending only if paid in a previous year and not yet paid for current year
          if (paymentStatus == 'Paid' && lastPaidYear != null && lastPaidYear < now.year) {
            await _firestore.collection('members').doc(doc.id).update({
              'paymentStatus': 'Pending Payment',
              'isOverdue': true,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error running annual renewal service: $e');
    }
  }

  /// Check if a single member's card should be locked
  static bool isMemberLocked(Map<String, dynamic> memberData) {
    final String paymentStatus = memberData['paymentStatus'] ?? 'Pending Payment';
    final String status = memberData['status'] ?? 'Pending Approval';

    if (status == 'Deceased') return true;
    return paymentStatus != 'Paid';
  }
}