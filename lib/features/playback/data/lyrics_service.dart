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
      // First try the exact /get endpoint
      final getParams = {
        'track_name': trackName,
        'artist_name': artistName,
        if (albumName.isNotEmpty) 'album_name': albumName,
        if (durationSeconds > 0) 'duration': durationSeconds.toString(),
      };

      var url = Uri.parse('$baseUrl/get').replace(queryParameters: getParams);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        return LyricsResponse.fromJson(jsonDecode(response.body));
      }

      // If exact match fails, try the /search endpoint and take the first valid result
      final searchParams = {
        'q': '$trackName $artistName',
      };

      url = Uri.parse('$baseUrl/search').replace(queryParameters: searchParams);
      response = await http.get(url);

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        if (list.isNotEmpty) {
           return LyricsResponse.fromJson(list.first);
        }
      }
    } catch (e) {
      print('Error fetching lyrics: $e');
    }
    return null;
  }
}
