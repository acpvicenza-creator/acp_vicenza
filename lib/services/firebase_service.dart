import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/member_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save Member Details and Signature Image
  Future<void> saveMemberWithSignature({
    required MemberModel member,
    required Uint8List signatureBytes,
  }) async {
    try {
      // 1. Upload Signature Image to Firebase Storage
      String signatureFileName =
          'signatures/sig_${member.fiscalCode}_${DateTime.now().millisecondsSinceEpoch}.png';
      Reference ref = _storage.ref().child(signatureFileName);
      UploadTask uploadTask = ref.putData(
        signatureBytes,
        SettableMetadata(contentType: 'image/png'),
      );
      TaskSnapshot snapshot = await uploadTask;
      String signatureUrl = await snapshot.ref.getDownloadURL();

      // 2. Save Member Document to Firestore
      Map<String, dynamic> memberData = member.toMap();
      memberData['signatureUrl'] = signatureUrl;
      memberData['createdAt'] = FieldValue.serverTimestamp();

      await _db.collection('members').doc(member.fiscalCode).set(memberData);
    } catch (e) {
      rethrow;
    }
  }

  // Update Member Details
  Future<void> updateMember(MemberModel member) async {
    try {
      await _db.collection('members').doc(member.id).update(member.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete Member Document
  Future<void> deleteMember(String memberId) async {
    try {
      await _db.collection('members').doc(memberId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Stream of Members for Admin List
  Stream<List<MemberModel>> getMembersStream() {
    return _db
        .collection('members')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => MemberModel.fromMap(doc.data()))
          .toList(),
    );
  }
}