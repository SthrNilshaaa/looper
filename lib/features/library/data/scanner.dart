import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/db_service.dart';
import '../domain/models/models.dart';
import 'package:isar_community/isar.dart';
import '../../playback/data/metadata_service.dart';
import 'artwork_downloader_service.dart';
import 'saf_folder_service.dart';

class ScanResult {
  final int songsCount;
  final Set<String> musicFolders;

  ScanResult({required this.songsCount, required this.musicFolders});
}

class ArtistParser {
  /// Splits strings like "Artist A feat. Artist B", "Artist A / Artist B", "Artist A; Artist B", "Artist A & Artist B"
  static List<String> parse(String? rawArtist) {
    if (rawArtist == null ||
        rawArtist.trim().isEmpty ||
        rawArtist.trim().toLowerCase() == 'unknown artist') {
      return ['Unknown Artist'];
    }

    final regex = RegExp(
      r'\s*(?:;|\/|\\|&|feat\.|ft\.|,|AND)\s*',
      caseSensitive: false,
    );
    final parts = rawArtist
        .split(regex)
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    return parts.isNotEmpty ? parts : [rawArtist.trim()];
  }

  static String primaryArtist(String? rawArtist) {
    final parsed = parse(rawArtist);
    return parsed.first;
  }
}

@visibleForTesting
bool isIgnoredScanPath(
  String targetPath, {
  bool includeSystemAndMessagingAudio = false,
}) {
  final lower = targetPath.toLowerCase();
  final baseName = p.basename(lower);
  final segments = p
      .split(lower)
      .where((segment) => segment.isNotEmpty && segment != p.separator)
      .toList();

  if (baseName.startsWith('.') && baseName != '.') return true;
  if (lower.contains('/android/data/') ||
      lower.endsWith('/android/data') ||
      lower.contains('/android/obb/') ||
      lower.endsWith('/android/obb') ||
      segments.contains('.cache') ||
      baseName == '.nomedia') {
    return true;
  }

  if (includeSystemAndMessagingAudio) return false;

  // Ringtones, Notifications, Alarms
  if (segments.any(
        const {
          'ringtones',
          'ringtone',
          'notifications',
          'notification',
          'alarms',
          'alarm',
        }.contains,
      ) ||
      lower.contains('/system/media/audio')) {
    return true;
  }

  // WhatsApp & Messaging Voice Notes / Audio
  if (segments.any(
    (segment) =>
        segment == 'whatsapp' ||
        segment == 'whatsapp business' ||
        segment == 'whatsapp voice notes' ||
        segment == 'whatsapp audio' ||
        segment == 'telegram audio' ||
        segment == 'telegram voice',
  )) {
    return true;
  }

  // Common voice note filename prefixes (PTT, AUD)
  if (baseName.startsWith('ptt-') || baseName.startsWith('aud-')) {
    return true;
  }

  return false;
}

Future<List<String>> _isolatedDirectoryTraversal(
  Map<String, dynamic> params,
) async {
  final String rootPath = params['rootPath'] as String;
  final List<String> extensions = List<String>.from(
    params['extensions'] as List,
  );
  final int minSizeBytes = params['minSizeBytes'] as int;
  final bool includeSystemAndMessagingAudio =
      params['includeSystemAndMessagingAudio'] as bool? ?? false;

  final dir = Directory(rootPath);
  if (!dir.existsSync()) return [];

  final List<String> validFiles = [];

  void walk(Directory currentDir) {
    if (isIgnoredScanPath(
      currentDir.path,
      includeSystemAndMessagingAudio: includeSystemAndMessagingAudio,
    )) {
      return;
    }

    List<FileSystemEntity> entities = [];
    try {
      entities = currentDir.listSync(recursive: false, followLinks: false);
    } catch (_) {
      return;
    }

    for (final entity in entities) {
      if (isIgnoredScanPath(
        entity.path,
        includeSystemAndMessagingAudio: includeSystemAndMessagingAudio,
      )) {
        continue;
      }

      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (extensions.contains(ext)) {
          try {
            if (entity.lengthSync() >= minSizeBytes) {
              validFiles.add(entity.path);
            }
          } catch (_) {}
        }
      } else if (entity is Directory) {
        walk(entity);
      }
    }
  }

  walk(dir);
  return validFiles;
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
    '.ape',
    '.wv',
    '.tta',
    '.dsf',
    '.dff',
  ];

  static const int minDurationMs = 0; // Skipped filter as requested
  static const int minSizeBytes = 0; // Skipped filter as requested

  static const MethodChannel _broadcastChannel = MethodChannel(
    'com.looper.player/broadcast',
  );
  final Map<String, String?> _folderArtCache = {};

  // A full-storage-discovery scan calls scanDirectory() once per candidate
  // folder (Music, Download, DCIM, ...), and without All Files Access every
  // one of those calls needs the *entire* device-wide MediaStore audio index
  // (see the merge logic below). Re-running that native query per-folder was
  // pure waste, so the most recent result is memoized briefly and shared
  // across every LibraryScanner instance created during one scan pass.
  static List<Map<String, dynamic>>? _cachedMediaStoreItems;
  static bool? _cachedMediaStoreFlag;
  static DateTime? _cachedMediaStoreAt;
  static const Duration _mediaStoreCacheTtl = Duration(seconds: 15);

  Future<List<Map<String, dynamic>>?> _queryMediaStoreNative({
    required bool includeSystemAndMessagingAudio,
  }) async {
    if (!Platform.isAndroid) return null;

    final cachedAt = _cachedMediaStoreAt;
    if (cachedAt != null &&
        _cachedMediaStoreFlag == includeSystemAndMessagingAudio &&
        DateTime.now().difference(cachedAt) < _mediaStoreCacheTtl) {
      return _cachedMediaStoreItems;
    }

    try {
      final List<dynamic>? rawList = await _broadcastChannel
          .invokeMethod<List<dynamic>>('queryMediaStore', {
            'minDurationMs': minDurationMs,
            'minSizeBytes': minSizeBytes,
            'includeSystemAndMessagingAudio': includeSystemAndMessagingAudio,
          });
      if (rawList == null) return null;
      final items = rawList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      _cachedMediaStoreItems = items;
      _cachedMediaStoreFlag = includeSystemAndMessagingAudio;
      _cachedMediaStoreAt = DateTime.now();
      return items;
    } catch (_) {
      return null;
    }
  }

  // Same memoization idea as the MediaStore cache above, for the SAF
  // (Storage Access Framework) folder listing: it's also device-wide (every
  // currently-granted "Add folder" folder, not just the one being scanned),
  // so without this it would get re-walked once per candidate folder during
  // a full scan.
  static List<String>? _cachedSafFiles;
  static DateTime? _cachedSafFilesAt;
  static const Duration _safFilesCacheTtl = Duration(seconds: 15);

  Future<List<String>> _querySafFiles() async {
    if (!Platform.isAndroid) return const [];

    final cachedAt = _cachedSafFilesAt;
    if (cachedAt != null &&
        DateTime.now().difference(cachedAt) < _safFilesCacheTtl) {
      return _cachedSafFiles ?? const [];
    }

    final files = await SafFolderService.listAudioFiles(supportedExtensions);
    _cachedSafFiles = files;
    _cachedSafFilesAt = DateTime.now();
    return files;
  }

  Future<ScanResult> scanDirectory(
    String path, {
    bool addFolderToSettings = false,
  }) async {
    final List<File> filesToProcess = [];
    final Set<String> musicFolders = {};

    final Set<String> discoveredPaths = {};

    final Map<String, Map<String, dynamic>> mediaStoreMap = {};
    final settings = await DbService.isar.appSettings.get(0);
    final includeSystemAndMessagingAudio =
        settings?.includeSystemAndMessagingAudio ?? false;

    // 1. Direct Background Isolate Directory Traversal for full disk coverage
    if (Directory(path).existsSync()) {
      final List<String> filePaths =
          await compute(_isolatedDirectoryTraversal, {
            'rootPath': path,
            'extensions': supportedExtensions,
            'minSizeBytes': minSizeBytes,
            'includeSystemAndMessagingAudio': includeSystemAndMessagingAudio,
          });
      discoveredPaths.addAll(filePaths);
    }

    // 2. Native Android MediaStore Query - the primary discovery source.
    // Without MANAGE_EXTERNAL_STORAGE (removed for Play Store compliance,
    // see AndroidManifest.xml) raw filesystem traversal can no longer reach
    // arbitrary folders on its own, so every MediaStore-indexed track is
    // always merged in here regardless of which root this particular scan
    // pass is scoped to.
    if (Platform.isAndroid) {
      final mediaStoreItems = await _queryMediaStoreNative(
        includeSystemAndMessagingAudio: includeSystemAndMessagingAudio,
      );
      if (mediaStoreItems != null && mediaStoreItems.isNotEmpty) {
        for (final item in mediaStoreItems) {
          final filePath = item['path'] as String?;
          if (filePath != null && filePath.isNotEmpty) {
            mediaStoreMap[filePath] = item;
            mediaStoreMap[p.canonicalize(filePath)] = item;
            final ext = p.extension(filePath).toLowerCase();
            if (supportedExtensions.contains(ext)) {
              discoveredPaths.add(filePath);
            }
          }
        }
      }
    }

    // 3. Native SAF (Storage Access Framework) query - covers files inside
    // manually-added folders ("Add folder") that raw traversal can no longer
    // reach without MANAGE_EXTERNAL_STORAGE, and formats MediaStore doesn't
    // index (e.g. .ape, .wv, .tta, .dsf, .dff), for as long as they live
    // inside a folder the user explicitly granted access to.
    if (Platform.isAndroid) {
      final safFiles = await _querySafFiles();
      for (final filePath in safFiles) {
        final ext = p.extension(filePath).toLowerCase();
        if (supportedExtensions.contains(ext)) {
          discoveredPaths.add(filePath);
        }
      }
    }

    for (final fp in discoveredPaths) {
      filesToProcess.add(File(fp));
      musicFolders.add(p.dirname(fp));
    }

    if (filesToProcess.isEmpty) {
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

    // Existing songs scoped to this folder - used below to know what may
    // need deleting (files under `path` that disappeared).
    final prefix = path.endsWith('/') ? path : '$path/';
    final songsInPathDb = await DbService.isar.songs
        .filter()
        .pathStartsWith(prefix)
        .or()
        .pathEqualTo(path)
        .findAll();

    // "Already known" lookup used to decide which discovered files still
    // need metadata extraction. This must be built from the WHOLE database,
    // not just `songsInPathDb`: without All Files Access the MediaStore
    // merge above intentionally pulls in every indexed audio file regardless
    // of `path` (scoped filesystem access can't be trusted to see
    // everything), so a single full-storage-discovery pass calls
    // scanDirectory() once per candidate folder (Music, Download, DCIM, ...)
    // with the SAME device-wide file list each time. Scoping this map to
    // `path` made every song look "new" on every folder pass but the one it
    // physically lives in, so its metadata (tag parsing, embedded art,
    // lyrics, even artwork downloads) was re-extracted once per folder -
    // easily 10x+ redundant work, which is why "Music and audio" scans were
    // so much slower than "All files" ones (a single-root scan).
    final allDbSongs = await DbService.isar.songs.where().findAll();
    final Map<String, Song> dbSongsMap = {};
    for (final s in allDbSongs) {
      dbSongsMap[s.path] = s;
      dbSongsMap[p.canonicalize(s.path)] = s;
    }

    final Set<String> currentFilePaths = filesToProcess
        .map((f) => f.path)
        .toSet();
    final Set<String> currentCanonicalPaths = filesToProcess
        .map((f) => p.canonicalize(f.path))
        .toSet();

    final List<int> idsToDelete = [];
    for (final song in songsInPathDb) {
      if (!currentFilePaths.contains(song.path) &&
          !currentCanonicalPaths.contains(p.canonicalize(song.path))) {
        idsToDelete.add(song.id);
      }
    }

    if (idsToDelete.isNotEmpty) {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.deleteAll(idsToDelete);
      });
    }

    final List<File> newFilesToProcess = filesToProcess.where((f) {
      final dbSong = dbSongsMap[f.path] ?? dbSongsMap[p.canonicalize(f.path)];
      if (dbSong == null) return true;
      if (dbSong.artist == 'Unknown Artist' || dbSong.artPath == null) {
        return true;
      }
      return false;
    }).toList();

    if (newFilesToProcess.isNotEmpty) {
      final downloadIfMissing =
          (settings?.downloadArtwork ?? false) &&
          (settings?.enableInternet ?? true);

      final List<Map<String, dynamic>> allResults = [];
      const int batchSize = 6;

      for (int i = 0; i < newFilesToProcess.length; i += batchSize) {
        final end = (i + batchSize < newFilesToProcess.length)
            ? i + batchSize
            : newFilesToProcess.length;
        final batch = newFilesToProcess.sublist(i, end);

        final results = await Future.wait(
          batch.map(
            (f) => _extractMetadata(
              f,
              mediaStoreData:
                  mediaStoreMap[f.path] ??
                  mediaStoreMap[p.canonicalize(f.path)],
              downloadArtworkIfMissing: downloadIfMissing,
            ),
          ),
        );
        for (final res in results) {
          if (res != null) {
            allResults.add(res);
          }
        }
        await Future.delayed(const Duration(milliseconds: 5));
      }

      if (allResults.isNotEmpty) {
        await DbService.isar.writeTxn(() async {
          for (final data in allResults) {
            final song = data['song'] as Song;
            final metadata = data['metadata'] as Metadata;
            final artPath = data['artPath'] as String?;

            final existingDbSong =
                dbSongsMap[song.path] ?? dbSongsMap[p.canonicalize(song.path)];
            if (existingDbSong != null) {
              song.id = existingDbSong.id;
            }

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

            final primaryArtistName = ArtistParser.primaryArtist(
              metadata.artist,
            );
            final existingArtist = await DbService.isar.artists
                .filter()
                .nameEqualTo(primaryArtistName)
                .findFirst();
            if (existingArtist == null) {
              final artistObj = Artist()
                ..name = primaryArtistName
                ..artPath = artPath;
              await DbService.isar.artists.put(artistObj);
            } else if (existingArtist.artPath == null && artPath != null) {
              existingArtist.artPath = artPath;
              await DbService.isar.artists.put(existingArtist);
            }
          }
        });
      }
    }

    return ScanResult(
      songsCount: filesToProcess.length,
      musicFolders: musicFolders,
    );
  }

  /// Removes excluded system/messaging audio after the setting is disabled.
  /// Short duration alone is not a reason to delete a legitimate track.
  Future<int> cleanupFilteredAudio({
    required bool includeSystemAndMessagingAudio,
  }) async {
    int removedCount = 0;
    try {
      await DbService.isar.writeTxn(() async {
        final allSongs = await DbService.isar.songs.where().findAll();
        final idsToDelete = <int>[];

        for (final song in allSongs) {
          final isIgnoredPath = isIgnoredScanPath(
            song.path,
            includeSystemAndMessagingAudio: includeSystemAndMessagingAudio,
          );

          if (isIgnoredPath) {
            idsToDelete.add(song.id);
          }
        }

        if (idsToDelete.isNotEmpty) {
          await DbService.isar.songs.deleteAll(idsToDelete);
          removedCount = idsToDelete.length;
        }

        // Cleanup orphaned albums
        final allAlbums = await DbService.isar.albums.where().findAll();
        for (final album in allAlbums) {
          final count = await DbService.isar.songs
              .filter()
              .albumEqualTo(album.name)
              .count();
          if (count == 0) {
            await DbService.isar.albums.delete(album.id);
          }
        }

        // Cleanup orphaned artists
        final allArtists = await DbService.isar.artists.where().findAll();
        for (final artist in allArtists) {
          final count = await DbService.isar.songs
              .filter()
              .artistEqualTo(artist.name)
              .count();
          if (count == 0) {
            await DbService.isar.artists.delete(artist.id);
          }
        }
      });
    } catch (_) {}
    return removedCount;
  }

  Future<List<int>?> _fetchNativeEmbeddedPicture(String path) async {
    if (!Platform.isAndroid) return null;
    try {
      final Uint8List? bytes = await _broadcastChannel.invokeMethod<Uint8List>(
        'getEmbeddedPicture',
        {'path': path},
      );
      return bytes?.toList();
    } catch (_) {
      return null;
    }
  }

  Future<String?> _findFolderArtwork(String songFilePath) async {
    try {
      final dirPath = p.dirname(songFilePath);
      if (_folderArtCache.containsKey(dirPath)) {
        return _folderArtCache[dirPath];
      }
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        _folderArtCache[dirPath] = null;
        return null;
      }
      final candidates = [
        'cover.jpg',
        'cover.png',
        'cover.jpeg',
        'cover.webp',
        'folder.jpg',
        'folder.png',
        'folder.jpeg',
        'folder.webp',
        'front.jpg',
        'front.png',
        'front.jpeg',
        'front.webp',
        'album.jpg',
        'album.png',
        'album.jpeg',
        'album.webp',
        'art.jpg',
        'art.png',
        'art.jpeg',
        'art.webp',
      ];
      for (final candidate in candidates) {
        final f = File(p.join(dirPath, candidate));
        if (await f.exists()) {
          _folderArtCache[dirPath] = f.path;
          return f.path;
        }
      }
      final entities = await dir
          .list(recursive: false, followLinks: false)
          .toList();
      for (final entity in entities) {
        if (entity is File) {
          final base = p.basename(entity.path).toLowerCase();
          if (base.contains('cover') ||
              base.contains('folder') ||
              base.contains('front') ||
              base.contains('album')) {
            final ext = p.extension(base);
            if (['.jpg', '.jpeg', '.png', '.webp'].contains(ext)) {
              _folderArtCache[dirPath] = entity.path;
              return entity.path;
            }
          }
        }
      }
      _folderArtCache[dirPath] = null;
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _extractMetadata(
    File file, {
    Map<String, dynamic>? mediaStoreData,
    bool downloadArtworkIfMissing = false,
  }) async {
    try {
      Metadata? metadata;
      try {
        metadata = await MetadataGod.readMetadata(
          file: file.path,
        ).timeout(const Duration(milliseconds: 1500));
      } catch (_) {}

      String? title = metadata?.title;
      String? artist = metadata?.artist;
      String? album = metadata?.album;
      String? genre = metadata?.genre;
      int? durationMs = metadata?.durationMs?.toInt();
      int? trackNumber = metadata?.trackNumber;
      int? year = metadata?.year;
      List<int>? pictureData = metadata?.picture?.data;

      // Use native MediaStore fallbacks if MetadataGod fields are null or empty
      if (mediaStoreData != null) {
        if (title == null || title.trim().isEmpty) {
          title = mediaStoreData['title'] as String?;
        }
        if (artist == null || artist.trim().isEmpty) {
          artist = mediaStoreData['artist'] as String?;
        }
        if (album == null || album.trim().isEmpty) {
          album = mediaStoreData['album'] as String?;
        }
        if (durationMs == null || durationMs == 0) {
          durationMs = (mediaStoreData['duration'] as num?)?.toInt();
        }
        if (trackNumber == null || trackNumber == 0) {
          trackNumber = (mediaStoreData['track'] as num?)?.toInt();
        }
        if (year == null || year == 0) {
          year = (mediaStoreData['year'] as num?)?.toInt();
        }
      }

      if (durationMs != null && durationMs < LibraryScanner.minDurationMs) {
        return null;
      }

      if (pictureData == null && Platform.isAndroid) {
        pictureData = await _fetchNativeEmbeddedPicture(file.path);
      }

      final filename = p.basenameWithoutExtension(file.path);

      if (artist == null ||
          artist.trim().isEmpty ||
          artist.trim().toLowerCase() == 'unknown artist') {
        if (filename.contains(' - ')) {
          final parts = filename.split(' - ');
          if (parts.length >= 2) {
            artist = parts[0].trim();
            if (title == null || title.trim().isEmpty || title == filename) {
              title = parts.sublist(1).join(' - ').trim();
            }
          }
        }
      }

      String? artPath;
      if (pictureData != null && pictureData.isNotEmpty) {
        artPath = await saveAlbumArt(album ?? 'unknown', pictureData);
      }

      artPath ??= await _findFolderArtwork(file.path);

      String? lyrics;
      try {
        final embeddedLyrics = await MetadataService.getEmbeddedLyrics(file.path);
        // Tag with the same [source:embedded] prefix LyricsFetcher/
        // LyricsNotifier use for an embedded-metadata hit, so the lyrics
        // screen's source pill can identify it - untagged text here read
        // back as a null source later ("No Lyrics Source" shown even though
        // lyrics were actually displayed, since scanning is usually what
        // populates song.lyrics first).
        if (embeddedLyrics != null && embeddedLyrics.isNotEmpty) {
          lyrics = '[source:embedded]\n$embeddedLyrics';
        }
      } catch (_) {}

      DateTime fileDate;
      try {
        fileDate = await file.lastModified();
      } catch (_) {
        fileDate = DateTime.now();
      }

      final cleanTitle = (title != null && title.trim().isNotEmpty)
          ? title.trim()
          : filename;
      final cleanArtist = (artist != null && artist.trim().isNotEmpty)
          ? artist.trim()
          : 'Unknown Artist';
      final cleanAlbum = (album != null && album.trim().isNotEmpty)
          ? album.trim()
          : 'Unknown Album';

      final song = Song()
        ..path = file.path
        ..title = cleanTitle
        ..artist = cleanArtist
        ..album = cleanAlbum
        ..genre = genre
        ..duration = durationMs
        ..trackNumber = trackNumber
        ..year = year
        ..artPath = artPath
        ..lyrics = lyrics
        ..dateAdded = fileDate;

      if (artPath == null && downloadArtworkIfMissing) {
        try {
          artPath = await ArtworkDownloaderService().downloadArtworkForSong(
            song,
          );
          song.artPath = artPath;
        } catch (_) {}
      }

      return {
        'song': song,
        'metadata':
            metadata ??
            Metadata(title: cleanTitle, artist: cleanArtist, album: cleanAlbum),
        'artPath': artPath,
      };
    } catch (e) {
      try {
        final filename = p.basenameWithoutExtension(file.path);
        DateTime fileDate;
        try {
          fileDate = file.lastModifiedSync();
        } catch (_) {
          fileDate = DateTime.now();
        }
        final folderArt = await _findFolderArtwork(file.path);
        final song = Song()
          ..path = file.path
          ..title = filename
          ..artist = 'Unknown Artist'
          ..album = 'Unknown Album'
          ..artPath = folderArt
          ..dateAdded = fileDate;
        return {
          'song': song,
          'metadata': Metadata(
            title: filename,
            artist: 'Unknown Artist',
            album: 'Unknown Album',
          ),
          'artPath': folderArt,
        };
      } catch (_) {
        return null;
      }
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
