import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'member_dashboard_screen.dart';
import 'register_member_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierCtrl = TextEditingController(); // N. Pratica or Codice Fiscale
  final _passwordCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedNPratica();
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // Auto-fill saved N. Pratica from device local storage
  Future<void> _loadSavedNPratica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPratica = prefs.getString('saved_n_pratica');
      if (savedPratica != null && savedPratica.isNotEmpty) {
        setState(() {
          _identifierCtrl.text = savedPratica;
        });
      }
    } catch (_) {}
  }

  Future<void> _savePraticaLocally(String nPratica) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_n_pratica', nPratica);
    } catch (_) {}
  }

  // 🔐 MEMBER LOGIN VERIFICATION
  Future<void> _loginMember() async {
    final identifier = _identifierCtrl.text.trim().toUpperCase();
    final password = _passwordCtrl.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both N. Pratica/Codice Fiscale and Password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Search by N. Pratica
      var memberQuery = await FirebaseFirestore.instance
          .collection('members')
          .where('nPratica', isEqualTo: identifier)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();

      // 2. If not found, search by Codice Fiscale
      if (memberQuery.docs.isEmpty) {
        memberQuery = await FirebaseFirestore.instance
            .collection('members')
            .where('fiscalCode', isEqualTo: identifier)
            .where('password', isEqualTo: password)
            .limit(1)
            .get();
      }

      if (!mounted) return;

      if (memberQuery.docs.isNotEmpty) {
        final memberDoc = memberQuery.docs.first;
        final memberData = memberDoc.data();
        final String nPratica = memberData['nPratica'] ?? identifier;

        await _savePraticaLocally(nPratica);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MemberDashboardScreen(memberDocId: memberDoc.id),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid credentials. Please check your N. Pratica / Password.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 🔑 RECOVER FORGOTTEN PASSWORD MODAL
  void _openForgotPasswordDialog() {
    final recoverCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Password Recovery', style: TextStyle(color: Color(0xFF043927))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your registered Codice Fiscale or Phone Number to recover password:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: recoverCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Codice Fiscale / Phone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_search),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF043927),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final queryText = recoverCtrl.text.trim().toUpperCase();
                if (queryText.isEmpty) return;

                final messenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(dialogCtx);

                try {
                  var res = await FirebaseFirestore.instance
                      .collection('members')
                      .where('fiscalCode', isEqualTo: queryText)
                      .limit(1)
                      .get();

                  if (res.docs.isEmpty) {
                    res = await FirebaseFirestore.instance
                        .collection('members')
                        .where('phone', isEqualTo: recoverCtrl.text.trim())
                        .limit(1)
                        .get();
                  }

                  nav.pop();

                  if (res.docs.isNotEmpty) {
                    final data = res.docs.first.data();
                    final pass = data['password'] ?? 'Not Set';
                    final nPra = data['nPratica'] ?? 'N/A';

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('Account Found! N. Pratica: $nPra | Password: $pass'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 8),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('No registered member found with these details.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Recover Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Member Login'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),

            // ICON / BADGE
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: darkGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_pin_circle_outlined, size: 64, color: darkGreen),
            ),
            const SizedBox(height: 12),

            const Text(
              'ACP VICENZA',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: darkGreen,
                letterSpacing: 0.8,
              ),
            ),
            const Text(
              'Enter your N. Pratica & password to manage your membership',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // ERROR MESSAGE BOX
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // IDENTIFIER FIELD (N. PRATICA OR CF)
            TextField(
              controller: _identifierCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'N. Pratica or Codice Fiscale *',
                hintText: 'e.g. ACP-2026-1001 or MRORSI80A...',
                prefixIcon: const Icon(Icons.badge_outlined, color: darkGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 14),

            // PASSWORD FIELD
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password *',
                prefixIcon: const Icon(Icons.lock_outline, color: darkGreen),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            // FORGOT PASSWORD LINK
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _openForgotPasswordDialog,
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _loginMember,
                icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.login),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login to Member Portal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 25),
            const Divider(),

            // REGISTER NEW MEMBER BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have a membership yet?", style: TextStyle(fontSize: 13, color: Colors.black54)),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterMemberScreen()),
                    );
                  },
                  child: const Text(
                    'Register Now',
                    style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}