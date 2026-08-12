import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/audit_log_service.dart';

class EditMemberDialog extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> memberData;

  const EditMemberDialog({
    super.key,
    required this.docId,
    required this.memberData,
  });

  @override
  State<EditMemberDialog> createState() => _EditMemberDialogState();
}

class _EditMemberDialogState extends State<EditMemberDialog> {
  late TextEditingController _fullNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _fiscalCodeCtrl;
  late TextEditingController _totalFeeCtrl;
  late String _status;
  late String _paymentStatus;
  late String _membershipType;

  final List<String> _statusOptions = [
    'Pending Approval',
    'Approved',
    'Rejected',
    'Deceased',
  ];

  final List<String> _paymentStatusOptions = [
    'Pending Payment',
    'Payment Submitted (Pending Verification)',
    'Paid',
  ];

  final List<String> _membershipTypeOptions = [
    'Single',
    'Family',
  ];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController(text: widget.memberData['fullName'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.memberData['phone'] ?? '');
    _addressCtrl = TextEditingController(text: widget.memberData['addressItaly'] ?? '');
    _fiscalCodeCtrl = TextEditingController(text: widget.memberData['fiscalCode'] ?? '');
    _totalFeeCtrl = TextEditingController(text: (widget.memberData['totalFee'] ?? '60').toString());

    _status = widget.memberData['status'] ?? 'Pending Approval';
    if (!_statusOptions.contains(_status)) _status = 'Pending Approval';

    _paymentStatus = widget.memberData['paymentStatus'] ?? 'Pending Payment';
    if (!_paymentStatusOptions.contains(_paymentStatus)) _paymentStatus = 'Pending Payment';

    _membershipType = widget.memberData['membershipType'] ?? 'Single';
    if (!_membershipTypeOptions.contains(_membershipType)) _membershipType = 'Single';
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _fiscalCodeCtrl.dispose();
    _totalFeeCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateMember() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      final double updatedFee = double.tryParse(_totalFeeCtrl.text.trim()) ?? 60.0;

      await FirebaseFirestore.instance.collection('members').doc(widget.docId).update({
        'fullName': _fullNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'addressItaly': _addressCtrl.text.trim(),
        'fiscalCode': _fiscalCodeCtrl.text.trim().toUpperCase(),
        'status': _status,
        'paymentStatus': _paymentStatus,
        'membershipType': _membershipType,
        'totalFee': updatedFee,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await AuditLogService.logAction(
        actionTitle: 'Member Details Updated',
        details: 'Admin modified record for ${_fullNameCtrl.text.trim()} (${widget.memberData['nPratica'] ?? ''})',
        targetMemberId: widget.docId,
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Member details successfully updated! ✅'),
          backgroundColor: Colors.green,
        ),
      );
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to update member: $e'),
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

    return AlertDialog(
      title: Text(
        'Edit Member (${widget.memberData['nPratica'] ?? ''})',
        style: const TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fiscalCodeCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: 'Codice Fiscale *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressCtrl,
              decoration: const InputDecoration(labelText: 'Address in Italy', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _totalFeeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Fee (€)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),

            // MEMBERSHIP PLAN DROPDOWN
            DropdownButtonFormField<String>(
              initialValue: _membershipType,
              decoration: const InputDecoration(labelText: 'Membership Plan', border: OutlineInputBorder()),
              items: _membershipTypeOptions.map((type) {
                return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _membershipType = val);
              },
            ),
            const SizedBox(height: 12),

            // APPLICATION STATUS DROPDOWN
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Application Status', border: OutlineInputBorder()),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(
                    status == 'Deceased' ? '🪦 Deceased' : status,
                    style: TextStyle(
                      color: status == 'Deceased' ? Colors.red : Colors.black,
                      fontWeight: status == 'Deceased' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 12),

            // PAYMENT STATUS DROPDOWN
            DropdownButtonFormField<String>(
              initialValue: _paymentStatus,
              decoration: const InputDecoration(labelText: 'Payment Status', border: OutlineInputBorder()),
              items: _paymentStatusOptions.map((payStatus) {
                return DropdownMenuItem(value: payStatus, child: Text(payStatus, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _paymentStatus = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkGreen,
            foregroundColor: Colors.white,
          ),
          onPressed: _isLoading ? null : _updateMember,
          child: Text(_isLoading ? 'Saving...' : 'Save Changes'),
        ),
      ],
    );
  }
}