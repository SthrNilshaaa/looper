import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/logger_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:looper_player/features/library/data/scanner.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/data/artist_image_service.dart';
import 'package:isar_community/isar.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/playback/data/lyrics_fetcher.dart';
import 'dart:async';

enum SongSortStrategy {
  dateAdded,
  title,
  artist,
  album,
  duration,
  year,
  playCount,
  lastPlayed,
}

/// True for a broad storage root such as "/storage/emulated/0" or a raw SD
/// card mount point ("/storage/XXXX-XXXX") - the coarse roots scanned once
/// "all files access" is granted, as opposed to a real per-song folder like
/// "/storage/emulated/0/Music". These must never be recorded in
/// libraryFolders, since scanning them recursively finds songs from every
/// real folder underneath, making the root itself a misleading entry.
bool _isCoarseStorageRoot(String path) {
  final normalized = (path.length > 1 && path.endsWith('/'))
      ? path.substring(0, path.length - 1)
      : path;
  if (normalized == '/storage/emulated/0') return true;
  return RegExp(r'^/storage/[^/]+$').hasMatch(normalized);
}

class LibraryState {
  final bool isScanning;
  final bool isInitialized;
  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;
  final SongSortStrategy sortStrategy;
  final bool isAscending;

  LibraryState({
    this.isScanning = false,
    this.isInitialized = false,
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
    this.sortStrategy = SongSortStrategy.dateAdded,
    this.isAscending = false,
  });

  LibraryState copyWith({
    bool? isScanning,
    bool? isInitialized,
    List<Song>? songs,
    List<Artist>? artists,
    List<Album>? albums,
    List<Playlist>? playlists,
    SongSortStrategy? sortStrategy,
    bool? isAscending,
  }) {
    return LibraryState(
      isScanning: isScanning ?? this.isScanning,
      isInitialized: isInitialized ?? this.isInitialized,
      songs: songs ?? this.songs,
      artists: artists ?? this.artists,
      albums: albums ?? this.albums,
      playlists: playlists ?? this.playlists,
      sortStrategy: sortStrategy ?? this.sortStrategy,
      isAscending: isAscending ?? this.isAscending,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final Ref _ref;
  StreamSubscription<List<Song>>? _songsSubscription;
  bool _isFetchingArtistImages = false;
  bool _isScanRunning = false;

  LibraryNotifier(this._ref) : super(LibraryState()) {
    // Automatically clean up database and refresh songs whenever active library folders change!
    _ref.listen<List<String>>(
      settingsProvider.select((s) => s.libraryFolders),
      (previous, next) async {
        if (previous != null && !listEquals(previous, next)) {
          await syncSongsWithFolders(next);
          _loadLibrary(); // Force-reload lists immediately
        }
      },
      fireImmediately: false,
    );

    _init();
  }

  Future<void> _init() async {
    // Wait for settings to load
    await _ref.read(settingsProvider.notifier).initialization;

    // Load initial sort strategy and order from persisted settings
    final initialSettings = _ref.read(settingsProvider);
    state = state.copyWith(
      sortStrategy: SongSortStrategy.values[initialSettings.sortStrategyIndex],
      isAscending: initialSettings.sortAscending,
    );

    _loadLibrary();
  }

  void _loadLibrary() {
    _watchSongs();
    _watchArtists();
    _watchAlbums();
    _watchPlaylists();
  }

  void setSortStrategy(SongSortStrategy strategy) {
    if (state.sortStrategy == strategy) {
      // Toggle direction if same strategy
      final newAsc = !state.isAscending;
      state = state.copyWith(isAscending: newAsc);
      _ref.read(settingsProvider.notifier).updateSortAscending(newAsc);
    } else {
      state = state.copyWith(sortStrategy: strategy);
      _ref.read(settingsProvider.notifier).updateSortStrategy(strategy.index);
    }
    _watchSongs();
  }

  void toggleSortOrder() {
    final newAsc = !state.isAscending;
    state = state.copyWith(isAscending: newAsc);
    _ref.read(settingsProvider.notifier).updateSortAscending(newAsc);
    _watchSongs();
  }

  QueryBuilder<Song, Song, QAfterSortBy> _buildSongsQuery() {
    final isAsc = state.isAscending;
    switch (state.sortStrategy) {
      case SongSortStrategy.title:
        return isAsc
            ? DbService.isar.songs.where().sortByTitle()
            : DbService.isar.songs.where().sortByTitleDesc();
      case SongSortStrategy.artist:
        return isAsc
            ? DbService.isar.songs.where().sortByArtist().thenByTitle()
            : DbService.isar.songs.where().sortByArtistDesc().thenByTitle();
      case SongSortStrategy.album:
        return isAsc
            ? DbService.isar.songs.where().sortByAlbum().thenByTrackNumber()
            : DbService.isar.songs
                  .where()
                  .sortByAlbumDesc()
                  .thenByTrackNumber();
      case SongSortStrategy.duration:
        return isAsc
            ? DbService.isar.songs.where().sortByDuration()
            : DbService.isar.songs.where().sortByDurationDesc();
      case SongSortStrategy.year:
        return isAsc
            ? DbService.isar.songs.where().sortByYear()
            : DbService.isar.songs.where().sortByYearDesc();
      case SongSortStrategy.playCount:
        return isAsc
            ? DbService.isar.songs.where().sortByPlayCount()
            : DbService.isar.songs.where().sortByPlayCountDesc();
      case SongSortStrategy.lastPlayed:
        return isAsc
            ? DbService.isar.songs.where().sortByLastPlayed()
            : DbService.isar.songs.where().sortByLastPlayedDesc();
      case SongSortStrategy.dateAdded:
      default:
        return isAsc
            ? DbService.isar.songs.where().sortByDateAdded()
            : DbService.isar.songs.where().sortByDateAddedDesc();
    }
  }

  void _watchSongs() {
    _songsSubscription?.cancel();
    _songsSubscription = _buildSongsQuery().watch(fireImmediately: true).listen(
      (songs) {
        state = state.copyWith(songs: songs, isInitialized: true);
      },
    );
  }

  void _watchArtists() {
    DbService.isar.artists
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .listen((artists) {
          state = state.copyWith(artists: artists);
          _fetchMissingArtistImages();
        });
  }

  void _watchAlbums() {
    DbService.isar.albums
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .listen((albums) {
          state = state.copyWith(albums: albums);
        });
  }

  void _watchPlaylists() {
    DbService.isar.playlists
        .where()
        .sortByName()
        .watch(fireImmediately: true)
        .listen((playlists) {
          state = state.copyWith(playlists: playlists);
        });
  }

  Future<void> _fetchMissingArtistImages() async {
    if (_isFetchingArtistImages) return;
    if (state.isScanning) return;

    _isFetchingArtistImages = true;
    try {
      final allArtists = await DbService.isar.artists.where().findAll();
      final artists = allArtists
          .where((a) => a.artistImageUrl == null)
          .toList();
      final service = ArtistImageService();

      for (final artist in artists) {
        // Yield/stop fetching immediately if a library scan starts
        if (state.isScanning) break;
        if (artist.name == 'Unknown Artist') continue;

        final localPath = await service.getArtistImage(artist.name);
        if (localPath != null) {
          await DbService.isar.writeTxn(() async {
            artist.artistImageUrl = localPath;
            await DbService.isar.artists.put(artist);
          });
        }

        // Wait 2.0 seconds between queries to prevent high CPU, power, and bandwidth usage,
        // and to fully comply with Deezer API rate limits.
        await Future.delayed(const Duration(milliseconds: 2000));
      }
    } finally {
      _isFetchingArtistImages = false;
    }
  }

  Future<void> prefetchLibraryLyrics() async {
    final songs = await DbService.isar.songs.where().findAll();
    // Also retries songs previously cached as "not found": LyricsFetcher
    // itself skips the slow/rate-limited online re-check for those (see its
    // cachedAsNotFound handling) but still re-tries the fast, local,
    // no-network embedded-metadata/sidecar-file checks - worth doing here
    // too, since e.g. Android's embedded-lyrics reader didn't exist when
    // some libraries were first scanned.
    final songsToFetch = songs
        .where(
          (s) =>
              s.lyrics == null ||
              s.lyrics!.isEmpty ||
              s.lyrics == '[source:not_found]',
        )
        .toList();

    if (songsToFetch.isEmpty) return;

    state = state.copyWith(isScanning: true);

    // Use a small concurrency limit to avoid overwhelming services
    const int batchSize = 5;
    for (int i = 0; i < songsToFetch.length; i += batchSize) {
      final end = (i + batchSize < songsToFetch.length)
          ? i + batchSize
          : songsToFetch.length;
      final batch = songsToFetch.sublist(i, end);

      await Future.wait(batch.map((song) => LyricsFetcher.fetchLyrics(song)));
    }

    state = state.copyWith(isScanning: false);
  }

  Future<bool> _requestPermissions() async {
    if (!Platform.isAndroid) return true;

    int sdkInt = 0;
    try {
      final sdkMatch = RegExp(
        r'API\s+(\d+)',
      ).firstMatch(Platform.operatingSystemVersion);
      if (sdkMatch != null) {
        sdkInt = int.parse(sdkMatch.group(1)!);
      }
    } catch (_) {}

    // Check if the standard media/storage permission is already granted to
    // bypass a slow OS request dialogue.
    final bool hasAudio = await Permission.audio.isGranted;
    final bool hasStorage = sdkInt < 33 && await Permission.storage.isGranted;

    if (hasAudio || hasStorage) {
      return true;
    }

    if (sdkInt >= 33) {
      return await Permission.audio.request().isGranted;
    } else {
      return await Permission.storage.request().isGranted;
    }
  }

  Future<void> scanSavedFolders({
    bool showVisualIndicator = true,
    bool fullStorageDiscovery = false,
  }) async {
    if (_isScanRunning || state.isScanning) {
      LoggerHelper.write(
        'LibraryNotifier.scanSavedFolders: Scan already in progress, ignoring.',
      );
      return;
    }
    _isScanRunning = true;
    try {
      if (!await _requestPermissions()) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));

      final settings = _ref.read(settingsProvider);
      final savedFolders = settings.libraryFolders;
      List<String> scanRoots = [];

      // Whole-storage discovery is explicit. App startup only refreshes
      // already indexed/default folders and must never start a full scan.
      if (fullStorageDiscovery) {
        if (Platform.isAndroid) {
          try {
            const MethodChannel(
              'com.looper.player/broadcast',
            ).invokeMethod('rescanMedia', {'path': '/storage/emulated/0'});
          } catch (_) {}

          // Raw traversal can no longer reach an arbitrary/whole-storage
          // root or SD cards without MANAGE_EXTERNAL_STORAGE (removed for
          // Play Store compliance - see AndroidManifest.xml). Scoped storage
          // still allows raw listing of these specific top-level public
          // directories with just READ_MEDIA_AUDIO/READ_EXTERNAL_STORAGE;
          // everything else (custom folders, SD cards, formats MediaStore
          // doesn't index) is covered by the MediaStore + SAF merges inside
          // LibraryScanner.scanDirectory() instead, not by walking more
          // scanRoots here.
          final List<String> commonPaths = [
            '/storage/emulated/0/Music',
            '/storage/emulated/0/Download',
            '/storage/emulated/0/Documents',
            '/storage/emulated/0/Audiobooks',
            '/storage/emulated/0/Podcasts',
            '/storage/emulated/0/DCIM',
            '/storage/emulated/0/Recordings',
            '/storage/emulated/0/Bluetooth',
          ];
          for (final cp in commonPaths) {
            if (Directory(cp).existsSync() && !scanRoots.contains(cp)) {
              scanRoots.add(cp);
            }
          }
        } else if (Platform.isLinux) {
          String defaultPath = '${Platform.environment['HOME']}/Music';
          try {
            final result = await Process.run('xdg-user-dir', ['MUSIC']);
            if (result.exitCode == 0 &&
                result.stdout.toString().trim().isNotEmpty) {
              defaultPath = result.stdout.toString().trim();
            }
          } catch (_) {}
          scanRoots.add(defaultPath);
        }

        for (final f in savedFolders) {
          if (Directory(f).existsSync() && !scanRoots.contains(f)) {
            scanRoots.add(f);
          }
        }
      } else {
        // Standard refresh / Pull-to-refresh / Rescan Library: Scan ONLY saved folders (or defaults if none saved)
        if (savedFolders.isNotEmpty) {
          for (final f in savedFolders) {
            if (Directory(f).existsSync() && !scanRoots.contains(f)) {
              scanRoots.add(f);
            }
          }
        } else {
          // Default fallback if savedFolders is empty
          if (Platform.isAndroid) {
            final List<String> commonPaths = [
              '/storage/emulated/0/Music',
              '/storage/emulated/0/Download',
              '/storage/emulated/0/Documents',
            ];
            for (final cp in commonPaths) {
              if (Directory(cp).existsSync()) {
                scanRoots.add(cp);
              }
            }
          } else if (Platform.isLinux) {
            scanRoots.add('${Platform.environment['HOME']}/Music');
          }
        }
      }

      if (scanRoots.isEmpty) {
        scanRoots.add('/storage/emulated/0');
      }

      if (showVisualIndicator) {
        state = state.copyWith(isScanning: true);
      }

      final Set<String> allDiscoveredFolders = Set<String>.from(savedFolders);

      for (final path in scanRoots) {
        if (Directory(path).existsSync()) {
          final result = await LibraryScanner().scanDirectory(path);
          if (result.songsCount > 0) {
            allDiscoveredFolders.addAll(result.musicFolders);
          }
        }
      }

      // Execute Post-Scan Cleanup Filter
      await LibraryScanner().cleanupFilteredAudio(
        includeSystemAndMessagingAudio: settings.includeSystemAndMessagingAudio,
      );

      // Rebuild libraryFolders from allDiscoveredFolders (previously-saved
      // folders + the real per-song folders LibraryScanner just found),
      // dropping any that no longer exist/contain songs, and dropping any
      // broad storage-root entries (e.g. "/storage/emulated/0" recorded by
      // an older buggy scan) in favor of the actual folders inside them.
      final candidateFolders = allDiscoveredFolders.where(
        (f) => !_isCoarseStorageRoot(f),
      );
      if (candidateFolders.isNotEmpty) {
        final List<String> validFolders = [];
        for (final folder in candidateFolders) {
          final prefix = folder.endsWith('/') ? folder : '$folder/';
          final hasSongs =
              await DbService.isar.songs
                  .filter()
                  .pathStartsWith(prefix)
                  .or()
                  .pathEqualTo(folder)
                  .count() >
              0;
          // Not gated on Directory(folder).existsSync(): a folder added via
          // the SAF picker is a real path, but scoped storage's raw stat()
          // can still deny it even with a valid persisted SAF grant (that
          // grant is only honored through the ContentResolver/DocumentsContract
          // door, not dart:io's). hasSongs alone is sufficient - it already
          // naturally drops to 0 once a folder's songs stop being discovered
          // on a later scan pass.
          if (hasSongs) {
            validFolders.add(folder);
          }
        }
        await _ref
            .read(settingsProvider.notifier)
            .updateLibraryFolders(validFolders);
      }

      // Fetch fresh songs, albums, artists, and playlists directly from Isar DB
      final freshSongs = await _buildSongsQuery().findAll();
      final freshAlbums = await DbService.isar.albums
          .where()
          .sortByName()
          .findAll();
      final freshArtists = await DbService.isar.artists
          .where()
          .sortByName()
          .findAll();
      final freshPlaylists = await DbService.isar.playlists
          .where()
          .sortByName()
          .findAll();

      state = state.copyWith(
        songs: freshSongs,
        albums: freshAlbums,
        artists: freshArtists,
        playlists: freshPlaylists,
        isScanning: false,
        isInitialized: true,
      );

      // Force-reload stream listeners for continuous updates
      _loadLibrary();
    } finally {
      _isScanRunning = false;
    }
  }

  Future<void> clearAllData() async {
    await DbService.isar.writeTxn(() async {
      await DbService.isar.songs.clear();
      await DbService.isar.albums.clear();
      await DbService.isar.artists.clear();
      await DbService.isar.playlists.clear();
    });
    await _ref.read(settingsProvider.notifier).updateLibraryFolders([]);
    await _ref.read(settingsProvider.notifier).updateLastPlayedSong(null);
  }

  Future<void> resetAndRescan() async {
    if (!await _requestPermissions()) return;
    state = state.copyWith(isScanning: true);
    await DbService.isar.writeTxn(() async {
      await DbService.isar.songs.clear();
      await DbService.isar.albums.clear();
      await DbService.isar.artists.clear();
    });
    await _ref.read(settingsProvider.notifier).updateLastPlayedSong(null);

    await scanSavedFolders(
      showVisualIndicator: true,
      fullStorageDiscovery: true,
    );
  }

  Future<int> scanLibrary(
    String path, {
    bool updateIsScanning = true,
    // False for a broad/coarse root (e.g. the whole internal storage root
    // scanned once "all files access" is granted) - recording that root
    // itself in libraryFolders would show the user "0" / "/storage/emulated/0"
    // instead of the actual folders their music lives in. Use
    // recordActualLibraryFolders() afterwards to record the real folders.
    bool recordFolder = true,
  }) async {
    if (!await _requestPermissions()) return 0;

    if (updateIsScanning) {
      state = state.copyWith(isScanning: true);
    }
    int totalSongsFound = 0;

    try {
      // Not gated on Directory(path).existsSync(): a folder added via the
      // SAF picker is a real path, but scoped storage's raw stat() can deny
      // it even with a valid persisted SAF grant (dart:io never goes through
      // the ContentResolver/DocumentsContract door that grant is honored
      // through). scanDirectory() already degrades gracefully for a path it
      // can't list directly - the MediaStore + SAF merges inside it still
      // find the folder's songs regardless.
      final result = await LibraryScanner().scanDirectory(path);
      totalSongsFound = result.songsCount;

      if (totalSongsFound > 0) {
        final settings = _ref.read(settingsProvider);
        final newFolders = Set<String>.from(settings.libraryFolders);
        if (recordFolder) {
          newFolders.add(path);
        } else {
          // Store actual song folders immediately for a broad root scan so
          // an interrupted discovery cannot leave this list empty.
          newFolders.addAll(result.musicFolders);
        }
        await _ref
            .read(settingsProvider.notifier)
            .updateLibraryFolders(newFolders.toList());
      }
    } catch (e) {
      LoggerHelper.write(
        'LibraryNotifier.scanLibrary: error scanning path $path',
        e,
      );
    }

    if (updateIsScanning) {
      state = state.copyWith(isScanning: false);
    }

    return totalSongsFound;
  }

  /// Recomputes libraryFolders from the actual parent folder of every song
  /// currently in the library, merging them into the existing list. Use this
  /// after a coarse/broad root scan (scanLibrary(..., recordFolder: false))
  /// so the "Library Folders" list shows the real folders songs live in
  /// (e.g. "Music", "Songs") instead of the broad root that was scanned.
  Future<void> recordActualLibraryFolders() async {
    final songs = await DbService.isar.songs.where().findAll();
    if (songs.isEmpty) return;

    final settings = _ref.read(settingsProvider);
    final newFolders = Set<String>.from(settings.libraryFolders);
    for (final song in songs) {
      newFolders.add(Directory(song.path).parent.path);
    }

    if (newFolders.length != settings.libraryFolders.length) {
      await _ref
          .read(settingsProvider.notifier)
          .updateLibraryFolders(newFolders.toList());
    }
  }

  Future<void> toggleFavorite(Song song) async {
    await DbService.isar.writeTxn(() async {
      // Direct ID lookup is safer to ensure we're updating the correct record
      final dbSong = await DbService.isar.songs.get(song.id);
      if (dbSong != null) {
        dbSong.isFavorite = !dbSong.isFavorite;
        await DbService.isar.songs.put(dbSong);
      } else {
        // Fallback for songs not yet in DB (e.g. played from file)
        song.isFavorite = !song.isFavorite;
        await DbService.isar.songs.put(song);
      }
    });
  }

  Future<void> syncSongsWithFolders(List<String> activeFolders) async {
    await DbService.isar.writeTxn(() async {
      // Find all songs in the DB
      final allSongs = await DbService.isar.songs.where().findAll();

      // Filter songs that do NOT belong to any of the active folders
      final songsToDelete = allSongs.where((song) {
        return !activeFolders.any((folder) => song.path.startsWith(folder));
      }).toList();

      if (songsToDelete.isNotEmpty) {
        final idsToDelete = songsToDelete.map((s) => s.id).toList();
        await DbService.isar.songs.deleteAll(idsToDelete);

        // Clean up empty albums & artists
        final remainingSongs = await DbService.isar.songs.where().findAll();
        final activeAlbumNames = remainingSongs.map((s) => s.album).toSet();
        final activeArtistNames = remainingSongs.map((s) => s.artist).toSet();

        // Load all albums and artists
        final allAlbums = await DbService.isar.albums.where().findAll();
        final albumsToDelete = allAlbums
            .where((a) => !activeAlbumNames.contains(a.name))
            .map((a) => a.id)
            .toList();
        if (albumsToDelete.isNotEmpty) {
          await DbService.isar.albums.deleteAll(albumsToDelete);
        }

        final allArtists = await DbService.isar.artists.where().findAll();
        final artistsToDelete = allArtists
            .where((art) => !activeArtistNames.contains(art.name))
            .map((art) => art.id)
            .toList();
        if (artistsToDelete.isNotEmpty) {
          await DbService.isar.artists.deleteAll(artistsToDelete);
        }
      }
    });
  }

  /// Edits an album's metadata (name, artist, year, artwork) and cascades the
  /// change to every song currently tagged with this album, since songs only
  /// reference their album by name rather than a foreign key. Does NOT touch
  /// the physical files — only the DB records (same contract as
  /// [PlaybackNotifier.editSongMetadata] for individual songs).
  Future<bool> editAlbumMetadata(
    Album album, {
    String? name,
    String? artist,
    int? year,
    String? artPath, // null = unchanged, '' = cleared, '/path' = new artwork
  }) async {
    try {
      await DbService.isar.writeTxn(() async {
        final songs = await DbService.isar.songs
            .filter()
            .albumEqualTo(album.name)
            .findAll();

        final newName = (name != null && name.trim().isNotEmpty)
            ? name.trim()
            : null;

        // Renaming onto another existing album's name merges into that
        // album (adopting its identity) instead of colliding with the
        // unique name index or leaving two entries for the same album.
        Album target = album;
        if (newName != null && newName != album.name) {
          final existing = await DbService.isar.albums
              .filter()
              .nameEqualTo(newName)
              .findFirst();
          if (existing != null && existing.id != album.id) {
            await DbService.isar.albums.delete(album.id);
            target = existing;
          }
        }

        target.name = newName ?? target.name;
        if (artist != null) {
          target.artist = artist.trim().isEmpty ? null : artist.trim();
        }
        if (year != null) target.year = year == 0 ? null : year;
        if (artPath != null) {
          target.artPath = artPath.trim().isEmpty ? null : artPath.trim();
        }
        await DbService.isar.albums.put(target);

        // Cascade name/artist/year to every song that belonged to the (old)
        // album so the library's text metadata stays consistent. Artwork is
        // deliberately NOT cascaded: a song's own artPath is what the mini
        // player, queue and song lists show for it, and songs can carry
        // their own custom/embedded art independent of the album cover -
        // overwriting it here made picking a new album cover silently
        // replace every song's picture too.
        for (final song in songs) {
          song.album = target.name;
          if (artist != null) song.artist = target.artist;
          if (year != null) song.year = target.year;
        }
        if (songs.isNotEmpty) {
          await DbService.isar.songs.putAll(songs);
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _songsSubscription?.cancel();
    super.dispose();
  }
}

final libraryProvider = StateNotifierProvider<LibraryNotifier, LibraryState>((
  ref,
) {
  return LibraryNotifier(ref);
});

final recentlyPlayedProvider = StreamProvider<List<Song>>((ref) {
  return DbService.isar.songs
      .where()
      .filter()
      .lastPlayedIsNotNull()
      .sortByLastPlayedDesc()
      .limit(10)
      .watch(fireImmediately: true);
});

final topSongsProvider = StreamProvider<List<Song>>((ref) {
  return DbService.isar.songs
      .where()
      .sortByPlayCountDesc()
      .limit(8)
      .watch(fireImmediately: true);
});
