import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class PrayerService {
  // 🕌 Mawaqit Mosque Slug for Faizan-e-Madina Vicenza (ACP)
  static const String mawaqitUrl =
      'https://mawaqit.net/it/faizan-e-madina-vicenza-acp-36100-vicenza-italy';

  // 📍 Vicenza Fallback Coordinates (Hanafi Calculation)
  static const double _latitude = 45.5455;
  static const double _longitude = 11.5354;

  // 🌐 FETCH LIVE TIMINGS FROM MAWAQIT
  static Future<Map<String, String>> getMawaqitPrayerTimes() async {
    try {
      final response = await http.get(
        Uri.parse(mawaqitUrl),
        headers: {
          'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
        },
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final body = response.body;

        // Extract ConfData or JSON prayer times from Mawaqit HTML script
        final match = RegExp(r'var\s+confData\s*=\s*(\{.*?\});', dotAll: true)
            .firstMatch(body);

        if (match != null) {
          final jsonStr = match.group(1);
          if (jsonStr != null) {
            final Map<String, dynamic> data = jsonDecode(jsonStr);
            final times = data['times'] as List<dynamic>?;
            final jumua = data['jumua']?.toString() ?? '13:35';
            final shuruq = data['shuruq']?.toString() ?? '';

            if (times != null && times.length >= 5) {
              return {
                'Fajr': times[0].toString(),
                'Sunrise': shuruq.isNotEmpty ? shuruq : '06:00',
                'Dhuhr': times[1].toString(),
                'Asr': times[2].toString(),
                'Maghrib': times[3].toString(),
                'Isha': times[4].toString(),
                'Jumuah': jumua,
                'Source': 'Faizan-e-Madina (Mawaqit Live)',
              };
            }
          }
        }
      }
    } catch (e) {
      // If offline or network error, fallback to calculation
    }

    // 🔄 Offline Fallback (Adhan Hanafi Calculation)
    return getOfflineHanafiTimes();
  }

  // 🕋 OFFLINE HANAFI FALLBACK
  static Map<String, String> getOfflineHanafiTimes() {
    final coordinates = Coordinates(_latitude, _longitude);
    final now = DateTime.now();
    final dateComponents = DateComponents.from(now);

    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.hanafi;

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);
    final timeFormat = DateFormat('HH:mm');

    return {
      'Fajr': timeFormat.format(prayerTimes.fajr),
      'Sunrise': timeFormat.format(prayerTimes.sunrise),
      'Dhuhr': timeFormat.format(prayerTimes.dhuhr),
      'Asr': timeFormat.format(prayerTimes.asr),
      'Maghrib': timeFormat.format(prayerTimes.maghrib),
      'Isha': timeFormat.format(prayerTimes.isha),
      'Jumuah': '13:35',
      'Source': 'Vicenza Hanafi (Calculation)',
    };
  }
}