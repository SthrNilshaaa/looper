import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:looper_player/features/library/data/scanner.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/data/artist_image_service.dart';
import 'package:isar/isar.dart';
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

class LibraryState {
  final bool isScanning;
  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final List<Playlist> playlists;
  final SongSortStrategy sortStrategy;
  final bool isAscending;

  LibraryState({
    this.isScanning = false,
    this.songs = const [],
    this.artists = const [],
    this.albums = const [],
    this.playlists = const [],
    this.sortStrategy = SongSortStrategy.dateAdded,
    this.isAscending = false,
  });

  LibraryState copyWith({
    bool? isScanning,
    List<Song>? songs,
    List<Artist>? artists,
    List<Album>? albums,
    List<Playlist>? playlists,
    SongSortStrategy? sortStrategy,
    bool? isAscending,
  }) {
    return LibraryState(
      isScanning: isScanning ?? this.isScanning,
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

  LibraryNotifier(this._ref) : super(LibraryState()) {
    _loadLibrary();

    // Automatically clean up database and refresh songs whenever active library folders change!
    _ref.listen<List<String>>(
      settingsProvider.select((s) => s.libraryFolders),
      (previous, next) async {
        if (previous != null && previous != next) {
          print('📂 LibraryNotifier: Library folders changed. Syncing database...');
          await syncSongsWithFolders(next);
          _loadLibrary(); // Force-reload lists immediately
        }
      },
      fireImmediately: false,
    );
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
      state = state.copyWith(isAscending: !state.isAscending);
    } else {
      state = state.copyWith(sortStrategy: strategy);
    }
    _watchSongs();
  }

  void toggleSortOrder() {
    state = state.copyWith(isAscending: !state.isAscending);
    _watchSongs();
  }

  void _watchSongs() {
    _songsSubscription?.cancel();
    
    QueryBuilder<Song, Song, QAfterSortBy> query;
    final isAsc = state.isAscending;

    switch (state.sortStrategy) {
      case SongSortStrategy.title:
        query = isAsc
            ? DbService.isar.songs.where().sortByTitle()
            : DbService.isar.songs.where().sortByTitleDesc();
        break;
      case SongSortStrategy.artist:
        query = isAsc
            ? DbService.isar.songs.where().sortByArtist().thenByTitle()
            : DbService.isar.songs.where().sortByArtistDesc().thenByTitle();
        break;
      case SongSortStrategy.album:
        query = isAsc
            ? DbService.isar.songs.where().sortByAlbum().thenByTrackNumber()
            : DbService.isar.songs.where().sortByAlbumDesc().thenByTrackNumber();
        break;
      case SongSortStrategy.duration:
        query = isAsc
            ? DbService.isar.songs.where().sortByDuration()
            : DbService.isar.songs.where().sortByDurationDesc();
        break;
      case SongSortStrategy.year:
        query = isAsc
            ? DbService.isar.songs.where().sortByYear()
            : DbService.isar.songs.where().sortByYearDesc();
        break;
      case SongSortStrategy.playCount:
        query = isAsc
            ? DbService.isar.songs.where().sortByPlayCount()
            : DbService.isar.songs.where().sortByPlayCountDesc();
        break;
      case SongSortStrategy.lastPlayed:
        query = isAsc
            ? DbService.isar.songs.where().sortByLastPlayed()
            : DbService.isar.songs.where().sortByLastPlayedDesc();
        break;
      case SongSortStrategy.dateAdded:
      default:
        query = isAsc
            ? DbService.isar.songs.where().sortByDateAdded()
            : DbService.isar.songs.where().sortByDateAddedDesc();
        break;
    }

    _songsSubscription = query.watch(fireImmediately: true).listen((songs) {
      state = state.copyWith(songs: songs);
    });
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
      final artists = allArtists.where((a) => a.artistImageUrl == null).toList();
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
    } catch (e) {
      print('Error in background artist image fetch: $e');
    } finally {
      _isFetchingArtistImages = false;
    }
  }

  Future<void> prefetchLibraryLyrics() async {
    final songs = await DbService.isar.songs.where().findAll();
    final songsToFetch = songs.where((s) => s.lyrics == null || s.lyrics!.isEmpty).toList();
    
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

    // Check if standard or manage external storage permissions are already granted
    // to bypass all slow OS request dialogues entirely.
    if (await Permission.audio.isGranted || 
        await Permission.storage.isGranted || 
        await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // 1. Request Notification permission (required for Android 13+)
    await Permission.notification.request();

    // 2. Check for "All Files Access" (Android 11+)
    // This is the most powerful permission and usually what users mean by "all files"
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    // 3. Request granular media permissions for Android 13+ (API 33+)
    // or standard storage permission for Android 12 and below
    Map<Permission, PermissionStatus> statuses = await [
      Permission.audio,
      Permission.storage,
    ].request();

    bool isGranted = (statuses[Permission.audio]?.isGranted ?? false) || 
                     (statuses[Permission.storage]?.isGranted ?? false);

    // If still not granted, try requesting manageExternalStorage explicitly
    if (!isGranted) {
      isGranted = await Permission.manageExternalStorage.request().isGranted;
    }

    return isGranted;
  }

  Future<void> scanSavedFolders() async {
    if (!await _requestPermissions()) {
      print('❌ Permissions denied');
      return;
    }
    final folders = _ref.read(settingsProvider).libraryFolders;
    
    if (folders.isEmpty) {
      // If no folders saved, try to discover music in common locations
      List<String> scanRoots = [];
      
      if (Platform.isLinux) {
        String defaultPath = '${Platform.environment['HOME']}/Music';
        try {
          final result = await Process.run('xdg-user-dir', ['MUSIC']);
          if (result.exitCode == 0 &&
              result.stdout.toString().trim().isNotEmpty) {
            defaultPath = result.stdout.toString().trim();
          }
        } catch (_) {}
        scanRoots.add(defaultPath);
      } else if (Platform.isAndroid) {
        // Start with common folders
        final List<String> commonPaths = [
          '/storage/emulated/0/Music',
          '/storage/emulated/0/Download',
          '/storage/emulated/0/Documents',
          '/storage/emulated/0/Audiobooks',
          '/storage/emulated/0/Podcasts',
        ];

        // If we have "All Files Access", we can just scan the root /storage/emulated/0
        // to find music in non-standard folders (Telegram, WhatsApp, etc.)
        if (await Permission.manageExternalStorage.isGranted) {
          scanRoots.add('/storage/emulated/0');
        } else {
          scanRoots.addAll(commonPaths);
        }

        // Try to find SD cards
        try {
          final storageDir = Directory('/storage');
          if (await storageDir.exists()) {
            final List<FileSystemEntity> entities = await storageDir.list().toList();
            for (final entity in entities) {
              final name = p.context.basename(entity.path);
              // Avoid emulated and system internal paths
              if (name != 'emulated' && name != 'self' && name != 'knox-emulated' && !name.contains('-')) {
                // This is likely an SD card mount point
                if (await Permission.manageExternalStorage.isGranted) {
                  scanRoots.add(entity.path);
                } else {
                  scanRoots.add('${entity.path}/Music');
                  scanRoots.add('${entity.path}/Download');
                }
              }
            }
          }
        } catch (e) {
          print('⚠️ Error searching for SD cards: $e');
        }
      }

      state = state.copyWith(isScanning: true);
      for (final path in scanRoots) {
        if (Directory(path).existsSync()) {
          await scanLibrary(path, updateIsScanning: false);
        }
      }
      state = state.copyWith(isScanning: false);
      return;
    }

    state = state.copyWith(isScanning: true);
    for (final folder in folders) {
      if (Directory(folder).existsSync()) {
        await LibraryScanner().scanDirectory(folder);
      }
    }
    state = state.copyWith(isScanning: false);
  }

  Future<void> resetAndRescan() async {
    if (!await _requestPermissions()) return;
    state = state.copyWith(isScanning: true);
    await DbService.isar.writeTxn(() async {
      await DbService.isar.songs.clear();
      await DbService.isar.albums.clear();
      await DbService.isar.artists.clear();
    });

    final folders = _ref.read(settingsProvider).libraryFolders;
    for (final folder in folders) {
      if (Directory(folder).existsSync()) {
        await LibraryScanner().scanDirectory(folder);
      }
    }
    state = state.copyWith(isScanning: false);
  }

  Future<int> scanLibrary(String path, {bool updateIsScanning = true}) async {
    if (!await _requestPermissions()) return 0;
    print('📂 Starting scan for: $path');
    if (updateIsScanning) {
      state = state.copyWith(isScanning: true);
    }
    int totalSongsFound = 0;

    try {
      final dir = Directory(path);
      if (dir.existsSync()) {
        print('✅ Directory exists: $path');
        final result = await LibraryScanner().scanDirectory(path);
        totalSongsFound = result.songsCount;
        
        if (totalSongsFound > 0) {
          // Add the root folder and all subfolders where music was actually found!
          final settings = _ref.read(settingsProvider);
          final newFolders = Set<String>.from(settings.libraryFolders)
            ..add(path)
            ..addAll(result.musicFolders);
          await _ref
              .read(settingsProvider.notifier)
              .updateLibraryFolders(newFolders.toList());
          print('📁 Added folders & subfolders to library: $path ($totalSongsFound songs across ${result.musicFolders.length} folders)');
        } else {
          print('ℹ️ No music found in: $path (not adding to settings)');
        }
      } else {
        print('❌ Directory does NOT exist or is inaccessible: $path');
      }
    } catch (e) {
      print('❌ Error during scan: $e');
    }

    if (updateIsScanning) {
      state = state.copyWith(isScanning: false);
    }
    print('🏁 Scan finished for: $path');
    return totalSongsFound;
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
        print('🧹 LibraryNotifier: Deleted ${idsToDelete.length} songs that belong to removed folders.');
        
        // Clean up empty albums & artists
        final remainingSongs = await DbService.isar.songs.where().findAll();
        final activeAlbumNames = remainingSongs.map((s) => s.album).toSet();
        final activeArtistNames = remainingSongs.map((s) => s.artist).toSet();
        
        // Load all albums and artists
        final allAlbums = await DbService.isar.albums.where().findAll();
        final albumsToDelete = allAlbums.where((a) => !activeAlbumNames.contains(a.name)).map((a) => a.id).toList();
        if (albumsToDelete.isNotEmpty) {
          await DbService.isar.albums.deleteAll(albumsToDelete);
          print('🧹 LibraryNotifier: Cleaned up ${albumsToDelete.length} orphaned albums.');
        }

        final allArtists = await DbService.isar.artists.where().findAll();
        final artistsToDelete = allArtists.where((art) => !activeArtistNames.contains(art.name)).map((art) => art.id).toList();
        if (artistsToDelete.isNotEmpty) {
          await DbService.isar.artists.deleteAll(artistsToDelete);
          print('🧹 LibraryNotifier: Cleaned up ${artistsToDelete.length} orphaned artists.');
        }
      }
    });
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
