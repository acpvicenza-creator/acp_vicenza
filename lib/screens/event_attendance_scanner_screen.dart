import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/audit_log_service.dart';

class EventAttendanceScannerScreen extends StatefulWidget {
  final String eventName;
  final String eventId;

  const EventAttendanceScannerScreen({
    super.key,
    required this.eventName,
    required this.eventId,
  });

  @override
  State<EventAttendanceScannerScreen> createState() => _EventAttendanceScannerScreenState();
}

class _EventAttendanceScannerScreenState extends State<EventAttendanceScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _processScannedCode(String scannedCode) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    _scannerController.stop();

    final String cleanPratica = scannedCode.trim().toUpperCase();
    final messenger = ScaffoldMessenger.of(context);

    try {
      final memberQuery = await FirebaseFirestore.instance
          .collection('members')
          .where('nPratica', isEqualTo: cleanPratica)
          .limit(1)
          .get();

      if (!mounted) return;

      if (memberQuery.docs.isEmpty) {
        _showResultDialog(
          title: 'Not Found ❌',
          message: 'No registered member found for N. Pratica: $cleanPratica',
          isSuccess: false,
        );
      } else {
        final memberData = memberQuery.docs.first.data();
        final String memberName = memberData['fullName'] ?? 'Member';
        final String status = memberData['status'] ?? 'Pending';
        final String paymentStatus = memberData['paymentStatus'] ?? 'Pending';

        if (status != 'Approved' || paymentStatus != 'Paid') {
          _showResultDialog(
            title: 'Inactive Membership ⚠️',
            message: 'Member: $memberName\nStatus: $status\nPayment: $paymentStatus\n\nMembership is not active.',
            isSuccess: false,
          );
        } else {
          // Record Attendance
          await FirebaseFirestore.instance.collection('event_attendance').add({
            'eventId': widget.eventId,
            'eventName': widget.eventName,
            'nPratica': cleanPratica,
            'memberName': memberName,
            'scannedAt': FieldValue.serverTimestamp(),
          });

          await AuditLogService.logAction(
            actionTitle: 'Event Attendance Logged',
            details: 'Marked attendance for $memberName ($cleanPratica) at ${widget.eventName}',
          );

          if (!mounted) return;

          _showResultDialog(
            title: 'Attendance Verified! ✅',
            message: 'Member: $memberName\nN. Pratica: $cleanPratica\n\nWelcome to ${widget.eventName}!',
            isSuccess: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error verifying QR: $e'), backgroundColor: Colors.red),
        );
        _resumeScanner();
      }
    }
  }

  void _showResultDialog({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: isSuccess ? Colors.green : Colors.red, fontSize: 16)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 13)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? const Color(0xFF043927) : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _resumeScanner();
            },
            child: const Text('Scan Next'),
          ),
        ],
      ),
    );
  }

  void _resumeScanner() {
    if (mounted) {
      setState(() => _isProcessing = false);
      _scannerController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Attendance: ${widget.eventName}'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processScannedCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // SCANNER OVERLAY BOX
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber, width: 3),
              borderRadius: BorderRadius.circular(16),
              // ✅ Fixed withValues instead of deprecated withOpacity
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),

          const Positioned(
            bottom: 40,
            child: Text(
              'Align Member Card QR Code inside the box',
              style: TextStyle(color: Colors.white, fontSize: 13, backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}