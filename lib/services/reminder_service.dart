import 'package:url_launcher/url_launcher.dart';

class ReminderService {
  // Send 1-Click WhatsApp Fee Reminder to a specific member
  static Future<void> sendIndividualFeeReminder({
    required String name,
    required String phone,
    required String nPratica,
    required double totalFee,
  }) async {
    final message = '''
السلام عليكم $name,

Associazione Culturale Comunità Pakistana Di Vicenza (ACP)

Kindly note that your annual membership fee (€${totalFee.toStringAsFixed(0)}) for N. Pratica: $nPratica is currently pending.

⚠️ Deadline: 31st March (As per Rule 2 & Rule 9).
Please complete your payment to keep your Benefit Card active.

JazakAllah Khair!
''';

    final encodedMessage = Uri.encodeComponent(message);
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Agar international code (+39 / +92) shuru mein na ho to Italian prefix default add karein
    if (!cleanPhone.startsWith('+') && !cleanPhone.startsWith('00')) {
      if (cleanPhone.startsWith('3') && cleanPhone.length == 10) {
        cleanPhone = '+39$cleanPhone';
      }
    }

    final nativeWhatsappUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encodedMessage');
    final universalWhatsappUri = Uri.parse('https://wa.me/${cleanPhone.replaceAll('+', '')}?text=$encodedMessage');

    try {
      if (await canLaunchUrl(nativeWhatsappUri)) {
        await launchUrl(nativeWhatsappUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(universalWhatsappUri)) {
        await launchUrl(universalWhatsappUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  // Bulk Reminder text generator for admin broad notifications
  static String generateBulkReminderMessage(int pendingCount) {
    return '''
📢 ACP VICENZA - ANNUAL FEE REMINDER

Dear Members ($pendingCount Pending),
Please settle your annual membership fees before March 31st to avoid membership cancellation and €50 late reactivation fine (Rule 9).

Contact ACP Management for payment confirmation.
JazakAllah Khair.
''';
  }
}