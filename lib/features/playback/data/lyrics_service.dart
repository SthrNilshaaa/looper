import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsResponse {
  final String? lyrics;
  final bool? instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsResponse({this.lyrics, this.instrumental, this.plainLyrics, this.syncedLyrics});

  factory LyricsResponse.fromJson(Map<String, dynamic> json) {
    return LyricsResponse(
      lyrics: json['lyrics']?.toString(),
      instrumental: json['instrumental'] as bool?,
      plainLyrics: json['plainLyrics']?.toString(),
      syncedLyrics: json['syncedLyrics']?.toString(),
    );
  }
}

class LyricsService {
  static const String baseUrl = 'https://lrclib.net/api';

  Future<LyricsResponse?> getLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int durationSeconds,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/get').replace(queryParameters: {
        'track_name': trackName,
        'artist_name': artistName,
        'album_name': albumName,
        'duration': durationSeconds.toString(),
      });

      final response = await http.get(url);
      if (response.statusCode == 200) {
        return LyricsResponse.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
    }
    return null;
  }
}
