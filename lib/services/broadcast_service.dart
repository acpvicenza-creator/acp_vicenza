import 'package:url_launcher/url_launcher.dart';

class BroadcastService {
  static Future<void> sendWhatsAppBroadcast(String message) async {
    final encodedMessage = Uri.encodeComponent(message);
    // Opens WhatsApp with pre-filled message for broad distribution
    final whatsappUrl = Uri.parse("whatsapp://send?text=$encodedMessage");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      final webUrl = Uri.parse("https://api.whatsapp.com/send?text=$encodedMessage");
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}