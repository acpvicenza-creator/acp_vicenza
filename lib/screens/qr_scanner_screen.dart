import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanned = false;
  final MobileScannerController _controller = MobileScannerController();

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return;
    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isScanned = true);
        final String rawCode = barcode.rawValue!;

        String searchedCode = rawCode;
        if (rawCode.contains('|')) {
          final parts = rawCode.split('|');
          if (parts.length > 1) searchedCode = parts[1];
        }

        _verifyMember(searchedCode, rawCode);
        break;
      }
    }
  }

  Future<void> _verifyMember(String fiscalCode, String fullData) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('members')
          .where('fiscalCode', isEqualTo: fiscalCode)
          .limit(1)
          .get();

      if (!mounted) return;

      if (querySnapshot.docs.isNotEmpty) {
        final member = querySnapshot.docs.first.data();
        _showResultDialog(
          title: '✅ MEMBER VERIFIED',
          color: Colors.green,
          content: 'Name: ${member['fullName']}\nCF: ${member['fiscalCode']}\nPhone: ${member['phone']}',
        );
      } else {
        _showResultDialog(
          title: '❌ NOT FOUND',
          color: Colors.red,
          content: 'No registered member found with this QR Code.\n\nRaw Data: $fullData',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showResultDialog(
        title: 'Error',
        color: Colors.orange,
        content: 'Verification failed: ${e.toString()}',
      );
    }
  }

  void _showResultDialog({required String title, required Color color, required String content}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3B6F)),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isScanned = false);
            },
            child: const Text('Scan Next', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Member QR'),
        backgroundColor: const Color(0xFF1B3B6F),
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, child) {
              final isTorchOn = state.torchState == TorchState.on;
              return IconButton(
                icon: Icon(
                  isTorchOn ? Icons.flash_on : Icons.flash_off,
                  color: isTorchOn ? Colors.yellow : Colors.grey,
                ),
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}