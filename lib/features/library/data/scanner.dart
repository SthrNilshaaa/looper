import 'dart:io';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/db_service.dart';
import '../domain/models/models.dart';
import 'package:isar/isar.dart';
import '../../playback/data/metadata_service.dart';

class ScanResult {
  final int songsCount;
  final Set<String> musicFolders;

  ScanResult({required this.songsCount, required this.musicFolders});
}

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

  Future<ScanResult> scanDirectory(String path, {bool addFolderToSettings = false}) async {
    print('🔍 Scanner: Scanning directory: $path');
    final dir = Directory(path);
    if (!await dir.exists()) {
      print('❌ Scanner: Directory does not exist: $path');
      return ScanResult(songsCount: 0, musicFolders: {});
    }

    final List<File> filesToProcess = [];
    final Set<String> musicFolders = {};
    
    Future<void> traverse(Directory currentDir) async {
      final baseName = p.basename(currentDir.path);
      // Skip hidden folders and Android system directories to avoid slow scans or access issues
      if (baseName.startsWith('.') && baseName != '.') return;
      if (baseName.toLowerCase() == 'android') return;

      List<FileSystemEntity> entities = [];
      try {
        entities = await currentDir.list(recursive: false, followLinks: true).toList();
      } catch (e) {
        // Silently catch and skip restricted directories without crashing the whole scan!
        return;
      }

      for (final entity in entities) {
        final name = p.basename(entity.path);
        if (name.startsWith('.') && name != '.') continue;

        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(ext)) {
            filesToProcess.add(entity);
            musicFolders.add(p.dirname(entity.path));
          }
        } else if (entity is Directory) {
          await traverse(entity);
        }
      }
    }

    try {
      await traverse(dir);
    } catch (e) {
      print('❌ Scanner: Critical error during traversal of $path: $e');
    }

    print('🎵 Scanner: Found ${filesToProcess.length} audio files in $path');

    if (filesToProcess.isEmpty) {
      // Clean up any songs in Isar that were in this folder
      await DbService.isar.writeTxn(() async {
        final prefix = path.endsWith('/') ? path : '$path/';
        final toDelete = await DbService.isar.songs
            .filter()
            .pathStartsWith(prefix)
            .or()
            .pathEqualTo(path)
            .findAll();
        final idsToDelete = toDelete.map((s) => s.id).toList();
        if (idsToDelete.isNotEmpty) {
          await DbService.isar.songs.deleteAll(idsToDelete);
        }
      });
      return ScanResult(songsCount: 0, musicFolders: {});
    }

    // Get all existing songs in the database that are located under this scan path
    final prefix = path.endsWith('/') ? path : '$path/';
    final songsInPathDb = await DbService.isar.songs
        .filter()
        .pathStartsWith(prefix)
        .or()
        .pathEqualTo(path)
        .findAll();
    final Map<String, Song> dbSongsMap = {for (var s in songsInPathDb) s.path: s};

    // Find deleted files (present in DB but no longer on disk)
    final Set<String> currentFilePaths = filesToProcess.map((f) => f.path).toSet();
    final List<int> idsToDelete = [];
    dbSongsMap.forEach((p, song) {
      if (!currentFilePaths.contains(p)) {
        idsToDelete.add(song.id);
      }
    });

    if (idsToDelete.isNotEmpty) {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.deleteAll(idsToDelete);
      });
      print('🗑️ Scanner: Pruned ${idsToDelete.length} deleted songs from database');
    }

    // Find new files to process (on disk but not in DB)
    final List<File> newFilesToProcess = filesToProcess.where((f) => !dbSongsMap.containsKey(f.path)).toList();

    // If requested, add discovered folders to settings
    if (addFolderToSettings) {
      print('📂 Scanner: Discovered ${musicFolders.length} folders with music');
    }

    if (newFilesToProcess.isNotEmpty) {
      print('🆕 Scanner: Parsing metadata for ${newFilesToProcess.length} new files...');
      
      final List<Map<String, dynamic>> allResults = [];
      const int batchSize = 16; // Process in larger batches of 16 for better parallelism
      
      for (int i = 0; i < newFilesToProcess.length; i += batchSize) {
        final end = (i + batchSize < newFilesToProcess.length)
            ? i + batchSize
            : newFilesToProcess.length;
        final batch = newFilesToProcess.sublist(i, end);

        final results = await Future.wait(batch.map((f) => _extractMetadata(f)));
        for (final res in results) {
          if (res != null) {
            allResults.add(res);
          }
        }
        
        // Small pause to allow the UI to breathe and process input events
        await Future.delayed(const Duration(milliseconds: 20));
      }

      if (allResults.isNotEmpty) {
        print('💾 Scanner: Writing ${allResults.length} parsed items to database in a single transaction...');
        await DbService.isar.writeTxn(() async {
          for (final data in allResults) {
            final song = data['song'] as Song;
            final metadata = data['metadata'] as Metadata;
            final artPath = data['artPath'] as String?;

            // Confirmed new, put it directly
            await DbService.isar.songs.put(song);

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
    } else {
      print('⚡ Scanner: All ${filesToProcess.length} files are up to date! Skipping parsing.');
    }

    return ScanResult(songsCount: filesToProcess.length, musicFolders: musicFolders);
  }

  Future<Map<String, dynamic>?> _extractMetadata(File file) async {
    try {
      Metadata? metadata;
      try {
        // Enforce strict 800ms timeout on native metadata read to prevent scanning/UI hangs
        metadata = await MetadataGod.readMetadata(file: file.path)
            .timeout(const Duration(milliseconds: 800));
      } catch (e) {
        print('⚠️ MetadataGod failed or timed out for ${file.path}: $e');
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
