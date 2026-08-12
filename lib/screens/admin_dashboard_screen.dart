import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart'; // 👈 AppTheme access karne ke liye
import 'member_card_screen.dart';
import 'qr_scanner_screen.dart';
import 'admin_edit_prayer_times_screen.dart';
import 'admin_add_announcement_screen.dart';
import 'admin_add_death_alert_screen.dart';
import 'admin_financial_ledger_screen.dart';
import 'admin_requests_screen.dart';
import 'admin_audit_logs_screen.dart';
import 'admin_advanced_death_case_screen.dart';
import '../services/audit_log_service.dart';
import '../services/pdf_service.dart';
import '../services/excel_export_service.dart';
import '../services/renewal_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _searchQuery = '';
  String _filterType = 'ALL';

  @override
  void initState() {
    super.initState();
    RenewalService.checkAndApplyAnnualRenewals();
  }

  // 🎨 LIVE ADMIN THEME SELECTOR MODAL
  void showAdminThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎨 Select Global App Theme (Admin Only)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...AppTheme.themes.values.map((theme) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor,
                      child: Icon(Icons.palette, color: theme.accentColor, size: 18),
                    ),
                    title: Text(theme.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    trailing: const Icon(Icons.check_circle_outline),
                    onTap: () async {
                      await FirebaseFirestore.instance
                          .collection('app_settings')
                          .doc('theme_config')
                          .set({'activeTheme': theme.id}, SetOptions(merge: true));

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Theme changed to ${theme.name} for all users! 🚀')),
                        );
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  final List<String> _statusOptions = [
    'Pending Approval',
    'Approved',
    'Rejected',
    'Deceased',
  ];

  final List<String> _paymentStatusOptions = [
    'Pending Payment',
    'Payment Submitted (Pending Verification)',
    'Paid',
  ];

  List<Map<String, String>> _extractAllDocuments(Map<String, dynamic> data) {
    List<Map<String, String>> docs = [];

    void addIfValid(String title, dynamic urlVal) {
      if (urlVal != null) {
        String u = urlVal.toString().trim();
        if (u.isNotEmpty && u.startsWith('http')) {
          if (!docs.any((element) => element['url'] == u)) {
            docs.add({'title': title, 'url': u});
          }
        }
      }
    }

    addIfValid('Carta d\'Identità (Front)', data['cartaIdentitaFront'] ?? data['cartaIdentitaFrontUrl']);
    addIfValid('Carta d\'Identità (Back)', data['cartaIdentitaBack'] ?? data['cartaIdentitaBackUrl']);
    addIfValid('Carta d\'Identità', data['cartaIdentitaUrl'] ?? data['cartaIdentita']);

    addIfValid('Pakistan ID Card (Front)', data['pakIdCardFront'] ?? data['pakIdCardFrontUrl']);
    addIfValid('Pakistan ID Card (Back)', data['pakIdCardBack'] ?? data['pakIdCardBackUrl']);
    addIfValid('Pakistan ID Card', data['pakIdCardUrl'] ?? data['pakIdCard']);

    addIfValid('Permesso di Soggiorno (Front)', data['permessoSoggiornoFront'] ?? data['permessoSoggiornoFrontUrl']);
    addIfValid('Permesso di Soggiorno (Back)', data['permessoSoggiornoBack'] ?? data['permessoSoggiornoBackUrl']);
    addIfValid('Permesso di Soggiorno', data['permessoSoggiornoUrl'] ?? data['permessoSoggiorno']);

    addIfValid('Passaporto', data['passaportoUrl'] ?? data['passaporto']);
    addIfValid('Codice Fiscale Card', data['codiceFiscaleUrl'] ?? data['codiceFiscale']);

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

    if (data['documents'] is List) {
      final List docList = data['documents'];
      for (int i = 0; i < docList.length; i++) {
        addIfValid('Scanned File ${i + 1}', docList[i]);
      }
    }

    return docs;
  }

  bool _checkHasDocuments(Map<String, dynamic> data) {
    return _extractAllDocuments(data).isNotEmpty;
  }

  void _openMemberDocumentsModal(Map<String, dynamic> data) {
    final List<Map<String, String>> validDocs = _extractAllDocuments(data);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Text(
                'Attached Documents: ${data['fullName'] ?? 'Member'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF043927)),
              ),
              Text('N. Pratica: ${data['nPratica'] ?? 'N/A'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const Divider(height: 20),

              if (validDocs.isNotEmpty)
                ...validDocs.map((doc) => _buildDocTile(doc['title']!, doc['url']!))
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No valid scanned documents found for this member.',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDocTile(String title, String url) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: const Text('Tap to view/download file', style: TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.open_in_new, color: Color(0xFF043927), size: 18),
        onTap: () async {
          final uri = Uri.parse(url.trim());
          final messenger = ScaffoldMessenger.of(context);
          try {
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              messenger.showSnackBar(
                const SnackBar(content: Text('Could not open document link.')),
              );
            }
          } catch (e) {
            debugPrint("Could not launch $url: $e");
          }
        },
      ),
    );
  }

  void _openManageAdminsDialog() {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'Vice President';

    final List<String> adminRoles = [
      'President',
      'Vice President',
      'General Secretary',
      'Finance Secretary / Cashier',
      'Executive Committee Member',
      'Auditor',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('🔐 Manage & Add Admins', style: TextStyle(color: Color(0xFF043927))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assign Admin Privileges to Committee Members',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Admin Email *',
                    hintText: 'e.g. secretary@acpvicenza.com',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Assign Login Password *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Committee Role',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: adminRoles.map((role) {
                    return DropdownMenuItem(value: role, child: Text(role, style: const TextStyle(fontSize: 12)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 15),

                const Divider(),
                const Text(
                  'Active Admins List:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('admins').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();
                    final adminDocs = snapshot.data!.docs;

                    if (adminDocs.isEmpty) {
                      return const Text('No extra admins added yet.', style: TextStyle(fontSize: 11, color: Colors.grey));
                    }

                    return SizedBox(
                      height: 120,
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: adminDocs.length,
                        itemBuilder: (context, index) {
                          final aData = adminDocs[index].data() as Map<String, dynamic>;
                          final docId = adminDocs[index].id;
                          final aEmail = aData['email'] ?? 'No Email';
                          final aRole = aData['role'] ?? 'Admin';

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(aEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            subtitle: Text('Role: $aRole', style: const TextStyle(fontSize: 10)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('admins').doc(docId).delete();
                                await AuditLogService.logAction(
                                  actionTitle: 'Admin Removed',
                                  details: 'Removed admin privileges from $aEmail',
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Close')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF043927),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Add Admin'),
              onPressed: () async {
                final email = emailCtrl.text.trim().toLowerCase();
                final pass = passwordCtrl.text.trim();

                if (email.isNotEmpty && pass.isNotEmpty) {
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(dialogCtx);

                  await FirebaseFirestore.instance.collection('admins').doc(email).set({
                    'email': email,
                    'password': pass,
                    'role': selectedRole,
                    'isActive': true,
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  await AuditLogService.logAction(
                    actionTitle: 'New Admin Created',
                    details: 'Created new Admin ($email) as $selectedRole',
                  );

                  nav.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Admin access granted to $email ($selectedRole)'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendFeeReminder(Map<String, dynamic> data) async {
    final messenger = ScaffoldMessenger.of(context);
    final name = data['fullName'] ?? 'Member';
    final phone = data['phone'] ?? '';
    final nPratica = data['nPratica'] ?? 'N/A';
    final totalFee = (data['totalFee'] as num?)?.toDouble() ?? 60.0;

    final message = '''
السلام عليكم $name,

Associazione Culturale Comunità Pakistana Di Vicenza (ACP)

Kindly note that your annual membership fee (€${totalFee.toStringAsFixed(0)}) for N. Pratica: $nPratica is currently pending.

⚠️ Deadline: 31st March (As per Rule 2 & Rule 9).
Please complete your payment to keep your Benefit Card active.

JazakAllah Khair!
''';

    final encodedMessage = Uri.encodeComponent(message);
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final whatsappUrl = Uri.parse("whatsapp://send?phone=$cleanPhone&text=$encodedMessage");
    final webUrl = Uri.parse("https://api.whatsapp.com/send?phone=$cleanPhone&text=$encodedMessage");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('WhatsApp not installed or invalid phone number.')),
      );
    }
  }

  Future<void> _generatePdfReceipt(Map<String, dynamic> memberData) async {
    final pdf = pw.Document();

    final name = memberData['fullName'] ?? 'Member';
    final nPratica = memberData['nPratica'] ?? 'N/A';
    final fiscalCode = memberData['fiscalCode'] ?? 'N/A';
    final type = memberData['membershipType'] ?? 'Single';
    final fee = (memberData['totalFee'] as num?)?.toDouble() ?? 0.0;
    final phone = memberData['phone'] ?? 'N/A';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  color: const PdfColor.fromInt(0xFF043927),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'ACP VICENZA - OFFICIAL RECEIPT',
                        style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'PAID',
                        style: pw.TextStyle(color: PdfColors.amber, fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.TableHelper.fromTextArray(
                  headers: ['Field', 'Details'],
                  data: [
                    ['N. Pratica', nPratica],
                    ['Member Name', name],
                    ['Fiscal Code', fiscalCode],
                    ['Contact Phone', phone],
                    ['Membership Plan', type],
                    ['Total Amount Received', 'EUR ${fee.toStringAsFixed(2)}'],
                    ['Payment Status', 'CONFIRMED & ACTIVE'],
                    ['Issue Date', '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF043927)),
                  cellPadding: const pw.EdgeInsets.all(8),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                ),

                pw.SizedBox(height: 25),
                pw.Text(
                  'This document serves as an official proof of payment for the ACP Vicenza Benefit/Funeral Committee.',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Associazione Culturale Comunità Pakistana Di Vicenza - Via R. Fabiani 47, Vicenza',
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'ACP_Receipt_$nPratica.pdf',
    );
  }

  void _openCreateEmergencyAppealDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '6000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🤝 Create Emergency Appeal (Chanda)', style: TextStyle(color: Color(0xFF043927))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Publish a new voluntary fund appeal to all members.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 10),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Appeal Title *', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Short Description', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target Amount (€)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF043927), foregroundColor: Colors.white),
            onPressed: () async {
              if (titleCtrl.text.isNotEmpty) {
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);

                await FirebaseFirestore.instance.collection('emergency_appeals').add({
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'targetAmount': double.tryParse(targetCtrl.text) ?? 6000.0,
                  'collectedAmount': 0.0,
                  'isActive': true,
                  'createdAt': FieldValue.serverTimestamp(),
                  'appealId': 'APPEAL-${DateTime.now().millisecondsSinceEpoch}',
                });

                nav.pop();
                messenger.showSnackBar(const SnackBar(content: Text('Emergency Appeal Created Successfully!')));
              }
            },
            child: const Text('Publish Appeal'),
          ),
        ],
      ),
    );
  }

  void _openWhatsAppBroadcastDialog() {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('📢 WhatsApp Community Broadcast', style: TextStyle(color: Color(0xFF043927))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write message to broadcast via WhatsApp:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: msgCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'e.g. Namaz-e-Janazah announcement, emergency alert, or fee update...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Send WhatsApp Broadcast'),
            onPressed: () async {
              if (msgCtrl.text.trim().isNotEmpty) {
                final text = Uri.encodeComponent(msgCtrl.text.trim());
                final whatsappUrl = Uri.parse("whatsapp://send?text=$text");
                final webUrl = Uri.parse("https://api.whatsapp.com/send?text=$text");
                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(ctx);

                nav.pop();

                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl);
                } else if (await canLaunchUrl(webUrl)) {
                  await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                } else {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('WhatsApp application not found.')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _exportMembersPdf(List<QueryDocumentSnapshot> docs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'ACP Vicenza - Registered Members Report',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['N. Pratica', 'Full Name', 'Fiscal Code', 'Phone', 'Status', 'Payment'],
                data: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return [
                    data['nPratica'] ?? '',
                    data['fullName'] ?? '',
                    data['fiscalCode'] ?? '',
                    data['phone'] ?? '',
                    data['status'] ?? 'Pending',
                    data['paymentStatus'] ?? 'Pending',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF043927)),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                ),
                cellPadding: const pw.EdgeInsets.all(5),
                cellStyle: const pw.TextStyle(fontSize: 8),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'ACP_Members_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  void _confirmDeleteMember(String docId, String memberName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member', style: TextStyle(color: Colors.red)),
        content: Text('Are you sure you want to permanently delete "$memberName"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final nav = Navigator.of(ctx);

              await FirebaseFirestore.instance.collection('members').doc(docId).delete();

              await AuditLogService.logAction(
                actionTitle: 'Member Deleted',
                details: 'Permanently deleted member record: $memberName',
                targetMemberId: docId,
              );

              nav.pop();
              messenger.showSnackBar(
                SnackBar(
                  content: Text('Member "$memberName" deleted successfully.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('ACP Admin Panel'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // 🎨 GLOBAL THEME SWITCHER BUTTON (ADMIN ONLY)
          IconButton(
            icon: const Icon(Icons.palette_outlined, color: Colors.amberAccent),
            tooltip: 'Change Global App Theme',
            onPressed: () => showAdminThemeSelector(context),
          ),

          // 📊 EXCEL REPORT EXPORT ACTION BUTTON
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('members').snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              return IconButton(
                icon: const Icon(Icons.table_chart),
                tooltip: 'Export Members to Excel (.xlsx)',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (docs.isNotEmpty) {
                    final List<Map<String, dynamic>> membersList = docs.map((doc) {
                      return doc.data() as Map<String, dynamic>;
                    }).toList();

                    await ExcelExportService.exportMembersToExcel(membersList);
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('No members data available to export.')),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: darkGreen),
              accountName: Text('Admin Panel Control', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              accountEmail: Text('ACP Vicenza Death Committee'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: darkGreen, size: 36),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.palette, color: Colors.amber),
              title: const Text('Change Global App Theme'),
              onTap: () {
                Navigator.pop(context);
                showAdminThemeSelector(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: darkGreen),
              title: const Text('Manage & Add Admins'),
              onTap: () {
                Navigator.pop(context);
                _openManageAdminsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: darkGreen),
              title: const Text('Admin Audit Logs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAuditLogsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.airline_seat_flat, color: darkGreen),
              title: const Text('Advanced Repatriation Manager'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminAdvancedDeathCaseScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism, color: darkGreen),
              title: const Text('Create Emergency Appeal'),
              onTap: () {
                Navigator.pop(context);
                _openCreateEmergencyAppealDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: darkGreen),
              title: const Text('WhatsApp Broadcast'),
              onTap: () {
                Navigator.pop(context);
                _openWhatsAppBroadcastDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: darkGreen),
              title: const Text('Financial Ledger'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFinancialLedgerScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.mark_email_unread_outlined, color: darkGreen),
              title: const Text('Member Requests'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.campaign, color: darkGreen),
              title: const Text('Broadcast Announcement'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAddAnnouncementScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.mosque, color: darkGreen),
              title: const Text('Edit Prayer Times'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEditPrayerTimesScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: darkGreen),
              title: const Text('QR Scanner'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScannerScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Admin Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('members').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.gpp_bad_rounded, size: 60, color: Colors.red),
                    const SizedBox(height: 12),
                    const Text(
                      'Firestore Permission Denied!',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Please update Rules in Firebase Console to allow reading "members" collection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {});
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry Fetching Data'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;
          final int totalMembers = allDocs.length;

          final int missingDocsCount = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return !_checkHasDocuments(data);
          }).length;

          final int pendingPaymentCount = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return (data['paymentStatus'] ?? 'Pending Payment') != 'Paid';
          }).length;

          final filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['fullName'] ?? '').toString().toLowerCase();
            final nPratica = (data['nPratica'] ?? '').toString().toLowerCase();
            final bool matchesSearch = name.contains(_searchQuery) || nPratica.contains(_searchQuery);

            if (!matchesSearch) return false;

            if (_filterType == 'MISSING_DOCS') {
              return !_checkHasDocuments(data);
            } else if (_filterType == 'PENDING_PAYMENT') {
              return (data['paymentStatus'] ?? 'Pending Payment') != 'Paid';
            }

            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    _buildStatCard('Total\nMembers', '$totalMembers', Colors.blue, () {
                      setState(() => _filterType = 'ALL');
                    }, _filterType == 'ALL'),
                    const SizedBox(width: 8),
                    _buildStatCard('Missing\nDocs', '$missingDocsCount', Colors.orange.shade800, () {
                      setState(() => _filterType = 'MISSING_DOCS');
                    }, _filterType == 'MISSING_DOCS'),
                    const SizedBox(width: 8),
                    _buildStatCard('Pending\nPayment', '$pendingPaymentCount', Colors.red, () {
                      setState(() => _filterType = 'PENDING_PAYMENT');
                    }, _filterType == 'PENDING_PAYMENT'),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: filteredDocs.isEmpty ? null : () => _exportMembersPdf(filteredDocs),
                    icon: const Icon(Icons.picture_as_pdf, size: 18),
                    label: Text('Download / Print PDF List (${filteredDocs.length})', style: const TextStyle(fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminAddDeathAlertScreen()),
                          );
                        },
                        icon: const Icon(Icons.warning_amber_rounded, size: 16),
                        label: const Text('Janazah Alert', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade800,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminFinancialLedgerScreen()),
                          );
                        },
                        icon: const Icon(Icons.account_balance_wallet, size: 16),
                        label: const Text('Ledger', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminEditPrayerTimesScreen()),
                          );
                        },
                        icon: const Icon(Icons.mosque, size: 16),
                        label: const Text('Prayers', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by Name or N. Pratica...',
                    prefixIcon: const Icon(Icons.search, color: darkGreen),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
              ),

              Expanded(
                child: filteredDocs.isEmpty
                    ? const Center(child: Text('No members found.'))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    String currentStatus = data['status'] ?? 'Pending Approval';
                    if (!_statusOptions.contains(currentStatus)) {
                      currentStatus = 'Pending Approval';
                    }

                    String currentPayment = data['paymentStatus'] ?? 'Pending Payment';
                    if (!_paymentStatusOptions.contains(currentPayment)) {
                      currentPayment = 'Pending Payment';
                    }

                    final List family = data['familyMembers'] ?? [];
                    final bool hasDocs = _checkHasDocuments(data);
                    final String memberName = data['fullName'] ?? 'No Name';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: currentStatus == 'Approved'
                              ? Colors.green.shade100
                              : (currentStatus == 'Deceased' ? Colors.black12 : Colors.orange.shade100),
                          child: Icon(
                            currentStatus == 'Approved'
                                ? Icons.check_circle
                                : (currentStatus == 'Deceased' ? Icons.brightness_3 : Icons.hourglass_top),
                            color: currentStatus == 'Approved'
                                ? Colors.green
                                : (currentStatus == 'Deceased' ? Colors.black87 : Colors.orange),
                          ),
                        ),
                        title: Text(
                          memberName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: currentStatus == 'Deceased' ? Colors.red.shade900 : Colors.black,
                          ),
                        ),
                        subtitle: Text('${data['nPratica'] ?? ''} | Fee: €${data['totalFee'] ?? '0'}'),

                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: darkGreen),
                          onSelected: (val) async {
                            if (val == 'pdf') {
                              await PdfService.generateMemberRegistrationPdf(data);
                            } else if (val == 'docs') {
                              _openMemberDocumentsModal(data);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'pdf',
                              child: Row(
                                children: [
                                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text('Export Member Dossier (PDF)', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'docs',
                              child: Row(
                                children: [
                                  Icon(Icons.folder_shared, color: darkGreen, size: 18),
                                  SizedBox(width: 8),
                                  Text('View Attached Scanned Docs', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(),
                                Text('• Fiscal Code: ${data['fiscalCode'] ?? 'N/A'}'),
                                Text('• Phone: ${data['phone'] ?? 'N/A'}'),
                                Text('• Membership Type: ${data['membershipType'] ?? 'Single'}'),
                                Text('• Address: ${data['addressItaly'] ?? 'N/A'}'),
                                Text(
                                  '• Documents Attached: ${hasDocs ? "Yes ✅" : "No ❌"}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hasDocs ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                if (family.isNotEmpty) ...[
                                  const Text('Family Members:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ...family.map((f) => Text('  - ${f['fullName']} (${f['gender']}) | DOB: ${f['dob']}', style: const TextStyle(fontSize: 11))),
                                  const SizedBox(height: 8),
                                ],

                                const Divider(),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('App Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    DropdownButton<String>(
                                      value: currentStatus,
                                      items: _statusOptions.map((status) {
                                        return DropdownMenuItem(
                                          value: status,
                                          child: Text(
                                            status == 'Deceased' ? '🪦 Deceased' : status,
                                            style: TextStyle(
                                              color: status == 'Deceased' ? Colors.red.shade900 : Colors.black,
                                              fontWeight: status == 'Deceased' ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (newVal) async {
                                        if (newVal != null) {
                                          final messenger = ScaffoldMessenger.of(context);
                                          await FirebaseFirestore.instance.collection('members').doc(doc.id).update({'status': newVal});
                                          await AuditLogService.logAction(
                                            actionTitle: newVal == 'Deceased' ? 'Member Marked as Deceased 🪦' : 'Member Status Changed',
                                            details: 'Changed status of $memberName to $newVal',
                                            targetMemberId: doc.id,
                                          );

                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text('Member "$memberName" status updated to $newVal'),
                                              backgroundColor: newVal == 'Deceased' ? Colors.black87 : Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                // 🔄 FIXED PAYMENT STATUS DROPDOWN (Saves lastPaidYear & prevents auto-revert)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Payment Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    DropdownButton<String>(
                                      value: currentPayment,
                                      items: _paymentStatusOptions.map((status) {
                                        return DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontSize: 12)));
                                      }).toList(),
                                      onChanged: (newVal) async {
                                        if (newVal != null) {
                                          final int currentYear = DateTime.now().year;
                                          Map<String, dynamic> updateData = {
                                            'paymentStatus': newVal,
                                          };

                                          if (newVal == 'Paid') {
                                            updateData['lastPaidYear'] = currentYear;
                                            updateData['paidAt'] = FieldValue.serverTimestamp();
                                            updateData['isOverdue'] = false;
                                          }

                                          await FirebaseFirestore.instance.collection('members').doc(doc.id).update(updateData);
                                          await AuditLogService.logAction(
                                            actionTitle: 'Payment Status Updated',
                                            details: 'Updated payment status of $memberName to $newVal',
                                            targetMemberId: doc.id,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    if (currentPayment != 'Paid')
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF25D366),
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.notifications_active, size: 16),
                                          label: const Text('Send Reminder', style: TextStyle(fontSize: 11)),
                                          onPressed: () => _sendFeeReminder(data),
                                        ),
                                      ),
                                    if (currentPayment != 'Paid') const SizedBox(width: 8),

                                    if (currentPayment == 'Paid')
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue.shade900,
                                            foregroundColor: Colors.white,
                                          ),
                                          icon: const Icon(Icons.receipt, size: 16),
                                          label: const Text('Generate Receipt', style: TextStyle(fontSize: 11)),
                                          onPressed: () => _generatePdfReceipt(data),
                                        ),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                if (currentStatus == 'Approved') ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: darkGreen, foregroundColor: Colors.white),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => MemberCardScreen(memberData: data)),
                                        );
                                      },
                                      icon: const Icon(Icons.qr_code),
                                      label: const Text('View Member Digital Card'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _confirmDeleteMember(doc.id, memberName),
                                    icon: const Icon(Icons.delete_forever, size: 18),
                                    label: const Text('Delete Member Record', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, VoidCallback onTap, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}