import 'package:flutter/material.dart';

enum AppThemeType {
  classicGreen, // Default ACP Dark Green
  royalBlue,    // Deep Royal Navy Blue
  darkGold,     // Luxury Dark & Gold
  burgundy,     // Elegant Deep Burgundy
}

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