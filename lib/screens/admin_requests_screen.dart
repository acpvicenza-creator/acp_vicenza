import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/audit_log_service.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {

  // 🔍 UNIVERSAL FRONT/BACK DOCUMENT EXTRACTOR
  List<Map<String, String>> _extractAllDocuments(Map<String, dynamic> data) {
    List<Map<String, String>> docs = [];

    void addIfValid(String title, dynamic urlVal) {
      if (urlVal != null) {
        String u = urlVal.toString().trim();
        if (u.isNotEmpty && (u.startsWith('http://') || u.startsWith('https://'))) {
          if (!docs.any((element) => element['url'] == u)) {
            docs.add({'title': title, 'url': u});
          }
        }
      }
    }

    // 1. Direct Root-Level Keys (Front & Back)
    addIfValid('Carta d\'Identità (Front)', data['cartaIdentitaFront']);
    addIfValid('Carta d\'Identità (Back)', data['cartaIdentitaBack']);
    addIfValid('Carta d\'Identità', data['cartaIdentita']);

    addIfValid('Pakistan ID Card (Front)', data['pakIdCardFront']);
    addIfValid('Pakistan ID Card (Back)', data['pakIdCardBack']);
    addIfValid('Pakistan ID Card', data['pakIdCard']);

    addIfValid('Permesso di Soggiorno (Front)', data['permessoSoggiornoFront']);
    addIfValid('Permesso di Soggiorno (Back)', data['permessoSoggiornoBack']);
    addIfValid('Permesso di Soggiorno', data['permessoSoggiorno']);

    addIfValid('Passaporto', data['passaporto']);
    addIfValid('Codice Fiscale Card', data['codiceFiscale']);

    // 2. Direct Url-Suffix Keys
    addIfValid('Carta d\'Identità (Front)', data['cartaIdentitaFrontUrl']);
    addIfValid('Carta d\'Identità (Back)', data['cartaIdentitaBackUrl']);
    addIfValid('Carta d\'Identità', data['cartaIdentitaUrl']);

    addIfValid('Pakistan ID Card (Front)', data['pakIdCardFrontUrl']);
    addIfValid('Pakistan ID Card (Back)', data['pakIdCardBackUrl']);
    addIfValid('Pakistan ID Card', data['pakIdCardUrl']);

    addIfValid('Permesso di Soggiorno (Front)', data['permessoSoggiornoFrontUrl']);
    addIfValid('Permesso di Soggiorno (Back)', data['permessoSoggiornoBackUrl']);
    addIfValid('Permesso di Soggiorno', data['permessoSoggiornoUrl']);

    addIfValid('Passaporto', data['passaportoUrl']);
    addIfValid('Codice Fiscale Card', data['codiceFiscaleUrl']);

    // 3. Map-Level Keys ('documentUrls')
    if (data['documentUrls'] is Map) {
      final docMap = data['documentUrls'] as Map<String, dynamic>;
      docMap.forEach((key, val) {
        if (key != 'altro') {
          String displayTitle = key;
          if (key == 'cartaIdentitaFront') displayTitle = 'Carta d\'Identità (Front)';
          if (key == 'cartaIdentitaBack') displayTitle = 'Carta d\'Identità (Back)';
          if (key == 'cartaIdentita') displayTitle = 'Carta d\'Identità';
          if (key == 'pakIdCardFront') displayTitle = 'Pakistan ID Card (Front)';
          if (key == 'pakIdCardBack') displayTitle = 'Pakistan ID Card (Back)';
          if (key == 'pakIdCard') displayTitle = 'Pakistan ID Card';
          if (key == 'permessoSoggiornoFront') displayTitle = 'Permesso di Soggiorno (Front)';
          if (key == 'permessoSoggiornoBack') displayTitle = 'Permesso di Soggiorno (Back)';
          if (key == 'permessoSoggiorno') displayTitle = 'Permesso di Soggiorno';
          if (key == 'passaporto') displayTitle = 'Passaporto';
          if (key == 'codiceFiscale') displayTitle = 'Codice Fiscale Card';
          addIfValid(displayTitle, val);
        }
      });
    }

    // 4. Array-Level List ('documents')
    if (data['documents'] is List) {
      final List docList = data['documents'];
      for (int i = 0; i < docList.length; i++) {
        addIfValid('Scanned File ${i + 1}', docList[i]);
      }
    }

    return docs;
  }

  // 📂 MODAL TO VIEW & DOWNLOAD DOCUMENTS
  void _openRequestDetailModal(String docId, Map<String, dynamic> data) {
    final List<Map<String, String>> validDocs = _extractAllDocuments(data);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                Text(
                  data['fullName'] ?? 'Applicant',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF043927)),
                ),
                Text(
                  'N. Pratica: ${data['nPratica'] ?? 'N/A'} | CF: ${data['fiscalCode'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Divider(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.attach_file, size: 16, color: Color(0xFF043927)),
                        SizedBox(width: 6),
                        Text(
                          'ATTACHED DOCUMENTS',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF043927)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: validDocs.isNotEmpty ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${validDocs.length} File(s) Found',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: validDocs.isNotEmpty ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 📄 ATTACHED DOCUMENTS LIST WITH DOWNLOAD/VIEW ACTION
                if (validDocs.isNotEmpty)
                  ...validDocs.map((doc) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: Colors.blue.shade50.withValues(alpha: 0.5),
                    child: ListTile(
                      leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                      title: Text(doc['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: const Text('Tap to view or download document PDF/Image', style: TextStyle(fontSize: 11)),
                      trailing: const ElevatedButton(
                        onPressed: null,
                        style: ButtonStyle(elevation: WidgetStatePropertyAll(0)),
                        child: Text('Download / Open', style: TextStyle(fontSize: 11, color: Color(0xFF043927))),
                      ),
                      onTap: () async {
                        final String cleanUrl = doc['url']!.trim();
                        final uri = Uri.parse(cleanUrl);
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not launch URL: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ))
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Text(
                      'No scanned documents attached for this registration.\n(Ensure user attaches docs during registration)',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 20),

                // APPROVE & REJECT ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final nav = Navigator.of(ctx);
                          final messenger = ScaffoldMessenger.of(context);

                          await FirebaseFirestore.instance.collection('members').doc(docId).update({
                            'status': 'Approved',
                            'paymentStatus': 'Pending Payment',
                          });
                          await AuditLogService.logAction(
                            actionTitle: 'Member Application Approved',
                            details: 'Approved application for ${data['fullName']} (${data['nPratica']})',
                            targetMemberId: docId,
                          );

                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Application for ${data['fullName']} Approved! ✅'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.close),
                        label: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          final nav = Navigator.of(ctx);
                          final messenger = ScaffoldMessenger.of(context);

                          await FirebaseFirestore.instance.collection('members').doc(docId).update({
                            'status': 'Rejected',
                          });
                          await AuditLogService.logAction(
                            actionTitle: 'Member Application Rejected',
                            details: 'Rejected application for ${data['fullName']} (${data['nPratica']})',
                            targetMemberId: docId,
                          );

                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Application for ${data['fullName']} Rejected.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Registration Requests'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('members')
            .where('status', isEqualTo: 'Pending Approval')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text('No pending registration requests at the moment.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final validDocs = _extractAllDocuments(data);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: validDocs.isNotEmpty ? Colors.green.shade100 : Colors.orange.shade100,
                    child: Icon(
                      validDocs.isNotEmpty ? Icons.folder_shared : Icons.person_add,
                      color: validDocs.isNotEmpty ? Colors.green.shade800 : Colors.orange,
                    ),
                  ),
                  title: Text(
                    data['fullName'] ?? 'Applicant',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'N. Pratica: ${data['nPratica'] ?? 'N/A'}\nDocs Attached: ${validDocs.length} File(s)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: validDocs.isNotEmpty ? Colors.green.shade800 : Colors.grey,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: darkGreen),
                  onTap: () => _openRequestDetailModal(doc.id, data),
                ),
              );
            },
          );
        },
      ),
    );
  }
}