import 'dart:io';
import 'dart:convert';
import 'package:metadata_god/metadata_god.dart';

class MetadataService {
  static Future<String?> getEmbeddedLyrics(String path) async {
    if (Platform.isLinux) {
      return await _getLyricsLinux(path);
    }
    return null;
  }

  static Future<String?> _getLyricsLinux(String path) async {
    try {
      final result = await Process.run('ffprobe', [
        '-v', 'quiet',
        '-print_format', 'json',
        '-show_format',
        path
      ]);

      if (result.exitCode == 0) {
        final data = jsonDecode(result.stdout);
        return _extractLyricsFromJson(data);
      }
    } catch (_) {}
    return null;
  }

  static String? _extractLyricsFromJson(Map<String, dynamic> data) {
    final tags = data['format']?['tags'];
    if (tags != null) {
      return _extractLyricsFromMap(Map<String, dynamic>.from(tags));
    }
    return null;
  }

  static String? _extractLyricsFromMap(Map<String, dynamic> tags) {
    // Look for common lyrics tags (case-insensitive)
    for (final key in tags.keys) {
      final lowerKey = key.toLowerCase();
      if (lowerKey == 'lyrics' || 
          lowerKey == 'unsync-lyrics' || 
          lowerKey == 'unsyncedlyrics' || 
          lowerKey == 'uslt') {
        return tags[key]?.toString();
      }
    }
    return null;
  }
}
