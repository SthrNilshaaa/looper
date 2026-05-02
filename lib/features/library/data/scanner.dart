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

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (supportedExtensions.contains(ext)) {
          await _processFile(entity);
        }
      }
    }
  }

  Future<void> _processFile(File file) async {
    try {
      final metadata = await MetadataGod.readMetadata(file: file.path);
      
      // Extract and save artwork first
      String? artPath;
      if (metadata.picture != null) {
        print('✅ Found picture for: ${metadata.title}');
        artPath = await saveAlbumArt(metadata.album ?? 'unknown', metadata.picture!.data);
        print('💾 Saved art to: $artPath');
      } else {
        print('❌ No picture found for: ${metadata.title}');
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

      await DbService.isar.writeTxn(() async {
        // Upsert song
        await DbService.isar.songs.putByPath(song);
        
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

        // Handle Artist
        if (metadata.artist != null) {
          final existingArtist = await DbService.isar.artists.filter().nameEqualTo(metadata.artist!).findFirst();
          if (existingArtist == null) {
            final artist = Artist()
              ..name = metadata.artist!;
            await DbService.isar.artists.put(artist);
          }
        }
      });
    } catch (e) {
      print('Error processing ${file.path}: $e');
    }
  }

  Future<String?> saveAlbumArt(String albumName, List<int> data) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final artDir = Directory(p.join(appDir.path, 'album_art'));
      if (!await artDir.exists()) await artDir.create(recursive: true);
      
      // Use a hash of the data to ensure uniqueness for different images
      final hash = data.length.toString() + data.take(10).join() + data.reversed.take(10).join();
      final safeAlbumName = albumName.replaceAll(RegExp(r'[^\w\s]+'), '');
      final fileName = '${safeAlbumName}_${hash.hashCode}.jpg';
      
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
