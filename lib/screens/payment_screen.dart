import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'welcome_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String memberName;
  final String praticaNumber;
  final double amount;
  final Map<String, dynamic> registrationData;

  const PaymentScreen({
    super.key,
    required this.memberName,
    required this.praticaNumber,
    required this.amount,
    required this.registrationData,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  // 💳 1. IN-APP STRIPE WEBVIEW (AUTO-DETECTS REDIRECT & RETURNS TO ACP)
  void _processStripePayment() {
    final int amountInCents = (widget.amount * 100).toInt();
    const String baseStripeUrl = 'https://buy.stripe.com/cNifZjfES4W3euPd2D5c401';
    final String dynamicCheckoutUrl =
        '$baseStripeUrl?client_reference_id=${widget.praticaNumber}&prefilled_amount=$amountInCents';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StripeWebViewScreen(
          paymentUrl: dynamicCheckoutUrl,
          onPaymentSuccess: () {
            Navigator.pop(context); // Close WebView Screen
            _showPaymentSuccessAndGoHome();
          },
        ),
      ),
    );
  }

  // 🎉 SUCCESS DIALOG -> DIRECT BACK TO ACP HOME
  void _showPaymentSuccessAndGoHome() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Pagamento Riuscito! 🎉'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grazie ${widget.memberName}, il pagamento è stato completato con successo.'),
            const SizedBox(height: 8),
            Text('N. Pratica: ${widget.praticaNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3B6F),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.home),
            label: const Text('Back to ACP Home', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  // 🅿️ 2. PAYPAL PAYMENT WITH AUTOMATIC AMOUNT
  Future<void> _processPayPalPayment() async {
    setState(() => _isLoading = true);

    final String paypalUrl =
        'https://www.paypal.com/paypalme/acpvicenza/${widget.amount.toStringAsFixed(0)}EUR';

    final Uri uri = Uri.parse(paypalUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('Could not open PayPal link.');
      }
    } catch (e) {
      _showSnackBar('Error opening PayPal: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🏦 3. BANK TRANSFER DETAILS MODAL
  void _showBankDetailsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏦 Bonifico Bancario (IBAN Details)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F)),
            ),
            const Divider(),
            const Text('Account Name: COMUNITA PAKISTANA DI VICENZA APS'),
            const SizedBox(height: 6),
            SelectableText(
              'IBAN: IT42 H060 4511 8000 0000 5006 673',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900),
            ),
            const SizedBox(height: 6),
            SelectableText('Causale: Fee ${widget.praticaNumber} - ${widget.memberName}'),
            const SizedBox(height: 15),
            const Text(
              'Note: Please send payment proof/receipt to the ACP Admin for approval.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final bool isNew = widget.registrationData['isNewMember'] ?? true;
    final bool isFam = widget.registrationData['isFamily'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Fee Payment'),
        backgroundColor: const Color(0xFF1B3B6F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Member: ${widget.memberName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('N. Pratica: ${widget.praticaNumber}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${isNew ? "New Registration" : "Renewal"} (${isFam ? "Family" : "Single"})',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Fee Due:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '€${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1B3B6F)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.blueGrey)),
            const SizedBox(height: 12),

            _buildPaymentOptionTile(
              icon: Icons.credit_card,
              title: 'Credit / Debit Card / GPay / Apple Pay',
              subtitle: 'Pay via Card, Google Pay, or Apple Pay',
              color: Colors.indigo,
              onTap: _processStripePayment,
            ),

            _buildPaymentOptionTile(
              icon: Icons.account_balance_wallet,
              title: 'PayPal',
              subtitle: 'Pay instantly using your PayPal Account',
              color: Colors.blue.shade800,
              onTap: _processPayPalPayment,
            ),

            _buildPaymentOptionTile(
              icon: Icons.account_balance,
              title: 'Bonifico Bancario (Bank Transfer)',
              subtitle: 'View ACP IBAN details to pay via Bank App',
              color: const Color(0xFF1B3B6F),
              onTap: _showBankDetailsModal,
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// 🌐 STRIPE WEBVIEW SCREEN THAT LISTENS FOR REDIRECT
class StripeWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onPaymentSuccess;

  const StripeWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.onPaymentSuccess,
  });

  @override
  State<StripeWebViewScreen> createState() => _StripeWebViewScreenState();
}

class _StripeWebViewScreenState extends State<StripeWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (url.contains('acpvicenza.it')) {
              widget.onPaymentSuccess();
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('acpvicenza.it')) {
              widget.onPaymentSuccess();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Secure Checkout'),
        backgroundColor: const Color(0xFF1B3B6F),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF1B3B6F)),
            ),
        ],
      ),
    );
  }
}