import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  // 📍 Vicenza, Italy Coordinates
  static const double _latitude = 45.5455;
  static const double _longitude = 11.5354;

  PrayerTimes _getPrayerTimes() {
    final coordinates = Coordinates(_latitude, _longitude);
    final now = DateTime.now();
    final dateComponents = DateComponents.from(now);

    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.hanafi; // 👈 Hanafi Fiqh Asr Timing

    return PrayerTimes(coordinates, dateComponents, params);
  }

  Map<String, String> _getAutoHanafiTimes(PrayerTimes prayerTimes) {
    return {
      'Fajr': _formatTime(prayerTimes.fajr),
      'Sunrise': _formatTime(prayerTimes.sunrise),
      'Dhuhr': _formatTime(prayerTimes.dhuhr),
      'Asr': _formatTime(prayerTimes.asr),
      'Maghrib': _formatTime(prayerTimes.maghrib),
      'Isha': _formatTime(prayerTimes.isha),
    };
  }

  String _getNextPrayerName(PrayerTimes prayerTimes) {
    final next = prayerTimes.nextPrayer();
    switch (next) {
      case Prayer.fajr:
        return 'Fajr';
      case Prayer.sunrise:
        return 'Sunrise';
      case Prayer.dhuhr:
        return 'Dhuhr';
      case Prayer.asr:
        return 'Asr';
      case Prayer.maghrib:
        return 'Maghrib';
      case Prayer.isha:
        return 'Isha';
      default:
        return 'Fajr (Tomorrow)';
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);
    final hijriDate = HijriCalendar.now();
    final prayerTimes = _getPrayerTimes();
    final autoTimes = _getAutoHanafiTimes(prayerTimes);
    final nextPrayer = _getNextPrayerName(prayerTimes);
    final gregorianDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('Namaz Timings (Vicenza)'),
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('settings').doc('prayer_times').snapshots(),
        builder: (context, snapshot) {
          Map<String, dynamic>? adminTimes;
          if (snapshot.hasData && snapshot.data!.exists) {
            adminTimes = snapshot.data!.data() as Map<String, dynamic>?;
          }

          final fajr = (adminTimes?['Fajr'] ?? '').toString().isNotEmpty ? adminTimes!['Fajr'] : autoTimes['Fajr'];
          final dhuhr = (adminTimes?['Dhuhr'] ?? '').toString().isNotEmpty ? adminTimes!['Dhuhr'] : autoTimes['Dhuhr'];
          final asr = (adminTimes?['Asr'] ?? '').toString().isNotEmpty ? adminTimes!['Asr'] : autoTimes['Asr'];
          final maghrib = (adminTimes?['Maghrib'] ?? '').toString().isNotEmpty ? adminTimes!['Maghrib'] : autoTimes['Maghrib'];
          final isha = (adminTimes?['Isha'] ?? '').toString().isNotEmpty ? adminTimes!['Isha'] : autoTimes['Isha'];
          final jumuah = (adminTimes?['Jumuah'] ?? '').toString().isNotEmpty ? adminTimes!['Jumuah'] : '13:30';

          final displayTimes = [
            {'name': 'Fajr', 'time': fajr, 'icon': Icons.wb_twilight, 'isNext': nextPrayer == 'Fajr'},
            {'name': 'Sunrise', 'time': autoTimes['Sunrise'], 'icon': Icons.wb_sunny_outlined, 'isNext': nextPrayer == 'Sunrise'},
            {'name': 'Dhuhr', 'time': dhuhr, 'icon': Icons.wb_sunny, 'isNext': nextPrayer == 'Dhuhr'},
            {'name': 'Asr (Hanafi)', 'time': asr, 'icon': Icons.sunny_snowing, 'isNext': nextPrayer == 'Asr'},
            {'name': 'Maghrib', 'time': maghrib, 'icon': Icons.nights_stay_outlined, 'isNext': nextPrayer == 'Maghrib'},
            {'name': 'Isha', 'time': isha, 'icon': Icons.nights_stay, 'isNext': nextPrayer == 'Isha'},
            {'name': 'Jumuah', 'time': jumuah, 'icon': Icons.mosque, 'isNext': false},
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🌙 HIJRI & GREGORIAN DATE HEADER CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: darkGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} AH',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gregorianDate,
                      style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Vicenza, Italy • Next: $nextPrayer',
                        style: const TextStyle(fontSize: 11, color: Colors.amberAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              ...displayTimes.map((item) {
                final isJumuah = item['name'] == 'Jumuah';
                final isNext = item['isNext'] == true;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isNext
                          ? Colors.green
                          : (isJumuah ? Colors.amber.shade400 : Colors.transparent),
                      width: isNext ? 1.5 : 1.0,
                    ),
                  ),
                  elevation: isNext ? 3 : (isJumuah ? 2 : 1),
                  color: isNext
                      ? Colors.green.shade50
                      : (isJumuah ? Colors.amber.shade50 : Colors.white),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isNext
                          ? Colors.green
                          : (isJumuah ? Colors.amber.shade100 : darkGreen.withValues(alpha: 0.1)),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isNext
                            ? Colors.white
                            : (isJumuah ? Colors.amber.shade900 : darkGreen),
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          item['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isJumuah ? Colors.amber.shade900 : darkGreen,
                          ),
                        ),
                        if (isNext) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEXT',
                              style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Text(
                      item['time'] as String,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isNext
                            ? Colors.green.shade900
                            : (isJumuah ? Colors.amber.shade900 : darkGreen),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}