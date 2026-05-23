import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter_new_full/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/session.dart';
import 'package:ffmpeg_kit_flutter_new_full/session_state.dart';

class MetadataService {
  static Future<String?> getEmbeddedLyrics(String path) async {
    if (Platform.isLinux) {
      return await _getLyricsLinux(path);
    } else if (Platform.isAndroid) {
      return await _getLyricsAndroid(path);
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
    } catch (e) {
      debugPrint('Error reading embedded lyrics with ffprobe: $e');
    }
    return null;
  }

  static Future<String?> _getLyricsAndroid(String path) async {
    try {
      final session = await FFprobeKit.getMediaInformation(path);
      final info = session.getMediaInformation();
      if (info == null) return null;
      
      final tags = info.getTags();
      if (tags != null) {
        return _extractLyricsFromMap(Map<String, dynamic>.from(tags));
      }
    } catch (e) {
      debugPrint('Error reading embedded lyrics with FFprobeKit: $e');
    }
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
