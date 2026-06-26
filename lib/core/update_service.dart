import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:looper_player/core/providers.dart';

import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const repoUrl = 'https://api.github.com/repos/SthrNilshaaa/looper/releases/latest';
  static const fallbackHtmlUrl = 'https://github.com/SthrNilshaaa/looper/releases';

  static Future<void> checkForUpdates() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(repoUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String tagName = data['tag_name'] ?? '';
        final String htmlUrl = data['html_url'] ?? fallbackHtmlUrl;
        
        if (tagName.isNotEmpty && _isUpdateAvailable(currentVersion, tagName)) {
          _showUpdateSnackbar(tagName, htmlUrl);
        }
      }
    } catch (e) {

    }
  }

  static bool _isUpdateAvailable(String current, String latest) {
    String cleanCurrent = current.replaceAll(RegExp(r'[^0-9.]'), '');
    String cleanLatest = latest.replaceAll(RegExp(r'[^0-9.]'), '');

    List<int> currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> latestParts = cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    int maxLength = currentParts.length > latestParts.length ? currentParts.length : latestParts.length;
    while (currentParts.length < maxLength) {
      currentParts.add(0);
    }
    while (latestParts.length < maxLength) {
      latestParts.add(0);
    }

    for (int i = 0; i < maxLength; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  static void _showUpdateSnackbar(String newVersion, String htmlUrl) {
    final state = scaffoldMessengerKey.currentState;
    if (state == null) return;

    state.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 10),
        content: Row(
          children: [
            const Icon(Icons.system_update_alt, color: Color(0xFF41C25E)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Available!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Version $newVersion is available on GitHub.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'VISIT',
          textColor: const Color(0xFF41C25E),
          onPressed: () async {
            final Uri uri = Uri.parse(htmlUrl);
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (e) {

            }
          },
        ),
      ),
    );
  }
}
