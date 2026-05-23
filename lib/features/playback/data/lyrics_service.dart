import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LyricsResponse {
  final String? lyrics;
  final bool? instrumental;
  final String? plainLyrics;
  final String? syncedLyrics;

  LyricsResponse({
    this.lyrics,
    this.instrumental,
    this.plainLyrics,
    this.syncedLyrics,
  });

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

  String _sanitize(String text) {
    // Remove (feat. ...), [Remastered], (Live), etc.
    return text
        .replaceAll(RegExp(r'\((feat|with|ft)\.?.*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[(feat|with|ft)\.?.*?\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\((Remastered|Live|Official|Video).*?\)', caseSensitive: false), '')
        .replaceAll(RegExp(r'\[(Remastered|Live|Official|Video).*?\]', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s{2,}', caseSensitive: false), ' ')
        .trim();
  }

  Future<LyricsResponse?> getLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int durationSeconds,
  }) async {
    final cleanTrack = _sanitize(trackName);
    final cleanArtist = _sanitize(artistName);

    try {
      // 1. Try the exact /get endpoint first
      final getParams = {
        'track_name': cleanTrack,
        'artist_name': cleanArtist,
        if (durationSeconds > 0) 'duration': durationSeconds.toString(),
      };

      var url = Uri.parse('$baseUrl/get').replace(queryParameters: getParams);
      var response = await http.get(url);

      if (response.statusCode == 200) {
        return LyricsResponse.fromJson(jsonDecode(response.body));
      }

      // 2. If exact fails, try /get with original names (just in case)
      if (cleanTrack != trackName || cleanArtist != artistName) {
        url = Uri.parse('$baseUrl/get').replace(queryParameters: {
          'track_name': trackName,
          'artist_name': artistName,
          if (durationSeconds > 0) 'duration': durationSeconds.toString(),
        });
        response = await http.get(url);
        if (response.statusCode == 200) {
          return LyricsResponse.fromJson(jsonDecode(response.body));
        }
      }

      // 3. Fallback to /search with multiple queries
      final searchQueries = [
        '$cleanArtist - $cleanTrack',
        '$artistName - $trackName',
        '$cleanTrack $cleanArtist',
        cleanTrack,
      ];

      for (final q in searchQueries) {
        debugPrint('🔍 LyricsService: Searching for "$q"...');
        url = Uri.parse('$baseUrl/search').replace(queryParameters: {'q': q});
        response = await http.get(url);

        if (response.statusCode == 200) {
          final List results = jsonDecode(response.body);
          if (results.isNotEmpty) {
            // Find best match by duration if possible
            if (durationSeconds > 0) {
              for (var result in results) {
                final resultDuration = (result['duration'] as num?)?.toInt() ?? 0;
                if ((resultDuration - durationSeconds).abs() < 10) {
                  debugPrint('✅ Found duration-matched result for "$q"');
                  return LyricsResponse.fromJson(result);
                }
              }
            }
            // Return first result with synced lyrics if any
            final syncedResult = results.firstWhere(
              (r) => r['syncedLyrics'] != null && r['syncedLyrics'].toString().isNotEmpty,
              orElse: () => results.first,
            );
            debugPrint('✅ Found search result for "$q"');
            return LyricsResponse.fromJson(syncedResult);
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching lyrics: $e');
    }
    return null;
  }
}
