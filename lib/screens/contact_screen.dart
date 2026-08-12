import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // 📞 DIRECT PHONE CALL HANDLER
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri, mode: LaunchMode.externalNonBrowserApplication);
      }
    } catch (e) {
      debugPrint('Could not launch dialer for $phoneNumber: $e');
    }
  }

  // 📧 DIRECT EMAIL APP HANDLER
  Future<void> _sendEmail(String emailPath) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailPath,
      queryParameters: {'subject': 'ACP Vicenza - Support Query'},
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Could not launch mail client: $e');
    }
  }

  // 🌐 DIRECT WEBSITE LAUNCHER HANDLER
  Future<void> _openWebsite(String urlString) async {
    String formattedUrl = urlString;
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final Uri launchUri = Uri.parse(formattedUrl);

    try {
      bool launched = await launchUrl(
        launchUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(launchUri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      debugPrint('Could not launch website $urlString: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    final contacts = [
      {'name': 'Shahid Ali', 'phone': '+39 328 0452178'},
      {'name': 'Mazhar Hussain', 'phone': '+39 329 6142116'},
      {'name': 'Mudassar Hussain', 'phone': '+39 320 2131444'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Contact Us - ACP'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER TITLE
            const Text(
              'Get in Touch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: darkGreen),
            ),
            const SizedBox(height: 4),
            const Text(
              'Associazione Culturale Comunità Pakistana di Vicenza',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // OFFICIAL CONTACT COMMITTEE MEMBERS
            const Text(
              'Committee Representatives',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen),
            ),
            const SizedBox(height: 10),

            ...contacts.map((contact) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => _makePhoneCall(contact['phone']!),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F2EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: darkGreen),
                ),
                title: Text(
                  contact['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(contact['phone']!),
                trailing: IconButton(
                  icon: const Icon(Icons.phone, color: darkGreen),
                  onPressed: () => _makePhoneCall(contact['phone']!),
                ),
              ),
            )),

            const SizedBox(height: 20),

            // OFFICIAL EMAIL & WEBSITE
            const Text(
              'Official Channels',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkGreen),
            ),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => _sendEmail('acpvicenza@gmail.com'),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F2EC),
                  child: Icon(Icons.email_outlined, color: darkGreen),
                ),
                title: const Text('Email Us', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text(
                  'acpvicenza@gmail.com',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
                trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 8),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => _openWebsite('www.acpvicenza.it'),
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F2EC),
                  child: Icon(Icons.language, color: darkGreen),
                ),
                title: const Text('Official Website', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text(
                  'www.acpvicenza.it',
                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
                trailing: const Icon(Icons.open_in_new, size: 18, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 30),

            // FOOTER BANNER
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Text(
                    'ACP Vicenza',
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Always available for community support and welfare.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}