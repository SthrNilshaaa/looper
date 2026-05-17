import 'dart:io';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/db_service.dart';
import '../domain/models/models.dart';
import 'package:isar/isar.dart';
import '../../playback/data/metadata_service.dart';

class LibraryScanner {
  final List<String> supportedExtensions = [
    '.mp3',
    '.flac',
    '.opus',
    '.aac',
    '.m4a',
    '.m4b',
    '.wav',
    '.ogg',
    '.aiff',
    '.alac',
    '.wma',
  ];

  Future<int> scanDirectory(String path, {bool addFolderToSettings = false}) async {
    print('🔍 Scanner: Scanning directory: $path');
    final dir = Directory(path);
    if (!await dir.exists()) {
      print('❌ Scanner: Directory does not exist: $path');
      return 0;
    }

    final List<File> filesToProcess = [];
    final Set<String> musicFolders = {};
    
    try {
      await for (final entity in dir.list(recursive: true, followLinks: true)) {
        final baseName = p.basename(entity.path);
        
        // Skip hidden files and directories (starting with .)
        if (baseName.startsWith('.') && baseName != '.') continue;
        
        // Also skip if any parent directory is hidden
        final relativePath = p.relative(entity.path, from: path);
        if (relativePath.split(p.separator).any((part) => part.startsWith('.') && part != '.')) {
          continue;
        }

        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(ext)) {
            filesToProcess.add(entity);
            musicFolders.add(p.dirname(entity.path));
          }
        }
      }
    } catch (e) {
      print('❌ Scanner: Error listing files in $path: $e');
    }

    print('🎵 Scanner: Found ${filesToProcess.length} audio files in $path');

    if (filesToProcess.isEmpty) return 0;

    // If requested, add discovered folders to settings
    if (addFolderToSettings) {
      // In a real app, you might want to add these to settingsProvider
      // For now, we print them and ensure they are processed
      print('📂 Scanner: Discovered ${musicFolders.length} folders with music');
    }

    // Process in smaller batches with delays to keep UI responsive
    const int batchSize = 4;
    for (int i = 0; i < filesToProcess.length; i += batchSize) {
      final end = (i + batchSize < filesToProcess.length)
          ? i + batchSize
          : filesToProcess.length;
      final batch = filesToProcess.sublist(i, end);

      final results = await Future.wait(batch.map((f) => _extractMetadata(f)));
      
      // Small pause to allow UI to breathe
      await Future.delayed(const Duration(milliseconds: 50));

      await DbService.isar.writeTxn(() async {
        for (final data in results) {
          if (data == null) continue;
          final song = data['song'] as Song;
          final metadata = data['metadata'] as Metadata;
          final artPath = data['artPath'] as String?;

          // Merge with existing song to preserve user data (history, favorites, etc.)
          final existingSong = await DbService.isar.songs
              .filter()
              .pathEqualTo(song.path)
              .findFirst();
          if (existingSong != null) {
            // Update metadata only
            existingSong.title = song.title;
            existingSong.artist = song.artist;
            existingSong.album = song.album;
            existingSong.genre = song.genre;
            existingSong.duration = song.duration;
            existingSong.trackNumber = song.trackNumber;
            existingSong.year = song.year;
            existingSong.artPath = song.artPath;
            // dateAdded, isFavorite, lastPlayed, playCount are PRESERVED
            await DbService.isar.songs.put(existingSong);
          } else {
            await DbService.isar.songs.put(song);
          }

          if (metadata.album != null) {
            final existingAlbum = await DbService.isar.albums
                .filter()
                .nameEqualTo(metadata.album!)
                .findFirst();
            if (existingAlbum == null) {
              final album = Album()
                ..name = metadata.album!
                ..artist = metadata.artist
                ..artPath = artPath
                ..dateAdded = DateTime.now();
              await DbService.isar.albums.put(album);
            } else if (existingAlbum.artPath == null && artPath != null) {
              existingAlbum.artPath = artPath;
              await DbService.isar.albums.put(existingAlbum);
            }
          }

          if (metadata.artist != null) {
            final existingArtist = await DbService.isar.artists
                .filter()
                .nameEqualTo(metadata.artist!)
                .findFirst();
            if (existingArtist == null) {
              final artist = Artist()..name = metadata.artist!;
              await DbService.isar.artists.put(artist);
            }
          }
        }
      });
    }
    return filesToProcess.length;
  }

  Future<Map<String, dynamic>?> _extractMetadata(File file) async {
    try {
      Metadata? metadata;
      try {
        metadata = await MetadataGod.readMetadata(file: file.path);
      } catch (e) {
        print('⚠️ MetadataGod failed for ${file.path}: $e');
      }

      String? artPath;
      if (metadata?.picture != null) {
        artPath = await saveAlbumArt(
          metadata?.album ?? 'unknown',
          metadata!.picture!.data,
        );
      }

      final lyrics = await MetadataService.getEmbeddedLyrics(file.path);

      final song = Song()
        ..path = file.path
        ..title = metadata?.title ?? p.basenameWithoutExtension(file.path)
        ..artist = metadata?.artist ?? 'Unknown Artist'
        ..album = metadata?.album ?? 'Unknown Album'
        ..genre = metadata?.genre
        ..duration = metadata?.durationMs?.toInt()
        ..trackNumber = metadata?.trackNumber
        ..year = metadata?.year
        ..artPath = artPath
        ..lyrics = lyrics
        ..dateAdded = DateTime.now();

      return {
        'song': song,
        'metadata': metadata ?? Metadata(title: song.title, artist: song.artist, album: song.album),
        'artPath': artPath
      };
    } catch (e) {
      print('❌ Final error extracting metadata for ${file.path}: $e');
      return null;
    }
  }

  Future<String?> saveAlbumArt(String albumName, List<int> data) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final artDir = Directory(p.join(appDir.path, 'album_art'));
      if (!await artDir.exists()) await artDir.create(recursive: true);

      final hash =
          data.length.toString() +
          data.take(10).join() +
          data.reversed.take(10).join();
      final fileName =
          '${albumName.replaceAll(RegExp(r'[^\w\s]+'), '')}_${hash.hashCode}.jpg';

      final file = File(p.join(artDir.path, fileName));
      if (!await file.exists()) {
        await file.writeAsBytes(data);
      }
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
