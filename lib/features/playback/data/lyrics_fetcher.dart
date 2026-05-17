import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'lyrics_cache.dart';
import 'metadata_service.dart';
import 'lyrics_service.dart';

class LyricsFetcher {
  static final LyricsService _service = LyricsService();

  static Future<String?> fetchLyrics(Song song) async {
    String? lrc;
    final artist = (song.artist ?? 'Unknown Artist').trim();
    final title = song.title.trim();

    // 1. Try Song Database First
    if (song.lyrics != null && song.lyrics!.isNotEmpty) {
      return song.lyrics;
    }

    // 2. Try Embedded Metadata (Live check)
    lrc = await MetadataService.getEmbeddedLyrics(song.path);
    if (lrc != null && lrc.isNotEmpty) {
      // Save to DB for future use
      await DbService.isar.writeTxn(() async {
        final dbSong = await DbService.isar.songs.get(song.id);
        if (dbSong != null) {
          dbSong.lyrics = lrc;
          await DbService.isar.songs.put(dbSong);
        }
      });
      return lrc;
    }

    // 3. Try Local Cache
    lrc = await LyricsCache.get(artist, title);
    if (lrc != null) return lrc;

    // 4. Try External Sidecar Files
    final songFile = File(song.path);
    final songDir = songFile.parent.path;
    final songBaseName = p.basenameWithoutExtension(song.path);

    final searchPaths = [
      p.join(songDir, '$songBaseName.lrc'),
      p.join(songDir, '$songBaseName.txt'),
      p.join(songDir, 'lyrics', '$songBaseName.lrc'),
      p.join(songDir, 'lyrics', '$songBaseName.txt'),
      p.join(songDir, 'Lyrics', '$songBaseName.lrc'),
    ];

    for (final path in searchPaths) {
      try {
        final file = File(path);
        if (await file.exists()) {
          final content = await file.readAsString();
          if (content.isNotEmpty) {
            lrc = content;
            break;
          }
        }
      } catch (_) {}
    }
    if (lrc != null) return lrc;

    // 5. Online service search
    try {
      final response = await _service.getLyrics(
        trackName: title,
        artistName: artist,
        albumName: (song.album ?? '').trim(),
        durationSeconds: (song.duration ?? 0) ~/ 1000,
      );
      lrc = response?.syncedLyrics ?? response?.plainLyrics;

      if (lrc != null && lrc.isNotEmpty) {
        // Save to cache and DB
        await LyricsCache.save(artist, title, lrc);
        await DbService.isar.writeTxn(() async {
          final dbSong = await DbService.isar.songs.get(song.id);
          if (dbSong != null) {
            dbSong.lyrics = lrc;
            await DbService.isar.songs.put(dbSong);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching online lyrics: $e');
    }

    return lrc;
  }
}
