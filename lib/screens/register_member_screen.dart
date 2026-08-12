import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import '../services/db_helper.dart';
import 'rules_and_regulations_screen.dart';
import 'payment_screen.dart';

class RegisterMemberScreen extends StatefulWidget {
  const RegisterMemberScreen({super.key});

  @override
  State<RegisterMemberScreen> createState() => _RegisterMemberScreenState();
}

class _RegisterMemberScreenState extends State<RegisterMemberScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. DATI DEL RICHIEDENTE / CAPOFAMIGLIA
  final _nPraticaController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _fiscalCodeController = TextEditingController();
  String _gender = 'M';
  final _phoneController = TextEditingController();
  final _passportController = TextEditingController();
  final _idCardController = TextEditingController();
  final _permessoController = TextEditingController();
  final _cittadinanzaController = TextEditingController();
  final _pakPhoneController = TextEditingController();
  final _italyAddressController = TextEditingController();
  final _comuneProvinciaController = TextEditingController();
  final _pakAddressController = TextEditingController();
  final _fatherNameController = TextEditingController();

  // DYNAMIC MEMBERSHIP FEE STRUCTURE
  String _membershipType = 'Single';
  double _annualFee = 60.0;
  bool _isRenewal = false;

  // AUTO-CHECK STATE VARIABLES
  bool _isCheckingDb = false;
  String? _detectedMemberInfo;

  double get _registrationFee => _isRenewal ? 0.0 : 20.0;
  double get _totalFee => _annualFee + _registrationFee;

  // RULES ACCEPTANCE CHECKBOX
  bool _acceptedRules = false;

  // 🖊️ DIGITAL SIGNATURE CONTROLLER
  final SignatureController _sigController = SignatureController(
    penStrokeWidth: 3,
    penColor: const Color(0xFF1B3B6F),
    exportBackgroundColor: Colors.white,
  );

  // 2. DATI DEI FAMILIARI
  final List<Map<String, dynamic>> _familyMembers = [];

  // 3. FRONT & BACK DOCUMENT ATTACHMENTS & PROFILE PHOTO
  File? _profilePhotoFile;
  File? _docCartaFrontFile;
  File? _docCartaBackFile;
  File? _docPakIdFrontFile;
  File? _docPakIdBackFile;
  File? _docPermessoFrontFile;
  File? _docPermessoBackFile;
  File? _docPassaportoFile;
  File? _docCodiceFiscaleFile;
  final _docAltroController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  bool get _isItalianCitizen {
    final cleanCittadinanza = _cittadinanzaController.text.trim().toLowerCase();
    return cleanCittadinanza.contains('italia') || cleanCittadinanza.contains('italy') || cleanCittadinanza == 'it';
  }

  String _generateRandomPassword() {
    final random = Random();
    final number = 100000 + random.nextInt(900000);
    return number.toString();
  }

  Future<void> _saveNPraticaForLogin(String nPratica) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_n_pratica', nPratica);
  }

  @override
  void initState() {
    super.initState();
    _generateAutomaticNPratica();
    _loadDraftFormData();
  }

  @override
  void dispose() {
    _sigController.dispose();
    _nPraticaController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _fiscalCodeController.dispose();
    _phoneController.dispose();
    _passportController.dispose();
    _idCardController.dispose();
    _permessoController.dispose();
    _cittadinanzaController.dispose();
    _pakPhoneController.dispose();
    _italyAddressController.dispose();
    _comuneProvinciaController.dispose();
    _pakAddressController.dispose();
    _fatherNameController.dispose();
    _docAltroController.dispose();
    super.dispose();
  }

  // 🖼️ PICK PROFILE PHOTO FUNCTION
  Future<void> _pickProfilePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profilePhotoFile = File(pickedFile.path);
      });
    }
  }

  // 🖊️ CONVERT DIGITAL SIGNATURE TO BASE64
  Future<String?> _getSignatureBase64() async {
    if (_sigController.isEmpty) return null;
    final Uint8List? pngBytes = await _sigController.toPngBytes();
    if (pngBytes == null) return null;
    return base64Encode(pngBytes);
  }

  Future<void> _checkExistingMember(String input) async {
    final cleanInput = input.trim().toUpperCase();
    if (cleanInput.length < 5) {
      setState(() {
        _isRenewal = false;
        _detectedMemberInfo = null;
      });
      return;
    }

    setState(() => _isCheckingDb = true);

    try {
      final fiscalQuery = await FirebaseFirestore.instance
          .collection('members')
          .where('fiscalCode', isEqualTo: cleanInput)
          .get();

      QuerySnapshot? finalQuery = fiscalQuery;

      if (fiscalQuery.docs.isEmpty) {
        finalQuery = await FirebaseFirestore.instance
            .collection('members')
            .where('nPratica', isEqualTo: cleanInput)
            .get();
      }

      if (finalQuery.docs.isNotEmpty) {
        final data = finalQuery.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _isRenewal = true;
          _membershipType = data['membershipType'] ?? 'Single';
          _annualFee = _membershipType == 'Family' ? 120.0 : 60.0;
          if ((data['fullName'] ?? '').isNotEmpty) _fullNameController.text = data['fullName'];
          if ((data['email'] ?? '').isNotEmpty) _emailController.text = data['email'];
          if ((data['phone'] ?? '').isNotEmpty) _phoneController.text = data['phone'];
          if ((data['cittadinanza'] ?? '').isNotEmpty) _cittadinanzaController.text = data['cittadinanza'];
          _detectedMemberInfo = "Existing Member Detected: ${data['nPratica'] ?? ''} (${data['fullName'] ?? ''})";
        });
      } else {
        setState(() {
          _isRenewal = false;
          _detectedMemberInfo = null;
        });
      }
    } catch (e) {
      debugPrint("DB Check Error: $e");
    } finally {
      if (mounted) setState(() => _isCheckingDb = false);
    }
  }

  Future<void> _loadDraftFormData() async {
    try {
      final db = await DBHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('registration_draft', limit: 1);

      if (maps.isNotEmpty) {
        final draft = maps.first;
        setState(() {
          _fullNameController.text = draft['fullName'] ?? '';
          _emailController.text = draft['email'] ?? '';
          _dobController.text = draft['dob'] ?? '';
          _fiscalCodeController.text = draft['fiscalCode'] ?? '';
          _gender = draft['gender'] ?? 'M';
          _phoneController.text = draft['phone'] ?? '';
          _passportController.text = draft['passport'] ?? '';
          _idCardController.text = draft['idCard'] ?? '';
          _permessoController.text = draft['permesso'] ?? '';
          _cittadinanzaController.text = draft['cittadinanza'] ?? '';
          _pakPhoneController.text = draft['pakPhone'] ?? '';
          _italyAddressController.text = draft['italyAddress'] ?? '';
          _comuneProvinciaController.text = draft['comuneProvincia'] ?? '';
          _pakAddressController.text = draft['pakAddress'] ?? '';
          _fatherNameController.text = draft['fatherName'] ?? '';
          _membershipType = draft['membershipType'] ?? 'Single';
          _annualFee = _membershipType == 'Family' ? 120.0 : 60.0;

          if (draft['familyJson'] != null && (draft['familyJson'] as String).isNotEmpty) {
            final List decoded = jsonDecode(draft['familyJson']);
            _familyMembers.clear();
            _familyMembers.addAll(decoded.cast<Map<String, dynamic>>());
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unsubmitted form restored from draft! 📝'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _saveDraftLocally() async {
    try {
      final db = await DBHelper.database;
      await db.delete('registration_draft');
      await db.insert('registration_draft', {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'dob': _dobController.text.trim(),
        'fiscalCode': _fiscalCodeController.text.trim(),
        'gender': _gender,
        'phone': _phoneController.text.trim(),
        'passport': _passportController.text.trim(),
        'idCard': _idCardController.text.trim(),
        'permesso': _permessoController.text.trim(),
        'cittadinanza': _cittadinanzaController.text.trim(),
        'pakPhone': _pakPhoneController.text.trim(),
        'italyAddress': _italyAddressController.text.trim(),
        'comuneProvincia': _comuneProvinciaController.text.trim(),
        'pakAddress': _pakAddressController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'membershipType': _membershipType,
        'familyJson': jsonEncode(_familyMembers),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> _clearDraft() async {
    try {
      final db = await DBHelper.database;
      await db.delete('registration_draft');
    } catch (_) {}
  }

  Future<void> _generateAutomaticNPratica() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('members').get();
      final count = snapshot.docs.length + 1001;
      final currentYear = DateTime.now().year;
      setState(() {
        _nPraticaController.text = 'ACP-$currentYear-$count';
      });
    } catch (e) {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      setState(() {
        _nPraticaController.text = 'ACP-${DateTime.now().year}-$timestamp';
      });
    }
  }

  Future<void> _showDocumentOptionModal(String docType, Function(File) onFileSelected) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                Center(
                  child: Text(
                    'Attach / Scan $docType',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F)),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.document_scanner, color: Color(0xFF1B3B6F)),
                  title: const Text('Scan Document with Camera'),
                  subtitle: const Text('Take a clear photo of physical document'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await _pickDocument(ImageSource.camera);
                    if (file != null) onFileSelected(file);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: const Text('Choose from Gallery / Files'),
                  subtitle: const Text('Select pre-existing image file'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final file = await _pickDocument(ImageSource.gallery);
                    if (file != null) onFileSelected(file);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<File?> _pickDocument(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image != null) return File(image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking document: $e')),
        );
      }
    }
    return null;
  }

  // 📤 SEPARATE FOLDER PER MEMBER IN FIREBASE STORAGE
  Future<String?> _uploadFile(File? file, String docType) async {
    if (file == null) return null;
    try {
      final String memberFolder = _nPraticaController.text.trim();
      final String fileName = '${docType}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = FirebaseStorage.instance
          .ref()
          .child('member_documents')
          .child(memberFolder)
          .child(fileName);

      final uploadTask = await ref.putFile(file).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Upload Timed Out'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Storage Upload Error ($docType): $e");
      return null;
    }
  }

  void _addFamilyMemberDialog() {
    final nameCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    final cfCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passportCtrl = TextEditingController();
    final cittadinanzaCtrl = TextEditingController();
    String gender = 'M';
    bool undertakingAccepted = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          int age = 0;
          try {
            final parts = dobCtrl.text.trim().split('/');
            if (parts.length == 3) {
              final birthDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
              final now = DateTime.now();
              age = now.year - birthDate.year;
              if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
                age--;
              }
            }
          } catch (_) {}

          return AlertDialog(
            title: const Text('Add Family Member'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nome e Cognome *'),
                  ),
                  TextField(
                    controller: dobCtrl,
                    decoration: const InputDecoration(labelText: 'Data di Nascita (DD/MM/YYYY) *'),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                  TextField(
                    controller: cfCtrl,
                    decoration: const InputDecoration(labelText: 'Codice Fiscale'),
                  ),
                  Row(
                    children: [
                      const Text('Sesso: '),
                      GestureDetector(
                        onTap: () => setDialogState(() {
                          gender = 'M';
                          undertakingAccepted = false;
                        }),
                        child: Row(
                          children: [
                            Icon(gender == 'M' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: const Color(0xFF1B3B6F), size: 20),
                            const Text(' M'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () => setDialogState(() => gender = 'F'),
                        child: Row(
                          children: [
                            Icon(gender == 'F' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: const Color(0xFF1B3B6F), size: 20),
                            const Text(' F'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (gender == 'F' && age >= 18) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'UNDERTAKING FOR FEMALE (> 18 YRS)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.red),
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'I declare that this female member is UNMARRIED and UNEMPLOYED (Does not have a job).',
                              style: TextStyle(fontSize: 11),
                            ),
                            value: undertakingAccepted,
                            onChanged: (val) => setDialogState(() => undertakingAccepted = val!),
                          ),
                        ],
                      ),
                    ),
                  ],
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefono')),
                  TextField(controller: passportCtrl, decoration: const InputDecoration(labelText: 'Passaporto')),
                  TextField(controller: cittadinanzaCtrl, decoration: const InputDecoration(labelText: 'Cittadinanza')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty || dobCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter Name and Date of Birth')),
                    );
                    return;
                  }

                  if (gender == 'M' && age >= 18) {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Registration Restricted'),
                        content: const Text(
                          'Male members aged 18 or above CANNOT be added under the Family Plan.\n\n'
                              'They must register for an independent Single Membership.',
                        ),
                        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
                      ),
                    );
                    return;
                  }

                  if (gender == 'F' && age >= 18 && !undertakingAccepted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please accept the undertaking for unmarried & unemployed status.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _familyMembers.add({
                      'fullName': nameCtrl.text.trim(),
                      'dob': dobCtrl.text.trim(),
                      'fiscalCode': cfCtrl.text.trim(),
                      'gender': gender,
                      'phone': phoneCtrl.text.trim(),
                      'passport': passportCtrl.text.trim(),
                      'cittadinanza': cittadinanzaCtrl.text.trim(),
                      'undertakingAccepted': undertakingAccepted,
                      'age': age,
                    });
                    _membershipType = 'Family';
                    _annualFee = 120.0;
                  });

                  _saveDraftLocally();
                  Navigator.pop(ctx);
                },
                child: const Text('Add Member'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _removeFamilyMember(int index) {
    setState(() {
      _familyMembers.removeAt(index);
      if (_familyMembers.isEmpty) {
        _membershipType = 'Single';
        _annualFee = 60.0;
      }
    });
    _saveDraftLocally();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedRules) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the ACP Rules & Regulations to proceed.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 🖊️ CHECK SIGNATURE VALIDATION
    if (_sigController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide your digital signature before submitting! 🖊️'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String? photoUrl = await _uploadFile(_profilePhotoFile, 'profile_photo');
      final String? cartaFrontUrl = await _uploadFile(_docCartaFrontFile, 'carta_identita_front');
      final String? cartaBackUrl = await _uploadFile(_docCartaBackFile, 'carta_identita_back');
      final String? pakIdFrontUrl = await _uploadFile(_docPakIdFrontFile, 'pak_id_front');
      final String? pakIdBackUrl = await _uploadFile(_docPakIdBackFile, 'pak_id_back');
      final String? permessoFrontUrl = _isItalianCitizen ? null : await _uploadFile(_docPermessoFrontFile, 'permesso_front');
      final String? permessoBackUrl = _isItalianCitizen ? null : await _uploadFile(_docPermessoBackFile, 'permesso_back');
      final String? passaportoUrl = await _uploadFile(_docPassaportoFile, 'passaporto');
      final String? cfUrl = await _uploadFile(_docCodiceFiscaleFile, 'codice_fiscale');

      final String? base64Signature = await _getSignatureBase64();
      final bool hasDocumentsAttached = cartaFrontUrl != null || passaportoUrl != null || cfUrl != null || pakIdFrontUrl != null;

      final String uniquePassword = _generateRandomPassword();
      final String generatedNPratica = _nPraticaController.text.trim();

      final bool isFamilyMember = _membershipType == 'Family' || _familyMembers.isNotEmpty;
      final bool isNewUser = !_isRenewal;

      final Map<String, dynamic> formData = {
        'nPratica': generatedNPratica,
        'password': uniquePassword,
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'dob': _dobController.text.trim(),
        'fiscalCode': _fiscalCodeController.text.trim().toUpperCase(),
        'gender': _gender,
        'phone': _phoneController.text.trim(),
        'passport': _passportController.text.trim(),
        'idCard': _idCardController.text.trim(),
        'permessoSoggiornoText': _isItalianCitizen ? 'N/A (Italian Citizen)' : _permessoController.text.trim(),
        'cittadinanza': _cittadinanzaController.text.trim(),
        'phonePakistan': _pakPhoneController.text.trim(),
        'addressItaly': _italyAddressController.text.trim(),
        'comuneProvincia': _comuneProvinciaController.text.trim(),
        'addressPakistan': _pakAddressController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'membershipType': _membershipType,
        'annualFee': _annualFee,
        'registrationFee': _registrationFee,
        'totalFee': _totalFee,
        'isRenewal': _isRenewal,
        'isNewMember': isNewUser,
        'isFamily': isFamilyMember,
        'rulesAccepted': _acceptedRules,
        'familyMembers': _familyMembers,
        'hasDocumentsAttached': hasDocumentsAttached,
        'signatureBase64': base64Signature,
        'photoUrl': photoUrl ?? '',

        // Direct Root Level Links (Front / Back)
        'cartaIdentitaFront': cartaFrontUrl ?? '',
        'cartaIdentitaBack': cartaBackUrl ?? '',
        'pakIdCardFront': pakIdFrontUrl ?? '',
        'pakIdCardBack': pakIdBackUrl ?? '',
        'permessoSoggiornoFront': permessoFrontUrl ?? '',
        'permessoSoggiornoBack': permessoBackUrl ?? '',
        'passaporto': passaportoUrl ?? '',
        'codiceFiscale': cfUrl ?? '',

        'documentUrls': <String, dynamic>{
          'cartaIdentitaFront': cartaFrontUrl ?? '',
          'cartaIdentitaBack': cartaBackUrl ?? '',
          'pakIdCardFront': pakIdFrontUrl ?? '',
          'pakIdCardBack': pakIdBackUrl ?? '',
          'permessoSoggiornoFront': permessoFrontUrl ?? '',
          'permessoSoggiornoBack': permessoBackUrl ?? '',
          'passaporto': passaportoUrl ?? '',
          'codiceFiscale': cfUrl ?? '',
          'altro': _docAltroController.text.trim(),
        },
        'status': 'Pending Approval',
        'paymentStatus': 'Pending Payment',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('members').add(formData);

      await _saveNPraticaForLogin(generatedNPratica);
      await _clearDraft();

      if (!mounted) return;

      final NavigatorState nav = Navigator.of(context);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('🔐 Save Your Login Credentials'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your registration request is submitted!\n\nYour Login Details:'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText('• N. Pratica: $generatedNPratica', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    SelectableText('• Password: $uniquePassword', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text('Note: Your N. Pratica is saved automatically on this device for future logins.', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3B6F), foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                nav.pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      memberName: _fullNameController.text,
                      praticaNumber: generatedNPratica,
                      amount: _totalFee,
                      registrationData: formData,
                    ),
                  ),
                );
              },
              child: const Text('Continue to Payment'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modulo Iscrizione (ACP)'),
        backgroundColor: const Color(0xFF1B3B6F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          onChanged: _saveDraftLocally,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'MODULO ISCRIZIONE PER IL COMITATO FUNEBRE',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F)),
                ),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _nPraticaController,
                readOnly: true,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F)),
                decoration: InputDecoration(
                  labelText: 'N. PRATICA (Auto-Generated)',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  prefixIcon: const Icon(Icons.confirmation_number, color: Color(0xFF1B3B6F)),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  border: Border.all(color: Colors.amber.shade800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MEMBERSHIP CATEGORY & FEES',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () {
                        setState(() => _isRenewal = !_isRenewal);
                        _saveDraftLocally();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isRenewal ? const Color(0xFF1B3B6F).withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isRenewal ? const Color(0xFF1B3B6F) : Colors.grey.shade400,
                          ),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: _isRenewal,
                              activeColor: const Color(0xFF1B3B6F),
                              onChanged: (val) {
                                setState(() => _isRenewal = val ?? false);
                                _saveDraftLocally();
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Annual Renewal? (Existing Member)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B3B6F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _membershipType = 'Single';
                                _annualFee = 60.0;
                              });
                              _saveDraftLocally();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(_membershipType == 'Single' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: const Color(0xFF1B3B6F), size: 20),
                                  const SizedBox(width: 6),
                                  const Text('Single (€60/yr)', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _membershipType = 'Family';
                                _annualFee = 120.0;
                              });
                              _saveDraftLocally();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Icon(_membershipType == 'Family' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: const Color(0xFF1B3B6F), size: 20),
                                  const SizedBox(width: 6),
                                  const Text('Family (€120/yr)', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Annual Fee: €${_annualFee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                          Text(
                            '• Registration Fee: ${_isRenewal ? "€0 (Renewal Waived)" : "€20 (First Time New Member)"}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _isRenewal ? Colors.green.shade800 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'TOTAL INITIAL DUE: €${_totalFee.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F), fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'DATI DEL RICHIEDENTE / CAPOFAMIGLIA',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
              const Divider(),

              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _fiscalCodeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Codice Fiscale *',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    suffixIcon: _isCheckingDb
                        ? const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    _checkExistingMember(val);
                    _saveDraftLocally();
                  },
                ),
              ),

              if (_isRenewal && _detectedMemberInfo != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$_detectedMemberInfo\nAnnual Renewal Mode Activated (€0 Reg Fee)',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),

              _buildTextField(_fullNameController, 'Nome e Cognome *', required: true),

              _buildTextField(
                _emailController,
                'Indirizzo Email *',
                required: true,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              _buildTextField(_dobController, 'Data di nascita (DD/MM/YYYY)'),

              Row(
                children: [
                  const Text('Sesso: '),
                  GestureDetector(
                    onTap: () {
                      setState(() => _gender = 'M');
                      _saveDraftLocally();
                    },
                    child: Row(
                      children: [
                        Icon(_gender == 'M' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: const Color(0xFF1B3B6F), size: 20),
                        const Text(' M'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      setState(() => _gender = 'F');
                      _saveDraftLocally();
                    },
                    child: Row(
                      children: [
                        Icon(_gender == 'F' ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: const Color(0xFF1B3B6F), size: 20),
                        const Text(' F'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTextField(_phoneController, 'Numero di telefono *', required: true, keyboardType: TextInputType.phone),
              _buildTextField(_passportController, 'Numero passaporto'),
              _buildTextField(_idCardController, 'Carta d\'identità'),

              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: TextFormField(
                  controller: _cittadinanzaController,
                  decoration: const InputDecoration(
                    labelText: 'Cittadinanza (e.g. Italiana, Pakistana)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) {
                    setState(() {});
                    _saveDraftLocally();
                  },
                ),
              ),

              if (!_isItalianCitizen) _buildTextField(_permessoController, 'Permesso di soggiorno'),

              _buildTextField(_pakPhoneController, 'Telefono in Pakistan', keyboardType: TextInputType.phone),
              _buildTextField(_italyAddressController, 'Indirizzo in Italia'),
              _buildTextField(_comuneProvinciaController, 'Comune / Provincia'),
              _buildTextField(_pakAddressController, 'Indirizzo in Pakistan'),
              _buildTextField(_fatherNameController, 'Nome del Padre'),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('DATI DEI FAMILIARI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                  ElevatedButton.icon(
                    onPressed: _addFamilyMemberDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Member'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3B6F), foregroundColor: Colors.white),
                  ),
                ],
              ),
              const Divider(),

              ..._familyMembers.asMap().entries.map((entry) {
                int idx = entry.key;
                var member = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text('${member['fullName']} (${member['gender']})'),
                    subtitle: Text(
                      'DOB: ${member['dob']} | Age: ${member['age']} yrs'
                          '${member['undertakingAccepted'] == true ? '\nUndertaking Accepted ✅' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFamilyMember(idx),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 25),

              const Text('DOCUMENTI ALLEGATI (SCAN FRONT / BACK)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const Text('Scan or attach clear front and back copies.', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Divider(),

              // 🖼️ PROFILE PHOTO
              _buildFileTile('Foto Tessera / Profile Photo', _profilePhotoFile, () {
                _pickProfilePhoto();
              }),

              // 🪪 CARTA D'IDENTITÀ (FRONT & BACK)
              _buildFileTile('Carta d\'Identità (Front)', _docCartaFrontFile, () {
                _showDocumentOptionModal('Carta d\'Identità (Front)', (file) => setState(() => _docCartaFrontFile = file));
              }),
              _buildFileTile('Carta d\'Identità (Back)', _docCartaBackFile, () {
                _showDocumentOptionModal('Carta d\'Identità (Back)', (file) => setState(() => _docCartaBackFile = file));
              }),

              // 🇵🇰 PAK ID CARD (FRONT & BACK)
              _buildFileTile('Pakistan ID Card - CNIC (Front)', _docPakIdFrontFile, () {
                _showDocumentOptionModal('Pakistan ID Card (Front)', (file) => setState(() => _docPakIdFrontFile = file));
              }),
              _buildFileTile('Pakistan ID Card - CNIC (Back)', _docPakIdBackFile, () {
                _showDocumentOptionModal('Pakistan ID Card (Back)', (file) => setState(() => _docPakIdBackFile = file));
              }),

              // 🛂 PERMESSO DI SOGGIORNO (FRONT & BACK)
              if (!_isItalianCitizen) ...[
                _buildFileTile('Permesso di Soggiorno (Front)', _docPermessoFrontFile, () {
                  _showDocumentOptionModal('Permesso di Soggiorno (Front)', (file) => setState(() => _docPermessoFrontFile = file));
                }),
                _buildFileTile('Permesso di Soggiorno (Back)', _docPermessoBackFile, () {
                  _showDocumentOptionModal('Permesso di Soggiorno (Back)', (file) => setState(() => _docPermessoBackFile = file));
                }),
              ] else
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Permesso di Soggiorno exempted for Italian Citizens ✅',
                        style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

              // 📖 PASSAPORTO & CODICE FISCALE
              _buildFileTile('Copia Passaporto (Main Page)', _docPassaportoFile, () {
                _showDocumentOptionModal('Passaporto', (file) => setState(() => _docPassaportoFile = file));
              }),
              _buildFileTile('Codice Fiscale Card', _docCodiceFiscaleFile, () {
                _showDocumentOptionModal('Codice Fiscale', (file) => setState(() => _docCodiceFiscaleFile = file));
              }),

              const SizedBox(height: 10),
              _buildTextField(_docAltroController, 'Altro (Specify details)'),

              const SizedBox(height: 20),

              // RULES ACCEPTANCE CHECKBOX
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: CheckboxListTile(
                  value: _acceptedRules,
                  activeColor: const Color(0xFF1B3B6F),
                  title: const Text(
                    'Ho letto e accetto le regole del Benefit Committee (ACP) *',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F)),
                  ),
                  subtitle: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RulesAndRegulationsScreen()),
                      );
                    },
                    child: const Text(
                      'Click here to read full 20 Rules & Regulations (Urdu/IT/EN) 📖',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 11),
                    ),
                  ),
                  onChanged: (val) => setState(() => _acceptedRules = val!),
                ),
              ),

              const SizedBox(height: 20),

              // 🖊️ DIGITAL SIGNATURE CANVAS SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Firma del Richiedente (Digital Signature) *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1B3B6F)),
                  ),
                  TextButton.icon(
                    onPressed: () => _sigController.clear(),
                    icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                    label: const Text('Clear Sign', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1B3B6F), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Signature(
                    controller: _sigController,
                    height: 140,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Please sign inside the white box using your finger or stylus.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B3B6F)),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Proceed to Payment (€${_totalFee.toStringAsFixed(0)})', style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTile(String title, File? file, VoidCallback onPick) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: file != null ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: file != null ? Colors.green : Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: file != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(file, width: 45, height: 45, fit: BoxFit.cover),
        )
            : const Icon(Icons.document_scanner, color: Color(0xFF1B3B6F)),
        title: Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
        subtitle: Text(
          file != null ? 'Attached ✅' : 'No file selected',
          style: TextStyle(color: file != null ? Colors.green : Colors.grey, fontSize: 11),
        ),
        trailing: ElevatedButton.icon(
          onPressed: onPick,
          icon: Icon(file != null ? Icons.refresh : Icons.camera_alt, size: 14),
          label: Text(file != null ? 'Rescan' : 'Scan / Attach', style: const TextStyle(fontSize: 11)),
          style: ElevatedButton.styleFrom(
            backgroundColor: file != null ? Colors.green : const Color(0xFF1B3B6F),
            foregroundColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool required = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: validator ??
                (value) {
              if (required && (value == null || value.trim().isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
        onChanged: (_) => _saveDraftLocally(),
      ),
    );
  }
}