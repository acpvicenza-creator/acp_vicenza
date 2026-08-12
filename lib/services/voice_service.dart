import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, String langCode) async {
    await _tts.stop();

    // Map App Language Code to TTS Accent
    String ttsLang = 'it-IT';
    if (langCode == 'ur') {
      ttsLang = 'ur-PK';
    } else if (langCode == 'en') {
      ttsLang = 'en-US';
    }

    await _tts.setLanguage(ttsLang);
    await _tts.setSpeechRate(0.45); // Comfortable reading speed
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}