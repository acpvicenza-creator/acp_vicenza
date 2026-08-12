import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuditLogService {
  static Future<void> logAction({
    required String actionTitle,
    required String details,
    String? targetMemberId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final adminEmail = user?.email ?? 'Admin';

    await FirebaseFirestore.instance.collection('audit_logs').add({
      'adminEmail': adminEmail,
      'actionTitle': actionTitle,
      'details': details,
      'targetMemberId': targetMemberId ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}