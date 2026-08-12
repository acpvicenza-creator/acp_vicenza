import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/prayer_service.dart';

class AutoPrayerTimesWidget extends StatelessWidget {
  const AutoPrayerTimesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    const darkGreen = Color(0xFF043927);
    final String todayDate = DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now());

    return FutureBuilder<Map<String, String>>(
      future: PrayerService.getMawaqitPrayerTimes(),
      builder: (context, snapshot) {
        final Map<String, String> prayers = snapshot.data ?? PrayerService.getOfflineHanafiTimes();
        final bool isLiveMawaqit = prayers['Source']?.contains('Mawaqit') ?? false;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.mosque, color: darkGreen, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Faizan-e-Madina Vicenza',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkGreen),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLiveMawaqit ? Colors.green.shade50 : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isLiveMawaqit ? Colors.green : Colors.amber.shade800),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLiveMawaqit ? Icons.wifi : Icons.access_time,
                            size: 11,
                            color: isLiveMawaqit ? Colors.green : Colors.amber.shade900,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLiveMawaqit ? 'Mawaqit Live' : 'Auto Vicenza',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: isLiveMawaqit ? Colors.green : Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    todayDate,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _prayerTimeColumn('Fajr', prayers['Fajr'] ?? '--:--'),
                    _prayerTimeColumn('Dhuhr', prayers['Dhuhr'] ?? '--:--'),
                    _prayerTimeColumn('Asr', prayers['Asr'] ?? '--:--'),
                    _prayerTimeColumn('Maghrib', prayers['Maghrib'] ?? '--:--'),
                    _prayerTimeColumn('Isha', prayers['Isha'] ?? '--:--'),
                    _prayerTimeColumn('Jumua', prayers['Jumuah'] ?? '13:35', isJumua: true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _prayerTimeColumn(String name, String time, {bool isJumua = false}) {
    const darkGreen = Color(0xFF043927);
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isJumua ? Colors.amber.shade900 : Colors.blueGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isJumua ? Colors.amber.shade900 : darkGreen,
          ),
        ),
      ],
    );
  }
}