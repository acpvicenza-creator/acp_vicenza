import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';

// 🎨 GLOBAL THEME MODEL & PALETTES
class AppTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;

  AppTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
  });

  static final Map<String, AppTheme> themes = {
    'classicGreen': AppTheme(
      id: 'classicGreen',
      name: 'Classic Emerald (Default)',
      primaryColor: const Color(0xFF043927),
      secondaryColor: const Color(0xFF0C5A32),
      accentColor: const Color(0xFFFFC107),
      backgroundColor: const Color(0xFFF4F7F5),
      cardColor: Colors.white,
    ),
    'royalBlue': AppTheme(
      id: 'royalBlue',
      name: 'Royal Navy Blue',
      primaryColor: const Color(0xFF0F2A4A),
      secondaryColor: const Color(0xFF1B3B6F),
      accentColor: const Color(0xFF4A90E2),
      backgroundColor: const Color(0xFFF0F4F8),
      cardColor: Colors.white,
    ),
    'darkGold': AppTheme(
      id: 'darkGold',
      name: 'Black & Gold Luxury',
      primaryColor: const Color(0xFF121212),
      secondaryColor: const Color(0xFF1E1E1E),
      accentColor: const Color(0xFFFFD700),
      backgroundColor: const Color(0xFF181818),
      cardColor: const Color(0xFF242424),
    ),
    'burgundy': AppTheme(
      id: 'burgundy',
      name: 'Imperial Burgundy',
      primaryColor: const Color(0xFF4A0E17),
      secondaryColor: const Color(0xFF721C24),
      accentColor: const Color(0xFFE5A93C),
      backgroundColor: const Color(0xFFF9F4F5),
      cardColor: Colors.white,
    ),
  };

  static AppTheme getTheme(String? themeId) {
    return themes[themeId] ?? themes['classicGreen']!;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. SAFE MULTI-PLATFORM FIREBASE INITIALIZATION
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyYOUR_API_KEY_HERE",
          authDomain: "your-app.firebaseapp.com",
          projectId: "your-app-id",
          storageBucket: "your-app.appspot.com",
          messagingSenderId: "123456789",
          appId: "1:123456789:web:abcdef",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
  } catch (e) {
    debugPrint("Firebase Init Error: $e");
  }

  // 2. LIVE STRIPE INITIALIZATION
  try {
    Stripe.publishableKey =
    "pk_live_51TPdSBRucgcMTB3UOw16Q8eZG7Suf21qJnoePDHsAuUdZVu0Zf039zvIBdYxMsQdIgwFq1nObeaR7geKVQmsz2II00NL6b1moJ";
    await Stripe.instance.applySettings();
  } catch (e) {
    debugPrint("Stripe Init Error: $e");
  }

  // 3. NON-BLOCKING BACKGROUND NOTIFICATION SERVICE
  NotificationService.initialize().catchError((e) {
    debugPrint("Notification Service Background Init Error: $e");
  });

  runApp(const ACPVicenzaApp());
}

class ACPVicenzaApp extends StatelessWidget {
  const ACPVicenzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔴 DYNAMIC THEME STREAM (Controlled by Admin via Firestore)
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('app_settings')
          .doc('theme_config')
          .snapshots(),
      builder: (context, snapshot) {
        String activeThemeId = 'classicGreen';
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          activeThemeId = data?['activeTheme'] ?? 'classicGreen';
        }

        final currentTheme = AppTheme.getTheme(activeThemeId);

        return MaterialApp(
          title: 'ACP Vicenza',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: currentTheme.primaryColor,
            scaffoldBackgroundColor: currentTheme.backgroundColor,
            cardColor: currentTheme.cardColor,
            appBarTheme: AppBarTheme(
              backgroundColor: currentTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: currentTheme.primaryColor,
              primary: currentTheme.primaryColor,
              secondary: currentTheme.accentColor,
              surface: currentTheme.cardColor,
            ),
          ),
          home: const WelcomeScreen(),
        );
      },
    );
  }
}

// 🏛️ BANK / IBAN DETAILS HELPER CLASS (For Bonifico Bancario)
class BankDetails {
  static const String accountTitle = "Comunita Pakistana Di Vicenza";
  static const String iban = "IT42 H060 4511 8000 0000 5006 673";

  // 📲 BottomSheet Modal to show IBAN for Bonifico
  static void showIBANBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bonifico Bancario (IBAN)',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B3B6F)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text('Intestatario (Account Name):',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SelectableText(
                accountTitle,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 14),
              const Text('IBAN:',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SelectableText(
                        iban,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF043927),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Color(0xFF043927)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: iban));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('IBAN copied to clipboard!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Causale (Payment Reason):',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const Text('Quota Associativa ACP - [Il tuo Nome]',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}