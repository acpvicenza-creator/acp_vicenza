import 'package:url_launcher/url_launcher.dart';

class WhatsAppReceiptService {
  /// International phone number formatting (Italy +39 aur Pakistan +92 ke liye)
  static String formatPhoneNumber(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 10 && clean.startsWith('3')) return '39$clean';
    if (clean.startsWith('0')) return '92${clean.substring(1)}';
    return clean;
  }

  /// 1-Click Official Payment Receipt with Logo & Verification Badge
  static Future<void> sendPaymentReceipt({
    required String memberName,
    required String memberPhone,
    required String memberId,
    required double amount,
    required String paymentType,
    required String transactionId,
    required String validUntil,
  }) async {
    final formattedPhone = formatPhoneNumber(memberPhone);

    // Live Current Date
    final now = DateTime.now();
    final formattedDate = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final message = '''
🏛️ *ASSOCIAZIONE CULTURALE COMUNITA PAKISTANA DI VICENZA (ACP)*
📍 _Vicenza, Italia | CF: 95156810244_
━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 *RICEVUTA DI PAGAMENTO DIGITALE*
      *(Official Payment Receipt)*
━━━━━━━━━━━━━━━━━━━━━━━━━━

👤 *INFORMAZIONI SOCIO / MEMBER INFO*
• *Nome / Name:* $memberName
• *Codice Socio / ID:* $memberId
• *Data Rilascio / Date:* $formattedDate

💳 *DETTAGLI PAGAMENTO / PAYMENT DETAILS*
• *Causale / Purpose:* $paymentType
• *ID Transazione:* $transactionId
• *Importo / Amount:* €${amount.toStringAsFixed(2)}
• *Validità Copertura:* $validUntil
• *Stato Pagamento:* Confermato & Attivo ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━
🛡️ _Ricevuta ufficiale generata elettronicamente da ACP Vicenza._
🌐 *Verifica Online:* https://acpvicenza.it/verify?id=$memberId
━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

    final uri = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Impossibile aprire WhatsApp.';
    }
  }

  /// 🚨 Emergency Death Alert Broadcast Formatter
  static Future<void> sendDeathAlert({
    required String deceasedName,
    required String janazahTime,
    required String janazahLocation,
    required String contactPerson,
    required String targetPhoneOrGroup,
  }) async {
    final formattedPhone = formatPhoneNumber(targetPhoneOrGroup);

    final alertMessage = '''
*🚨 COMUNICAZIONE URGENTE - ACP VICENZA 🚨*
━━━━━━━━━━━━━━━━━━━━━━━━━━
*إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ*
_Inna lillahi wa inna ilayhi raji'un_

Nihayat afsos ke sath itla di jati hai ke *$deceasedName* ka inteqal ho gaya hai.

📍 *DETTAGLI FUNERALE / JANAZAH DETAILS:*
• *Orario / Waqt:* $janazahTime
• *Luogo / Location:* $janazahLocation
• *Contatto / Rabta:* $contactPerson

Tamam ahbab se dua-e-maghfirat aur shirkat ki darkhwast hai.
━━━━━━━━━━━━━━━━━━━━━━━━━━
*Associazione Culturale Pakistana Di Vicenza*
''';

    final uri = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(alertMessage)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}