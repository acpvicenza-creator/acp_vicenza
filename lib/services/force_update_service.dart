import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateService {
  // Current app build version (pubspec.yaml ka build number e.g. 1)
  static const int currentInstalledBuildNumber = 1;

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('version_info')
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final int minRequiredBuild = data['minRequiredBuild'] ?? 1;
      final String playStoreUrl = data['playStoreUrl'] ?? '';
      final String appStoreUrl = data['appStoreUrl'] ?? '';
      final String updateMessage = data['updateMessage'] ??
          'A new version of ACP Vicenza is available. Please update to continue using the app.';

      if (currentInstalledBuildNumber < minRequiredBuild) {
        if (context.mounted) {
          _showUpdateDialog(context, updateMessage, playStoreUrl, appStoreUrl);
        }
      }
    } catch (e) {
      debugPrint("Force Update Check Error: $e");
    }
  }

  static void _showUpdateDialog(
      BuildContext context,
      String message,
      String playStoreUrl,
      String appStoreUrl,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false, // User dialog band nahi kar sakta
      builder: (ctx) => PopScope(
        canPop: false, // Back button disabled
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.system_update, color: Color(0xFF1B3B6F), size: 28),
              SizedBox(width: 10),
              Text('Update Required', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3B6F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final TargetPlatform platform = Theme.of(context).platform;
                  final String url = platform == TargetPlatform.iOS ? appStoreUrl : playStoreUrl;

                  if (url.isNotEmpty && await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Update Now', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}