import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  String _currentLanguage = 'it'; // Default: Italian ('it', 'ur', 'en')

  String get currentLanguage => _currentLanguage;

  LanguageService() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('app_language') ?? 'it';
    notifyListeners();
  }

  Future<void> changeLanguage(String langCode) async {
    _currentLanguage = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', langCode);
    notifyListeners();
  }

  // 📖 TRANSLATION DICTIONARY
  static const Map<String, Map<String, String>> _localizedValues = {
    'it': {
      'app_title': 'ACP Vicenza',
      'chi_siamo': 'Chi Siamo',
      'contattaci': 'Contattaci',
      'digital_card': 'Tessera Digitale',
      'status_paid': 'Pagato',
      'status_pending': 'In Attesa',
      'select_language': 'Seleziona Lingua',
      'rules_policy': 'Regolamento e Privacy',
    },
    'ur': {
      'app_title': 'اے سی پی وینسیا',
      'chi_siamo': 'ہمارے بارے میں',
      'contattaci': 'ہم سے رابطہ کریں',
      'digital_card': 'ڈیجیٹل ممبرشپ کارڈ',
      'status_paid': 'ادائیگی ہو گئی',
      'status_pending': 'ادائیگی واجب الادا',
      'select_language': 'زبان منتخب کریں',
      'rules_policy': 'قوانین و ضوابط',
    },
    'en': {
      'app_title': 'ACP Vicenza',
      'chi_siamo': 'About Us',
      'contattaci': 'Contact Us',
      'digital_card': 'Digital Membership Card',
      'status_paid': 'Paid',
      'status_pending': 'Pending Payment',
      'select_language': 'Select Language',
      'rules_policy': 'Rules & Privacy',
    },
  };

  String getText(String key) {
    return _localizedValues[_currentLanguage]?[key] ?? _localizedValues['it']![key] ?? key;
  }
}