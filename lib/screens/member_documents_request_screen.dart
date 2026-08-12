import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/audit_log_service.dart';

class MemberDocumentsRequestScreen extends StatefulWidget {
  final String memberDocId;
  final String memberName;
  final String nPratica;

  const MemberDocumentsRequestScreen({
    super.key,
    required this.memberDocId,
    required this.memberName,
    required this.nPratica,
  });

  @override
  State<MemberDocumentsRequestScreen> createState() => _MemberDocumentsRequestScreenState();
}

class _MemberDocumentsRequestScreenState extends State<MemberDocumentsRequestScreen> {
  String _selectedDocType = 'Carta d\'Identità';
  final _reasonCtrl = TextEditingController();
  bool _isLoading = false;

  final List<String> _docTypes = [
    'Carta d\'Identità',
    'Passaporto',
    'Permesso di Soggiorno',
    'Codice Fiscale',
    'Certificato di Residenza / Altro',
  ];

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final reason = _reasonCtrl.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('document_requests').add({
        'memberDocId': widget.memberDocId,
        'memberName': widget.memberName,
        'nPratica': widget.nPratica,
        'documentType': _selectedDocType,
        'reason': reason.isNotEmpty ? reason : 'Standard verification update',
        'status': 'PENDING_UPLOAD',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      await AuditLogService.logAction(
        actionTitle: 'Document Request Sent',
        details: 'Requested $_selectedDocType from ${widget.memberName} (${widget.nPratica})',
        targetMemberId: widget.memberDocId,
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text('Request for $_selectedDocType sent to member! ✅'),
          backgroundColor: Colors.green,
        ),
      );
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error sending request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Scanned Document'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Member: ${widget.memberName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkGreen),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'N. Pratica: ${widget.nPratica}',
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Select Required Document Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _selectedDocType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.file_present_outlined, color: darkGreen),
              ),
              items: _docTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDocType = val);
              },
            ),

            const SizedBox(height: 16),

            const Text(
              'Reason / Specific Instructions (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Please upload clear front and back copy...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _submitRequest,
                icon: const Icon(Icons.send, size: 18),
                label: Text(_isLoading ? 'Sending Request...' : 'Send Document Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}