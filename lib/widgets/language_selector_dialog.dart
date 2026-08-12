import 'package:flutter/material.dart';

class LanguageSelectorDialog extends StatelessWidget {
  final String currentLang;
  final Function(String) onLanguageSelected;

  const LanguageSelectorDialog({
    super.key,
    required this.currentLang,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);

    return AlertDialog(
      title: const Text('Zaban/Language/Lingua', style: TextStyle(color: darkGreen, fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangOption(context, 'Italiano 🇮🇹', 'it'),
          _buildLangOption(context, 'اردو 🇵🇰', 'ur'),
          _buildLangOption(context, 'English 🇬🇧', 'en'),
        ],
      ),
    );
  }

  Widget _buildLangOption(BuildContext context, String label, String code) {
    final isSelected = currentLang == code;
    return ListTile(
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF043927)) : null,
      onTap: () {
        onLanguageSelected(code);
        Navigator.pop(context);
      },
    );
  }
}