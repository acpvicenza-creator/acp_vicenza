import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/audit_log_service.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Fallback credentials for Super Admin
  final String _masterEmail = "admin@acp.com";
  final String _masterPassword = "Admin2026acp@";

  String? _errorMessage;
  bool _obscureText = true;
  bool _isLoading = false;

  Future<void> _verifyLogin() async {
    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    bool isAuthorized = false;
    String adminRole = 'Admin';

    try {
      // 1. DIRECT FAST PATH FOR MASTER ADMIN (NO WAITING FOR NETWORK)
      if (email == _masterEmail && password == _masterPassword) {
        isAuthorized = true;
        adminRole = 'Super Admin';
      } else {
        // 2. CHECK FIRESTORE FOR OTHER CREATED ADMINS WITH TIMEOUT
        try {
          final adminQuery = await FirebaseFirestore.instance
              .collection('admins')
              .where('email', isEqualTo: email)
              .get()
              .timeout(const Duration(seconds: 4));

          if (adminQuery.docs.isNotEmpty) {
            final adminData = adminQuery.docs.first.data();
            final storedPassword = adminData['password'] ?? '';
            final bool isActive = adminData['isActive'] ?? true;

            if (storedPassword == password && isActive) {
              isAuthorized = true;
              adminRole = adminData['role'] ?? 'Admin';
            }
          }
        } catch (dbError) {
          debugPrint("Firestore query timeout/error: $dbError");
        }
      }

      if (!mounted) return;

      if (isAuthorized) {
        // NON-BLOCKING AUDIT LOG FIRE-AND-FORGET
        AuditLogService.logAction(
          actionTitle: 'Admin Logged In',
          details: 'Admin ($email) logged into Dashboard as $adminRole',
        ).catchError((_) {});

        // INSTANT NAVIGATION
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid Email or Password! Access Denied.';
          _isLoading = false;
        });
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed: ${e.toString()}';
          _isLoading = false;
        });
      }
    } finally {
      if (mounted && !isAuthorized) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF1B3B6F);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Access'),
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.admin_panel_settings, size: 80, color: darkBlue),
              const SizedBox(height: 20),
              const Text(
                'ACP Multi-Admin Portal',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkBlue),
              ),
              const SizedBox(height: 25),

              // EMAIL FIELD
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Admin Email',
                  hintText: 'admin@acp.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: darkBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // PASSWORD FIELD
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  errorText: _errorMessage,
                  prefixIcon: const Icon(Icons.lock_outline, color: darkBlue),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onSubmitted: (_) => _verifyLogin(),
              ),
              const SizedBox(height: 25),

              // LOGIN BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _verifyLogin,
                child: _isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : const Text('Login to Dashboard', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}