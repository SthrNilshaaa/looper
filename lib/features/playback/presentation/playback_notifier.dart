import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/library/data/scanner.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:isar/isar.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum RepeatMode { off, all, one }

class PlaybackState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final double volume;

  final bool isScrubbing;
  final List<Song> queue;

  PlaybackState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
    this.isScrubbing = false,
    this.queue = const [],
  });

  PlaybackState copyWith({
    Object? currentSong = _sentinel,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    RepeatMode? repeatMode,
    double? volume,
    bool? isScrubbing,
    List<Song>? queue,
  }) {
    return PlaybackState(
      currentSong: currentSong == _sentinel ? this.currentSong : currentSong as Song?,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      isScrubbing: isScrubbing ?? this.isScrubbing,
      queue: queue ?? this.queue,
    );
  }
}

const _sentinel = Object();

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final Ref ref;
  late final Player player;
  List<Song> _playlist = [];
  int _currentIndex = -1;

  PlaybackNotifier(this.ref) : super(PlaybackState()) {
    player = ref.read(audioServiceProvider).player;
    ref.read(audioServiceProvider).onNext = skipNext;
    ref.read(audioServiceProvider).onPrevious = skipPrevious;
    ref.read(audioServiceProvider).onSeek = (duration) => seek(duration);
    ref.read(audioServiceProvider).onFavoriteToggle = toggleFavorite;
    ref.read(audioServiceProvider).onShuffleToggle = toggleShuffle;
    _init();
  }

  void _updateNotification() {
    final song = state.currentSong;
    if (song != null) {
      ref.read(audioServiceProvider).updatePlaybackState(
        isPlaying: state.isPlaying,
        isFavorite: song.isFavorite,
        isShuffle: state.isShuffle,
      );
    }
  }

  Future<void> _init() async {
    player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
      _updateNotification();
    });

    player.stream.position.listen((position) {
      if (!state.isScrubbing) {
        state = state.copyWith(position: position);
      }
    });

    player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    DateTime? lastCompletedTime;
    player.stream.completed.listen((completed) {
      if (completed) {
        final now = DateTime.now();
        if (lastCompletedTime != null && now.difference(lastCompletedTime!).inMilliseconds < 1000) {
          return;
        }
        lastCompletedTime = now;

        if (state.repeatMode == RepeatMode.one) {
          player.seek(Duration.zero);
          ref.read(audioServiceProvider).resume();
        } else {
          skipNext();
        }
      }
    });

    // Load last settings
    final settings = ref.read(settingsProvider);
    state = state.copyWith(
      volume: settings.volume,
      isShuffle: settings.shuffle,
      repeatMode: RepeatMode.values[settings.repeatMode],
    );
    player.setVolume(settings.volume * 100);

    if (settings.lastPlayedSongId != null) {
      final song = await DbService.isar.songs.get(settings.lastPlayedSongId!);
      if (song != null) {
        state = state.copyWith(currentSong: song);
        _playlist = [song];
        _currentIndex = 0;
      }
    }
  }

  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      await play(_playlist[_currentIndex]);
    }
  }

  void setPlaylist(List<Song> songs, {int initialIndex = 0}) {
    _playlist = List.from(songs);
    if (state.isShuffle) {
      _playlist.shuffle();
      _currentIndex = _playlist.indexWhere(
        (s) => s.path == songs[initialIndex].path,
      );
    } else {
      _currentIndex = initialIndex;
    }
    state = state.copyWith(queue: _playlist);
    if (_playlist.isNotEmpty) {
      play(_playlist[_currentIndex]);
    }
  }

  Future<void> play(Song song) async {
    final settings = ref.read(settingsProvider);
    if (settings.audioFocus) {
      final onCall = await ref.read(audioServiceProvider).isOnCall();
      if (onCall) {
        print('🎵 Cannot play song: Device is currently on a call.');
        return;
      }
    }

    state = state.copyWith(currentSong: song);
    final metadata = {
      'title': song.title,
      'artist': song.artist ?? 'Unknown Artist',
      'album': song.album ?? 'Unknown Album',
      if (song.artPath != null) 'artPath': song.artPath!,
      if (song.duration != null) 'duration': song.duration!,
    };
    await ref.read(audioServiceProvider).play(song.path, metadata: metadata);

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.setTitle(
        'Looper Player - ${song.title} - ${song.artist ?? 'Unknown Artist'}',
      );
    }

    // Broadcast notification on Linux
    if (Platform.isLinux) {
      final notification = LocalNotification(
        title: song.title,
        body:
            '${song.artist ?? 'Unknown Artist'}\n${song.album ?? 'Unknown Album'}',
      );
      await notification.show();
    }
    // Update play history in DB
    await DbService.isar.writeTxn(() async {
      // Find the song in DB by path to ensure we have the correct ID and preserve favorites/history
      final dbSong = await DbService.isar.songs
          .filter()
          .pathEqualTo(song.path)
          .findFirst();

      final songToUpdate = dbSong ?? song;
      songToUpdate.lastPlayed = DateTime.now();
      songToUpdate.playCount++;

      // Update the song object in our state to reflect the latest DB state (especially the ID)
      if (dbSong != null) {
        // If it exists, copy properties to our current song object
        song.id = dbSong.id;
        song.isFavorite = dbSong.isFavorite;
        song.playCount = dbSong.playCount;
        song.lastPlayed = dbSong.lastPlayed;
      }

      await DbService.isar.songs.put(songToUpdate);
    });

    final idx = _playlist.indexWhere((s) => s.path == song.path);
    if (idx != -1) {
      _currentIndex = idx;
    } else {
      // If song not in playlist, add it at current position or at end
      if (_currentIndex == -1) {
        _playlist = [song];
        _currentIndex = 0;
      } else {
        _playlist.insert(_currentIndex + 1, song);
        _currentIndex++;
      }
      state = state.copyWith(queue: List.from(_playlist));
    }
    _updateNotification();
  }

  void addToQueue(Song song) {
    if (_playlist.any((s) => s.path == song.path)) return;
    _playlist.add(song);
    state = state.copyWith(queue: List.from(_playlist));
  }

  void addNext(Song song) {
    // Remove if already in queue to avoid duplicates/unexpected behavior
    _playlist.removeWhere((s) => s.path == song.path);

    final insertIndex = _currentIndex + 1;
    if (insertIndex >= _playlist.length) {
      _playlist.add(song);
    } else {
      _playlist.insert(insertIndex, song);
    }

    state = state.copyWith(queue: List.from(_playlist));
  }

  Future<void> playFromFile(String path) async {
    // Check if song exists in DB
    final songs = await DbService.isar.songs
        .filter()
        .pathEqualTo(path)
        .findAll();
    Song? song = songs.isEmpty ? null : songs.first;

    if (song == null) {
      // Create a temporary song object from metadata
      final metadata = await MetadataGod.readMetadata(file: path);
      // Extract and save artwork
      String? artPath;
      if (metadata.picture != null) {
        final scanner =
            LibraryScanner(); // Need to save it using the same logic
        artPath = await scanner.saveAlbumArt(
          metadata.album ?? 'unknown',
          metadata.picture!.data,
        );
      }

      song = Song()
        ..path = path
        ..title = metadata.title ?? path.split('/').last
        ..artist = metadata.artist
        ..album = metadata.album
        ..duration = metadata.durationMs?.toInt()
        ..artPath = artPath;
    }

    await play(song);
  }

  Future<void> togglePlay() async {
    if (!state.isPlaying) {
      final settings = ref.read(settingsProvider);
      if (settings.audioFocus) {
        final onCall = await ref.read(audioServiceProvider).isOnCall();
        if (onCall) {
          print('🎵 Cannot play/resume: Device is currently on a call.');
          return;
        }
      }
    }

    if (state.isPlaying) {
      await ref.read(audioServiceProvider).pause();
    } else {
      if (player.state.playlist.medias.isEmpty && state.currentSong != null) {
        await play(state.currentSong!);
      } else {
        await ref.read(audioServiceProvider).resume();
      }
    }
  }

  Future<void> skipNext() async {
    if (_playlist.isEmpty) return;
    _currentIndex++;
    if (_currentIndex >= _playlist.length) {
      if (state.repeatMode == RepeatMode.all) {
        _currentIndex = 0;
      } else {
        _currentIndex = _playlist.length - 1;
        await ref.read(audioServiceProvider).pause();
        return;
      }
    }
    await play(_playlist[_currentIndex]);
  }

  Future<void> skipPrevious() async {
    if (_playlist.isEmpty) return;
    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    _currentIndex--;
    if (_currentIndex < 0) {
      if (state.repeatMode == RepeatMode.all) {
        _currentIndex = _playlist.length - 1;
      } else {
        _currentIndex = 0;
      }
    }
    await play(_playlist[_currentIndex]);
  }

  Future<void> seekRelative(int seconds) async {
    Duration newPos = state.position + Duration(seconds: seconds);
    if (newPos < Duration.zero) newPos = Duration.zero;
    if (newPos > state.duration) newPos = state.duration;
    await seek(newPos);
  }

  void adjustVolume(double delta) {
    final newVolume = (state.volume + delta).clamp(0.0, 1.0);
    setVolume(newVolume);
  }

  void toggleShuffle() {
    final newState = !state.isShuffle;
    state = state.copyWith(isShuffle: newState);
    if (newState) {
      _playlist.shuffle();
    }
    state = state.copyWith(queue: _playlist);
    if (state.currentSong != null) {
      _currentIndex = _playlist.indexWhere(
        (s) => s.path == state.currentSong!.path,
      );
    }
    ref.read(settingsProvider.notifier).updateShuffle(newState);
    _updateNotification();
  }

  int songId(Song s) => s.id;

  void nextRepeatMode() {
    final nextMode = RepeatMode
        .values[(state.repeatMode.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeatMode: nextMode);
    ref.read(settingsProvider.notifier).updateRepeatMode(nextMode.index);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
    player.setVolume(volume * 100);
    ref.read(settingsProvider.notifier).updateVolume(volume);
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
    state = state.copyWith(position: position);
  }

  void startScrubbing() {
    state = state.copyWith(isScrubbing: true);
    player.setVolume(0);
  }

  void stopScrubbing() {
    state = state.copyWith(
      isScrubbing: false,
      position: player.state.position,
    );
    player.setVolume(state.volume * 100);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final song = _playlist.removeAt(oldIndex);
    _playlist.insert(newIndex, song);
    state = state.copyWith(queue: List.from(_playlist));
    if (state.currentSong != null) {
      _currentIndex = _playlist.indexWhere((s) => s.path == state.currentSong!.path);
    }
  }

  void removeFromQueue(int index) {
    if (index == _currentIndex) {
      skipNext();
    }
    _playlist.removeAt(index);
    state = state.copyWith(queue: List.from(_playlist));
    if (state.currentSong != null) {
      _currentIndex = _playlist.indexWhere((s) => s.path == state.currentSong!.path);
    }
  }

  void clearQueue() {
    _playlist = [];
    _currentIndex = -1;
    state = PlaybackState(
      volume: state.volume,
      isShuffle: state.isShuffle,
      repeatMode: state.repeatMode,
    );
    player.stop();
  }

  Future<void> toggleFavorite() async {
    final song = state.currentSong;
    if (song == null) return;

    await DbService.isar.writeTxn(() async {
      song.isFavorite = !song.isFavorite;
      await DbService.isar.songs.put(song);
    });

    // Refresh the state to trigger UI updates
    state = state.copyWith(currentSong: song);
    _updateNotification();
  }

  double _lastVolume = 1.0;

  void toggleMute() {
    if (state.volume > 0) {
      _lastVolume = state.volume;
      setVolume(0);
    } else {
      setVolume(_lastVolume > 0 ? _lastVolume : 1.0);
    }
  }

  Future<bool> _requestStoragePermissions() async {
    if (!Platform.isAndroid) return true;
    try {
      // Check if we already have permissions
      if (await Permission.audio.isGranted ||
          await Permission.storage.isGranted ||
          await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Request permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.audio,
        Permission.storage,
      ].request();

      bool isGranted = (statuses[Permission.audio]?.isGranted ?? false) ||
                       (statuses[Permission.storage]?.isGranted ?? false);

      if (!isGranted && await Permission.manageExternalStorage.request().isGranted) {
        isGranted = true;
      }

      return isGranted;
    } catch (e) {
      print('Error requesting storage permissions: $e');
      return true; // Fallback to let the app try physical operations
    }
  }

  Future<bool> renameSong(Song song, String newTitle) async {
    try {
      await _requestStoragePermissions();
    } catch (e) {
      print('Permission request failed: $e');
    }

    final isCurrent = state.currentSong?.id == song.id;
    if (isCurrent) {
      // Temporarily pause playback to release the file handle lock
      await player.pause();
      // Wait for player to completely release the file handle
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final file = File(song.path);
    final dir = file.parent.path;
    final ext = p.extension(song.path);
    final newPath = p.join(dir, '$newTitle$ext');

    bool fileRenamed = false;
    try {
      if (await file.exists()) {
        await file.rename(newPath);
        fileRenamed = true;
      }
    } catch (e) {
      print('Physical file rename failed (continuing with DB update): $e');
    }

    bool dbSuccess = false;
    try {
      await DbService.isar.writeTxn(() async {
        song.title = newTitle;
        song.path = newPath;
        await DbService.isar.songs.put(song);
      });
      dbSuccess = true;

      // Update in-memory queue
      final index = _playlist.indexWhere((s) => s.id == song.id);
      if (index != -1) {
        _playlist[index] = song;
      }

      // Update state if it's the current song
      if (isCurrent) {
        state = state.copyWith(
          currentSong: song,
          queue: List.from(_playlist),
        );
        // Resume playing track from the new path
        await playAtIndex(_currentIndex);
      } else {
        state = state.copyWith(queue: List.from(_playlist));
      }
    } catch (e) {
      print('Error renaming in DB: $e');
    }

    return dbSuccess;
  }

  Future<bool> deleteSong(Song song) async {
    try {
      await _requestStoragePermissions();
    } catch (e) {
      print('Permission request failed: $e');
    }

    final isCurrent = state.currentSong?.id == song.id;
    if (isCurrent) {
      if (_playlist.length > 1) {
        await skipNext();
      } else {
        clearQueue();
      }
      // Wait for player to completely release the file handle
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final file = File(song.path);
    bool fileDeleted = false;
    try {
      if (await file.exists()) {
        await file.delete();
        fileDeleted = true;
      }
    } catch (e) {
      print('Physical file delete failed (continuing with DB delete): $e');
    }

    bool dbSuccess = false;
    try {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.delete(song.id);
      });
      dbSuccess = true;

      _playlist.removeWhere((s) => s.id == song.id);
      state = state.copyWith(queue: List.from(_playlist));

      // Clean up orphaned artists and albums
      await _cleanUpOrphanedArtistsAndAlbums();
    } catch (e) {
      print('Error deleting from DB: $e');
    }

    return dbSuccess;
  }

  Future<void> _cleanUpOrphanedArtistsAndAlbums() async {
    try {
      await DbService.isar.writeTxn(() async {
        final remainingSongs = await DbService.isar.songs.where().findAll();
        final activeAlbumNames = remainingSongs.map((s) => s.album).toSet();
        final activeArtistNames = remainingSongs.map((s) => s.artist).toSet();

        final allAlbums = await DbService.isar.albums.where().findAll();
        final albumsToDelete = allAlbums.where((a) => !activeAlbumNames.contains(a.name)).map((a) => a.id).toList();
        if (albumsToDelete.isNotEmpty) {
          await DbService.isar.albums.deleteAll(albumsToDelete);
        }

        final allArtists = await DbService.isar.artists.where().findAll();
        final artistsToDelete = allArtists.where((art) => !activeArtistNames.contains(art.name)).map((art) => art.id).toList();
        if (artistsToDelete.isNotEmpty) {
          await DbService.isar.artists.deleteAll(artistsToDelete);
        }
      });
    } catch (e) {
      print('Error cleaning up orphaned artists/albums: $e');
    }
  }

  Future<void> shareSong(Song song) async {
    await Share.shareXFiles([XFile(song.path)], text: 'Check out this song: ${song.title}');
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) {
    return PlaybackNotifier(ref);
  },
);
