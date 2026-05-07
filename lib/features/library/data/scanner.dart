import 'dart:io';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/db_service.dart';
import '../domain/models/models.dart';
import 'package:isar/isar.dart';

class LibraryScanner {
  final List<String> supportedExtensions = [
    '.mp3', '.flac', '.opus', '.aac', '.m4a', '.wav', '.ogg', '.aiff', '.alac'
  ];

  Future<void> scanDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return;

    final List<File> filesToProcess = [];
    await for (final entity in dir.list(recursive: true, followLinks: true)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (supportedExtensions.contains(ext)) {
          filesToProcess.add(entity);
        }
      }
    }

    if (filesToProcess.isEmpty) return;

    // Process in batches to avoid overwhelming the system
    const int batchSize = 20;
    for (int i = 0; i < filesToProcess.length; i += batchSize) {
      final end = (i + batchSize < filesToProcess.length) ? i + batchSize : filesToProcess.length;
      final batch = filesToProcess.sublist(i, end);
      
      final results = await Future.wait(batch.map((f) => _extractMetadata(f)));
      
      await DbService.isar.writeTxn(() async {
        for (final data in results) {
          if (data == null) continue;
          final song = data['song'] as Song;
          final metadata = data['metadata'] as Metadata;
          final artPath = data['artPath'] as String?;

          // Merge with existing song to preserve user data (history, favorites, etc.)
          final existingSong = await DbService.isar.songs.filter().pathEqualTo(song.path).findFirst();
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
            final existingAlbum = await DbService.isar.albums.filter().nameEqualTo(metadata.album!).findFirst();
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
            final existingArtist = await DbService.isar.artists.filter().nameEqualTo(metadata.artist!).findFirst();
            if (existingArtist == null) {
              final artist = Artist()
                ..name = metadata.artist!;
              await DbService.isar.artists.put(artist);
            }
          }
        }
      });
    }
  }

  Future<Map<String, dynamic>?> _extractMetadata(File file) async {
    try {
      final metadata = await MetadataGod.readMetadata(file: file.path);
      String? artPath;
      if (metadata.picture != null) {
        artPath = await saveAlbumArt(metadata.album ?? 'unknown', metadata.picture!.data);
      }

      final song = Song()
        ..path = file.path
        ..title = metadata.title ?? p.basenameWithoutExtension(file.path)
        ..artist = metadata.artist
        ..album = metadata.album
        ..genre = metadata.genre
        ..duration = metadata.durationMs?.toInt()
        ..trackNumber = metadata.trackNumber
        ..year = metadata.year
        ..artPath = artPath
        ..dateAdded = DateTime.now();

      return {
        'song': song,
        'metadata': metadata,
        'artPath': artPath,
      };
    } catch (e) {
      return null;
    }
  }

  Future<String?> saveAlbumArt(String albumName, List<int> data) async {
    try {
      final appDir = await getApplicationSupportDirectory();
      final artDir = Directory(p.join(appDir.path, 'album_art'));
      if (!await artDir.exists()) await artDir.create(recursive: true);
      
      final hash = data.length.toString() + data.take(10).join() + data.reversed.take(10).join();
      final fileName = '${albumName.replaceAll(RegExp(r'[^\w\s]+'), '')}_${hash.hashCode}.jpg';
      
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
