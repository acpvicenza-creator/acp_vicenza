import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/language_service.dart';
import '../services/voice_service.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final VoiceService _voiceService = VoiceService();
  final LanguageService _languageService = LanguageService();
  bool _isPlaying = false;

  @override
  void dispose() {
    _voiceService.stop(); // Screen se baahar jaane par aawaz stop ho gi
    super.dispose();
  }

  // 🔊 VOICE READER TOGGLE
  Future<void> _toggleAudioReader() async {
    if (_isPlaying) {
      await _voiceService.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      const String fullTextToRead =
          'Informativa sulla Privacy ACP Vicenza. Associazione Culturale Comunità Pakistana di Vicenza respects your privacy in compliance with EU GDPR. '
          'We collect registration details, Codice Fiscale, and document scans solely for the Funeral Benefit Fund management. '
          'Transactions are securely processed via Stripe or direct Bonifico Bancario. Your data is never sold to third parties, and you can request account deletion at any time.';

      setState(() {
        _isPlaying = true;
      });

      await _voiceService.speak(
        fullTextToRead,
        _languageService.currentLanguage,
      );

      setState(() {
        _isPlaying = false;
      });
    }
  }

  Future<void> _sendEmail() async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: 'acpvicenza@gmail.com',
      queryParameters: {'subject': 'ACP App - Privacy & Data Request (GDPR)'},
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Privacy Policy & GDPR'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        actions: [
          // 🔊 VOICE ASSISTANT BUTTON
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.stop_circle : Icons.volume_up,
              color: _isPlaying ? Colors.amber : Colors.white,
              size: 26,
            ),
            tooltip: _isPlaying ? 'Stop Reading' : 'Listen Policy',
            onPressed: _toggleAudioReader,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informativa sulla Privacy',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkGreen),
                      ),
                      Text(
                        'ACP Vicenza • Regolamento UE 2016/679 (GDPR)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Last Updated: August 2026',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // 🔊 INLINE AUDIO PLAY BUTTON
                IconButton(
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: darkGreen,
                    size: 34,
                  ),
                  onPressed: _toggleAudioReader,
                ),
              ],
            ),
            const Divider(height: 25),

            _buildSectionTitle('1. Data Controller (Titolare del Trattamento)'),
            _buildSectionText(
              'The Data Controller is Associazione Culturale Comunità Pakistana di Vicenza (referred to as "ACP Vicenza", "we", "us"), with registered office in Via R. Fabiani 47, 36100 Vicenza (VI), Italy. Email: acpvicenza@gmail.com.',
            ),

            _buildSectionTitle('2. Information We Collect'),
            _buildSectionText(
              'When registering for the Funeral Benefit Fund (Comitato Funebre) or using our services, we collect:\n'
                  '• Personal Identity: Full Name, Date of Birth, Gender, Codice Fiscale, and Father\'s Name.\n'
                  '• Contact Details: Italian & Pakistani Phone Numbers, Email Address, and Residential Addresses.\n'
                  '• Scanned Identity Documents: Carta d\'Identità, Passaporto, Permesso di Soggiorno, and Codice Fiscale.\n'
                  '• Digital Signature: Finger/stylus electronic signature confirming registration undertakings.\n'
                  '• Device & Push Token: Firebase Cloud Messaging (FCM) token for Janazah alerts and announcements.',
            ),

            _buildSectionTitle('3. Device Hardware Permissions'),
            _buildSectionText(
              'To ensure proper functionality, the app requests:\n'
                  '• Camera: Exclusively to scan physical identification cards or certificates for membership registration.\n'
                  '• Photos & Storage: To upload scanned document copies and member profile pictures.\n'
                  'We never access personal photo albums or files outside what you explicitly select.',
            ),

            _buildSectionTitle('4. Purpose & Legal Basis of Processing'),
            _buildSectionText(
              'Your personal data is strictly processed to:\n'
                  '• Administer membership status and generate Digital Membership Cards.\n'
                  '• Verify eligibility for deceased member repatriation and funeral benefit coverage.\n'
                  '• Transmit urgent community announcements, prayer times, and Namaz-e-Janazah notifications.\n'
                  '• Process and record voluntary annual membership dues and emergency relief funds.',
            ),

            _buildSectionTitle('5. Payment Processing & Third-Party Services'),
            _buildSectionText(
              'We partner with reliable third-party providers complying with EU GDPR and PCI-DSS standards:\n'
                  '• Stripe & Direct Banking: Card and Bonifico payments are processed via encrypted secure protocols. We DO NOT store, view, or retain your credit card CVV or bank credentials on our servers.\n'
                  '• Google Firebase (EU Region): Encrypted cloud database storage, authentication, and push messaging.',
            ),

            _buildSectionTitle('6. Account & Data Deletion Rights (Apple & GDPR)'),
            _buildSectionText(
              'You have the right to access, rectify, or permanently delete your personal data at any time:\n'
                  '• In-App Deletion: Open Member Portal > Tap "Delete My Account (Privacy Request)".\n'
                  '• Email Request: Send an email to acpvicenza@gmail.com. Your request will be fulfilled within 30 days pursuant to GDPR Art. 17.',
            ),

            _buildSectionTitle('7. Membership Fees & Refund Policy'),
            _buildSectionText(
              'All annual dues and initial registration fees are non-commercial welfare contributions dedicated to community funeral and repatriation reserves. Contributions are non-refundable once approved and confirmed.',
            ),

            const SizedBox(height: 15),

            // CONTACT BUTTON FOR DATA & PAYMENT ENQUIRIES
            Card(
              elevation: 0,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green.shade300),
              ),
              child: ListTile(
                onTap: _sendEmail,
                leading: const Icon(Icons.email, color: darkGreen),
                title: const Text('Contact Data Protection Officer (DPO)',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: darkGreen)),
                subtitle: const Text('acpvicenza@gmail.com',
                    style: TextStyle(fontSize: 12, color: Colors.blue)),
                trailing:
                const Icon(Icons.open_in_new, size: 16, color: darkGreen),
              ),
            ),

            const SizedBox(height: 25),

            // FOOTER BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Text('Associazione Culturale Comunità Pakistana di Vicenza APS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  SizedBox(height: 2),
                  Text('Via R. Fabiani 47, Vicenza (36100), Italy',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 14.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF043927)),
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style:
      const TextStyle(fontSize: 12.5, height: 1.4, color: Colors.black87),
    );
  }
}