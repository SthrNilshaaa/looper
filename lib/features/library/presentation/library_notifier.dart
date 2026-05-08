import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/data/scanner.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/library/data/artist_image_service.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';

class LibraryState {
  final bool isScanning;
  final List<Song> songs;

  LibraryState({this.isScanning = false, this.songs = const []});

  LibraryState copyWith({bool? isScanning, List<Song>? songs}) {
    return LibraryState(
      isScanning: isScanning ?? this.isScanning,
      songs: songs ?? this.songs,
    );
  }
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  final Ref _ref;

  LibraryNotifier(this._ref) : super(LibraryState()) {
    _loadSongs();
  }

  void _loadSongs() {
    DbService.isar.songs
        .where()
        .sortByDateAddedDesc()
        .watch(fireImmediately: true)
        .listen((songs) {
          state = state.copyWith(songs: songs);
          _fetchMissingArtistImages();
        });
  }

  Future<void> _fetchMissingArtistImages() async {
    final allArtists = await DbService.isar.artists.where().findAll();
    final artists = allArtists.where((a) => a.artistImageUrl == null).toList();
    final service = ArtistImageService();

    for (final artist in artists) {
      if (artist.name == 'Unknown Artist') continue;
      final imageUrl = await service.getArtistImage(artist.name);
      if (imageUrl != null) {
        await DbService.isar.writeTxn(() async {
          artist.artistImageUrl = imageUrl;
          await DbService.isar.artists.put(artist);
        });
      }
    }
  }

  Future<void> scanSavedFolders() async {
    final folders = _ref.read(settingsProvider).libraryFolders;
    if (folders.isEmpty) {
      // If no folders saved, try default Music dir
      String defaultPath = '${Platform.environment['HOME']}/Music';
      if (Platform.isLinux) {
        try {
          final result = await Process.run('xdg-user-dir', ['MUSIC']);
          if (result.exitCode == 0 &&
              result.stdout.toString().trim().isNotEmpty) {
            defaultPath = result.stdout.toString().trim();
          }
        } catch (_) {
          // Fallback to ~/Music if xdg-user-dir fails
        }
      }

      if (Directory(defaultPath).existsSync()) {
        await scanLibrary(defaultPath);
      }
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

  Future<void> scanLibrary(String path) async {
    state = state.copyWith(isScanning: true);

    if (Directory(path).existsSync()) {
      // Add to saved folders if not already there
      final settings = _ref.read(settingsProvider);
      if (!settings.libraryFolders.contains(path)) {
        final newFolders = List<String>.from(settings.libraryFolders)
          ..add(path);
        await _ref
            .read(settingsProvider.notifier)
            .updateLibraryFolders(newFolders);
      }

      await LibraryScanner().scanDirectory(path);
    }
    state = state.copyWith(isScanning: false);
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
