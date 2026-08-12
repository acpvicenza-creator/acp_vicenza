import 'package:flutter/material.dart';
import 'privacy_policy_screen.dart';

class AboutAcpScreen extends StatelessWidget {
  const AboutAcpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Chi Siamo - ACP'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi Siamo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Associazione Culturale Comunità Pakistana di Vicenza (ACP)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'L\'Associazione Culturale Comunità Pakistana di Vicenza (ACP) è un\'organizzazione senza scopo di lucro fondata con l\'obiettivo di promuovere la cultura pakistana, favorire l\'integrazione sociale e sostenere la comunità pakistana residente a Vicenza e nelle province limitrofe.',
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 10),
            Text(
              'ACP rappresenta un punto di riferimento per famiglie, giovani e cittadini pakistani, creando un ambiente basato su solidarietà, rispetto e collaborazione. Attraverso le sue attività, l\'associazione contribuisce a rafforzare il dialogo interculturale e a valorizzare le tradizioni del Pakistan all\'interno della società italiana.',
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade800),
            ),

            const SizedBox(height: 16),

            // 📜 MUBARAK HADEES-E-PAK (EQUALITY / MASAWAT BANNER)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.format_quote_rounded, color: Colors.amber, size: 30),
                  const SizedBox(height: 4),

                  // ARABIC / URDU HEADING
                  const Text(
                    'قَالَ رَسُولُ اللَّهِ ﷺ',
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // URDU TRANSLATION
                  const Text(
                    '”کسی عربی کو کسی عجمی پر اور کسی عجمی کو کسی عربی پر، نہ کسی گورے کو کسی کالے پر اور نہ کسی کالے کو کسی گورے پر کوئی فضیلت حاصل ہے مگر تقویٰ کے سبب۔“',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.6,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '(خطبہ حجتہ الوداع - مسند احمد)',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),

                  const Divider(color: Colors.white24, height: 20),

                  // ITALIAN TRANSLATION
                  const Text(
                    '«Un arabo non ha alcuna superiorità su un non-arabo, né un non-arabo ha superiorità su un arabo; un bianco non è superiore a un nero, né un nero è superiore a un bianco, se non per la pietà e le buone azioni.»',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '— Ultimo Sermone del Profeta Muhammad ﷺ (Musnad Ahmad)',
                    style: TextStyle(fontSize: 10, color: Colors.amber),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            // 🔐 PRIVACY POLICY & TERMS CARD
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_outlined, color: darkGreen),
                ),
                title: const Text(
                  'Privacy Policy & Terms of Service',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                subtitle: const Text(
                  'Learn how we process & protect member data',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'La Nostra Missione',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'La nostra missione è quella di costruire una comunità unita e solidale, promuovendo iniziative culturali, sociali e di assistenza che migliorino la qualità della vita dei nostri membri e favoriscano l\'integrazione nel territorio italiano.',
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade800),
            ),

            const SizedBox(height: 20),

            const Text(
              'I Nostri Servizi & Attività',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 10),

            // ⚰️ COMITATO FUNEBRE (DEATH COMMITTEE) CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.volunteer_activism, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Comitato Funebre (Death Committee)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ACP offre ai propri connazionali iscritti un servizio dedicato di Comitato Funebre (Death Committee). In caso di decesso, l\'associazione garantisce supporto completo per le pratiche consolari, legali, la preghiera funebre (Janazah) e il rimpatrio dignitoso della salma in Pakistan o la sepoltura in Italia in conformità con i principi islamici.',
                      style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            _buildServiceCard(
              title: 'Eventi Culturali & Religiosi',
              description:
              'Organizziamo durante tutto l\'anno eventi culturali, religiosi e ricreativi per celebrare le tradizioni pakistane, rafforzare il senso di appartenenza e favorire l\'incontro tra culture diverse.',
            ),
            const SizedBox(height: 10),
            _buildServiceCard(
              title: 'Assistenza alla Comunità & Integrazione',
              description:
              'Supportiamo i cittadini pakistani residenti in Italia con attività informative, orientamento documentale, iniziative sociali e momenti di condivisione.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({required String title, required String description}) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF043927),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 12.5, height: 1.4, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}