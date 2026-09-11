import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar_community/isar.dart';
import 'db_service.dart';
import 'logger_helper.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';

class ImportExportService {
  static Future<void> exportLibraryData(BuildContext context) async {
    LoggerHelper.write('ImportExportService: Starting library backup export...');
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 1. Get all liked songs
      final likedSongs = await DbService.isar.songs.filter().isFavoriteEqualTo(true).findAll();
      final favoritesJson = likedSongs.map((s) => {
        'path': s.path,
        'title': s.title,
        'artist': s.artist,
        'album': s.album,
      }).toList();
      LoggerHelper.write('ImportExportService: Found ${likedSongs.length} favorited songs to export.');

      // 2. Get all playlists
      final playlists = await DbService.isar.playlists.where().findAll();
      final playlistsJson = playlists.map((p) => {
        'name': p.name,
        'songPaths': p.songPaths,
        'dateCreated': p.dateCreated.toIso8601String(),
        'dateModified': p.dateModified.toIso8601String(),
      }).toList();
      LoggerHelper.write('ImportExportService: Found ${playlists.length} playlists to export.');

      // 3. Construct JSON structure
      final backup = {
        'version': 1,
        'favorites': favoritesJson,
        'playlists': playlistsJson,
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(backup);

      // 4. Write to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/looper_player_backup.json');
      await file.writeAsString(jsonStr);
      LoggerHelper.write('ImportExportService: Serialised backup written to: ${file.path}');

      // 5. Native Share
      await Share.shareXFiles([XFile(file.path)], subject: 'Looper Player Backup');
      LoggerHelper.write('ImportExportService: Shared backup file successfully.');
    } catch (e, stack) {
      LoggerHelper.write('ImportExportService: Failed to export library data', e, stack);
      messenger.showSnackBar(SnackBar(
        content: const Text('Failed to export backup: An internal error occurred while saving the backup file.'),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  static Future<void> importLibraryData(BuildContext context, WidgetRef ref) async {
    LoggerHelper.write('ImportExportService: Starting library backup import...');
    final messenger = ScaffoldMessenger.of(context);
    try {
      // 1. Pick file
      final result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.path == null) {
        LoggerHelper.write('ImportExportService: Import cancelled by user (no file selected).');
        return;
      }

      final filePath = result.path!;
      LoggerHelper.write('ImportExportService: User selected file: $filePath');

      final file = File(filePath);
      final content = await file.readAsString();
      final Map<String, dynamic> backup = jsonDecode(content);

      if (backup['version'] != 1) {
        throw 'Unsupported backup version: ${backup['version']}';
      }

      int favoritesMerged = 0;
      int playlistsCreated = 0;

      // 2. Import Favorites
      final favorites = backup['favorites'] as List<dynamic>? ?? [];
      LoggerHelper.write('ImportExportService: Parsing ${favorites.length} favorited songs from backup.');
      for (final fav in favorites) {
        final path = fav['path'] as String?;
        final title = fav['title'] as String?;
        final artist = fav['artist'] as String?;
        final album = fav['album'] as String?;

        if (path == null) continue;

        // Try to match song by path first
        var song = await DbService.isar.songs.filter().pathEqualTo(path).findFirst();

        // Fallback: match by title and artist if path fails (path drift/drive change)
        if (song == null && title != null && artist != null) {
          song = await DbService.isar.songs.filter()
              .titleEqualTo(title)
              .and()
              .artistEqualTo(artist)
              .findFirst();
        }

        if (song != null && !song.isFavorite) {
          song.isFavorite = true;
          await DbService.isar.writeTxn(() async {
            await DbService.isar.songs.put(song!);
          });
          favoritesMerged++;
        }
      }
      LoggerHelper.write('ImportExportService: Merged $favoritesMerged favorites.');

      // 3. Import Playlists
      final playlists = backup['playlists'] as List<dynamic>? ?? [];
      LoggerHelper.write('ImportExportService: Parsing ${playlists.length} playlists from backup.');
      for (final pl in playlists) {
        final name = pl['name'] as String?;
        final songPaths = List<String>.from(pl['songPaths'] ?? []);
        final dateCreatedStr = pl['dateCreated'] as String?;
        final dateModifiedStr = pl['dateModified'] as String?;

        if (name == null || name.isEmpty) continue;

        final dateCreated = dateCreatedStr != null ? DateTime.parse(dateCreatedStr) : DateTime.now();
        final dateModified = dateModifiedStr != null ? DateTime.parse(dateModifiedStr) : DateTime.now();

        // Check if playlist exists
        var playlist = await DbService.isar.playlists.filter().nameEqualTo(name).findFirst();
        if (playlist == null) {
          playlist = Playlist()
            ..name = name
            ..songPaths = songPaths
            ..dateCreated = dateCreated
            ..dateModified = dateModified;
          await DbService.isar.writeTxn(() async {
            await DbService.isar.playlists.put(playlist!);
          });
          playlistsCreated++;
        } else {
          // Merge paths
          final mergedPaths = Set<String>.from(playlist.songPaths)..addAll(songPaths);
          playlist.songPaths = mergedPaths.toList();
          playlist.dateModified = DateTime.now();
          await DbService.isar.writeTxn(() async {
            await DbService.isar.playlists.put(playlist!);
          });
          playlistsCreated++;
        }
      }
      LoggerHelper.write('ImportExportService: Synced $playlistsCreated playlists.');

      // Trigger Library ref scan / updates to sync UI
      ref.read(libraryProvider.notifier).scanSavedFolders(showVisualIndicator: false);

      messenger.showSnackBar(SnackBar(
        content: Text('Backup imported: Merged $favoritesMerged favorites, synced $playlistsCreated playlists'),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e, stack) {
      LoggerHelper.write('ImportExportService: Failed to import library data', e, stack);
      messenger.showSnackBar(SnackBar(
        content: const Text('Failed to import backup: The file could not be read or the backup format is invalid.'),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}
