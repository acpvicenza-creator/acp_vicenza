import 'package:flutter/material.dart';

class RulesAndRegulationsScreen extends StatelessWidget {
  const RulesAndRegulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    final List<Map<String, String>> rules = [
      {
        'num': '1',
        'title': 'Membership Dues (Quota Associativa)',
        'it': '€5/mese per Single (€60/anno), €10/mese per Famiglia (€120/anno).',
        'en': '€5/month for Single (€60/year), €10/month for Family (€120/year).',
        'ur': 'بینیفٹ کمیٹی کا مستقل ممبر بننے کے لیے 5 یورو ماہانہ سنگل آدمی کے لیے اور 10 یورو ماہانہ فیملی کی صورت میں ادا کرنے ہونگے۔'
      },
      {
        'num': '1A',
        'title': 'Registration Fee (Quota Iscrizione)',
        'it': '€20 una tantum per la prima iscrizione di ogni nuovo membro.',
        'en': '€20 one-time registration fee for every new member.',
        'ur': 'رجسٹریشن فیس 20 یورو جو کہ ہر ممبر رکنیت حاصل کرنے کے لیے ادا کریگا۔'
      },
      {
        'num': '1B',
        'title': 'Payment Responsibility (Responsabilità)',
        'it': 'Ogni iscritto è responsabile del versamento del proprio contributo.',
        'en': 'Each member is personally responsible for remitting their dues.',
        'ur': 'نیز یہ فنڈ ہر ممبر خود پہنچانے کا ذمہ دار ہوگا۔'
      },
      {
        'num': '2',
        'title': 'Annual Payment Window (Scadenza Annuale)',
        'it': 'Contributo da versare ogni anno dal 1° Gennaio al 31 Marzo.',
        'en': 'Annual fee must be paid between Jan 1st and March 31st each year.',
        'ur': 'فنڈ سالانہ وصول کیا جائے گا اور ہر ممبر 1 جنوری سے 31 مارچ تک فنڈ ادا کرنے کا پابند ہوگا۔'
      },
      {
        'num': '3',
        'title': 'Family Coverage (Composizione Famiglia)',
        'it': 'Inclusi marito, moglie e figli minori di 18 anni.',
        'en': 'Includes husband, wife, and dependent children under 18.',
        'ur': 'فیملی میں میاں بیوی اور 18 سال سے کم عمر کے بچے شامل ہوں گے۔'
      },
      {
        'num': '4',
        'title': 'Member Repatriation (Decesso Membro)',
        'it': 'Copertura spese rimpatrio salma in Pakistan fino a max €6.000.',
        'en': 'Repatriation costs to Pakistan covered up to a maximum of €6,000.',
        'ur': 'بینیفٹ کمیٹی کے کسی ممبر کی وفات کی صورت میں پاکستان میت بھجوانے کے تمام انتظامات اور اخراجات جو کہ زیادہ سے زیادہ 6000 یورو تک سوسائٹی ادا کرے گی۔'
      },
      {
        'num': '5',
        'title': 'Head of Family Death (Decesso Capofamiglia)',
        'it': 'Spese rimpatrio salma + 1 biglietto aereo per un familiare accompagnatore.',
        'en': 'Full repatriation expenses + 1 companion flight ticket to Pakistan.',
        'ur': 'کسی فیملی کے سربراہ کی وفات کی صورت میں پاکستان میت بھجوانے کے تمام انتظامات اور اخراجات کرے گی، مزید ایک فرد کی ٹکٹ فراہم کی جائے گی۔'
      },
      {
        'num': '6',
        'title': 'Family Continuity (Continuità Famiglia)',
        'it': 'La famiglia del capofamiglia deceduto mantiene la copertura continuando a pagare.',
        'en': 'Surviving family keeps eligibility by continuing annual dues payment.',
        'ur': 'فیملی کے سربراہ کی وفات کے بعد اس کی فیملی اگر فنڈ ادا کرے گی تو وہ ممبر رہے گی۔'
      },
      {
        'num': '7',
        'title': 'Financial Aid (Sostegno Capofamiglia)',
        'it': 'Contributo di €2.000 alla famiglia in caso di decesso del capofamiglia.',
        'en': '€2,000 direct financial aid given to the deceased head\'s family.',
        'ur': 'کسی فیملی کے سربراہ کی وفات اگر پاکستان میں ہو تو اس صورت میں کمیٹی فیملی کود ہزار یورو کی معاونت کرے گی۔'
      },
      {
        'num': '8',
        'title': 'Required Documents (Documenti Obbligatori)',
        'it': 'Obbligatori Permesso di Soggiorno, Carta d\'Identità e Passaporto.',
        'en': 'Valid Permesso di Soggiorno, Italian ID Card, and Passport required.',
        'ur': 'بینیفٹ کمیٹی کا ممبر بننے کے لیے مذکورہ فارم اور Permesso Di Sogg, Carta Di Identità, Passaporto فراہم کرنا ضروری ہے۔'
      },
      {
        'num': '9',
        'title': 'Lapsed Fee & Penalty (Ritardo e Penale)',
        'it': 'Cancellazione dopo il 31 Marzo. Penale di €50 per la riattivazione.',
        'en': 'Membership cancelled after March 31st. €50 fine for reactivation.',
        'ur': 'اگر بینیفٹ کمیٹی کا کوئی بھی ممبر بغیر اطلاع کے 31 مارچ کے بعد تین ماہ اپنا فنڈ ادا نہیں کرتا تو اس کی ممبرشپ منسوخ ہو جائے گی اور دوبارہ ممبرشپ بحال کرنے کے لیے اسے اپنے بقایا جات کے ساتھ 50 یورو جرمانہ کی صورت میں ادا کرنا ہوں گے۔'
      },
      {
        'num': '10',
        'title': 'Board Decisions (Decisioni della Shura)',
        'it': 'La decisione della Shura ACP su casi non previsti sarà definitiva.',
        'en': 'ACP Shura decision will be final for unlisted circumstances.',
        'ur': 'کسی بھی ایسی صورتحال کے بارے میں جس کا ذکر قواعد و ضوابط میں نہ کیا گیا ہو اس کا حتمی فیصلہ اے سی پی سوسائٹی کی مجلس شوریٰ کرے گی اور وہ فیصلہ کمیٹی کے ہر ممبر کے لیے قابل قبول ہوگا۔'
      },
      {
        'num': '11',
        'title': 'Membership Pass (Tessera Associativa)',
        'it': 'A ciascun iscritto viene rilasciata una tessera associativa digitale.',
        'en': 'Every registered active member receives an official Digital Card.',
        'ur': 'بینیفٹ کمیٹی کے ہر ممبر کو ایک عدد ممبرشپ کارڈ جاری کیا جائے گا۔'
      },
      {
        'num': '12',
        'title': 'Daughters >18 Years (Figlie Maggiorenni)',
        'it': 'Figlie >18 anni incluse solo se non sposate e disoccupate.',
        'en': 'Daughters over 18 included only if unmarried AND unemployed.',
        'ur': 'اٹھارہ سال سے زائد عمر کی ایسی بیٹیاں جو نہ شادی شدہ ہوں اور نہ ہی ملازمت کرتی ہوں تو وہ فیملی میں شمار کی جائیں گی۔'
      },
      {
        'num': '13',
        'title': 'Fund Allocation (Utilizzo Fondi)',
        'it': 'Fondi in eccedenza destinabili ad altre opere caritatevoli previa approvazione.',
        'en': 'Surplus funds may be used for other charity causes upon approval.',
        'ur': 'اے سی پی (ACP) سوسائٹی بینیفٹ کمیٹی کی مد میں جمع شدہ رقم کو شوریٰ کی مشاورت کے بعد کسی بھی خیر کے کاموں میں استعمال کر سکتی ہے۔'
      },
      {
        'num': '14',
        'title': 'Non-Refundable Policy (Non Rimborsabilità)',
        'it': 'I contributi versati alla Benefit Committee non sono in alcun caso rimborsabili.',
        'en': 'All contributions paid to the committee are strictly non-refundable.',
        'ur': 'بینیفٹ کمیٹی کا کوئی بھی ممبر کسی صورت میں جمع شدہ رقم کا مطالبہ نہیں کر سکتا۔'
      },
      {
        'num': '15',
        'title': 'Death outside Italy (Decesso all\'Estero)',
        'it': '€2.000 per decesso in Pakistan. In Europa secondo standard italiani.',
        'en': '€2,000 for death in Pakistan. In Europe, costs as per Italian rates.',
        'ur': 'اگر کسی ممبر کی وفات پاکستان میں ہو تو 2000 یورو معاونت کی جائے گی، اگر کسی ممبر کی وفات اٹلی کے علاوہ کہیں یورپ میں ہوتی ہے تو اخراجات اٹلی کے مطابق ادا کیے جائیں گے۔'
      },
      {
        'num': '16',
        'title': 'Emergency Levy (Contributo Straordinario)',
        'it': 'In caso di esaurimento fondi, può essere richiesto un contributo extra.',
        'en': 'Extra contribution may be requested if emergency reserves run out.',
        'ur': 'کسی بھی ناگہانی صورت (زیادہ اموات کی صورت میں) اگر فنڈ ختم ہو جائے تو ممبران سے اضافی فنڈ لیا جا سکتا ہے۔'
      },
      {
        'num': '17',
        'title': 'Rules Amendments (Modifiche Regolamento)',
        'it': 'Le modifiche approvate saranno comunicate tempestivamente a tutti.',
        'en': 'Approved changes to rules will be transparently notified to members.',
        'ur': 'قواعد و ضوابط میں کمیٹی کی مشاورت سے تبدیلی کی جا سکتی ہے، لیکن جو بھی تبدیلی ہوگی اس سے تمام ممبران کو آگاہ کیا جائے گا۔'
      },
      {
        'num': '18',
        'title': 'Unpaid Exclusion (Decesso con Quota Scaduta)',
        'it': 'Nessuna copertura in caso di decesso con quota non pagata oltre il 31 Marzo.',
        'en': 'No funeral benefit provided if death occurs while fee is unpaid past March 31.',
        'ur': 'کوئی بھی ممبر (31 مارچ) کے بعد ممبرشپ فیس ادا نہیں کرتا تو اس کے ساتھ کوئی حادثہ ہو جائے یا وفات ہو جائے تو کمیٹی ذمہ دار نہ ہوگی۔'
      },
      {
        'num': '19',
        'title': 'Forfeiture of Rights (Perdita Benefici)',
        'it': 'Il mancato rinnovo comporta la perdita automatica dei diritti associativi.',
        'en': 'Failure to renew results in automatic loss of all member benefits.',
        'ur': 'اگر کوئی ممبر فیس ادا نہیں کرتا وہ تمام بینیفٹ سے محروم ہو جائے گا، اس لیے تمام ممبران کو 31 مارچ تک ہر صورت ممبرشپ ادا کرنا ہوگی۔'
      },
      {
        'num': '20',
        'title': 'Family Arrival (Ricongiungimento Familiare)',
        'it': 'Iscrizione obbligatoria della famiglia entro 1 mese dall\'arrivo in Italia.',
        'en': 'Family arriving in Italy must be registered within 1 month of arrival.',
        'ur': 'جو ممبر بطور سنگل فرد رجسٹرڈ ہے، اس کی فیملی کے اٹلی آنے کی صورت میں نئے مہینے کے اندر اندراج کروانا لازمی ہوگا، بمہ رجسٹریشن فیس۔'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Rules & Regulations (ACP)'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: rules.length,
        itemBuilder: (context, index) {
          final rule = rules[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: darkGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Rule ${rule['num']}',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          rule['title']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🇮🇹 ${rule['it']!}',
                    style: const TextStyle(fontSize: 12, height: 1.3, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🇬🇧 ${rule['en']!}',
                    style: TextStyle(fontSize: 11.5, height: 1.3, color: Colors.blue.shade900),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      rule['ur']!,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF043927), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}