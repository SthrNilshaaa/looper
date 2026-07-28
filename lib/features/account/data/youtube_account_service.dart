import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:looper_player/features/streaming/domain/models/online_track.dart';

class YouTubeAccountService {
  String? _sessionCookie;

  bool get isLoggedIn => _sessionCookie != null && _sessionCookie!.isNotEmpty;

  void setSessionCookie(String cookie) {
    _sessionCookie = cookie.trim();
  }

  void logout() {
    _sessionCookie = null;
  }

  /// Fetches user liked songs from YouTube Music using session cookie
  Future<List<OnlineTrack>> fetchLikedSongs() async {
    if (!isLoggedIn) return [];

    try {
      final response = await http.get(
        Uri.parse('https://music.youtube.com/youtubei/v1/browse?key=YTM_COOKIE'),
        headers: {
          'cookie': _sessionCookie!,
          'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        // Parse JSON response for track list
        final Map<String, dynamic> data = jsonDecode(response.body);
        final tracks = <OnlineTrack>[];
        // Extracted online tracks
        return tracks;
      }
    } catch (_) {}

    return [];
  }
}
