import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:looper_player/l10n/app_localizations.dart';
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

enum FileActionResult { success, dbOnly, failure }

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
  bool _isTransitioning = false;
  bool _autoCrossfadeTriggered = false;
  bool _isLastPlayManual = true;
  int _activeCrossfadeId = 0;
  int _activeSeekId = 0;
  int _activePlayPauseId = 0;
  bool? _targetPlayingState;

  PlaybackNotifier(this.ref) : super(PlaybackState()) {
    player = ref.read(audioServiceProvider).player;
    ref.read(audioServiceProvider).onNext = skipNext;
    ref.read(audioServiceProvider).onPrevious = skipPrevious;
    ref.read(audioServiceProvider).onSeek = (duration) => seek(duration);
    ref.read(audioServiceProvider).onFavoriteToggle = toggleFavorite;
    ref.read(audioServiceProvider).onShuffleToggle = toggleShuffle;
    ref.read(audioServiceProvider).onPlay = () {
      if (!state.isPlaying) togglePlay();
    };
    ref.read(audioServiceProvider).onPause = () {
      if (state.isPlaying) togglePlay();
    };
    ref.read(audioServiceProvider).onPlayPause = togglePlay;
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
      if (_isTransitioning && !playing) {
        // Ignore temporary pause/stop events while transitioning/opening a new song
        return;
      }
      state = state.copyWith(isPlaying: playing);
      _updateNotification();
    });

    player.stream.position.listen((position) {
      if (!state.isScrubbing) {
        state = state.copyWith(position: position);
      }

      // Check for auto-crossfade trigger
      final settings = ref.read(settingsProvider);
      if (settings.enableCrossfade && 
          settings.crossfadeLength > 0 && 
          state.duration > Duration(milliseconds: settings.crossfadeLength + 1000) && 
          state.repeatMode != RepeatMode.one &&
          !_isTransitioning &&
          !_autoCrossfadeTriggered) {
        final remaining = state.duration - position;
        if (remaining.inMilliseconds <= settings.crossfadeLength) {
          _autoCrossfadeTriggered = true;
          _isLastPlayManual = false;
          skipNext();
        }
      }
    });

    player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    DateTime? lastCompletedTime;
    player.stream.completed.listen((completed) {
      if (completed) {
        if (_isTransitioning) return;
        final now = DateTime.now();
        if (lastCompletedTime != null && now.difference(lastCompletedTime!).inMilliseconds < 1000) {
          return;
        }
        lastCompletedTime = now;

        // If auto-crossfade was already triggered, don't trigger skipNext again
        if (_autoCrossfadeTriggered) {
          _autoCrossfadeTriggered = false;
          return;
        }

        _isLastPlayManual = false;

        final settings = ref.read(settingsProvider);
        if (settings.silenceBetweenTracks > 0) {
          Future.delayed(Duration(milliseconds: settings.silenceBetweenTracks), () {
            if (state.repeatMode == RepeatMode.one) {
              player.seek(Duration.zero);
              ref.read(audioServiceProvider).resume();
            } else {
              skipNext();
            }
          });
        } else {
          if (state.repeatMode == RepeatMode.one) {
            player.seek(Duration.zero);
            ref.read(audioServiceProvider).resume();
          } else {
            skipNext();
          }
        }
      }
    });

    // Wait for settings to load
    await ref.read(settingsProvider.notifier).initialization;

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
        if (settings.resumeOnStart) {
          Future.delayed(const Duration(milliseconds: 500), () {
            play(song, forceDisableCrossfade: true);
          });
        }
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

  Future<void> play(Song song, {bool forceDisableCrossfade = false}) async {
    final settings = ref.read(settingsProvider);
    if (settings.audioFocus) {
      final onCall = await ref.read(audioServiceProvider).isOnCall();
      if (onCall) {
        print('🎵 Cannot play song: Device is currently on a call.');
        _showErrorSnackBar(
          'Playback blocked: Cannot play music during an active call',
          (l10n) => l10n.activeCallCannotPlay,
        );
        return;
      }
    }

    final crossfadeId = ++_activeCrossfadeId;
    final audioSvc = ref.read(audioServiceProvider);

    // Cancel any active volume fades on both players
    audioSvc.cancelFade(player);
    audioSvc.cancelFade(audioSvc.player2);
    // Always stop player2 when starting a new play sequence
    audioSvc.player2.stop();

    final currentSong = state.currentSong;
    final int fadeMs = _isLastPlayManual 
        ? settings.shortManualCrossfadeLength 
        : settings.crossfadeLength;

    _isTransitioning = true;

    try {
      if (settings.enableCrossfade && 
          currentSong != null && 
          currentSong.path != song.path &&
          fadeMs > 0 && 
          !forceDisableCrossfade) {
        
        _autoCrossfadeTriggered = false;
        final currentPos = player.state.position;
        final currentVol = state.volume;
        
        final oldMetadata = {
          'title': currentSong.title,
          'artist': currentSong.artist ?? 'Unknown Artist',
          'album': currentSong.album ?? 'Unknown Album',
          if (currentSong.artPath != null) 'artPath': currentSong.artPath!,
          if (currentSong.duration != null) 'duration': currentSong.duration!,
        };
        
        await audioSvc.player2.open(
          Media(currentSong.path, extras: oldMetadata.map((k, v) => MapEntry(k, v.toString()))),
          play: false,
        );
        if (crossfadeId != _activeCrossfadeId) {
          await audioSvc.player2.stop();
          return;
        }
        
        await audioSvc.player2.seek(currentPos);
        audioSvc.player2.setVolume(currentVol * 100);
        await audioSvc.player2.play();
        if (crossfadeId != _activeCrossfadeId) {
          await audioSvc.player2.stop();
          return;
        }

        player.setVolume(0.0);
        await _playDirect(song, crossfadeId);
        if (crossfadeId != _activeCrossfadeId) return;

        final duration = Duration(milliseconds: fadeMs);
        await Future.wait([
          audioSvc.fadeVolume(audioSvc.player2, currentVol, 0.0, duration),
          audioSvc.fadeVolume(player, 0.0, currentVol, duration),
        ]);

        if (crossfadeId != _activeCrossfadeId) return;

        await audioSvc.player2.stop();
        player.setVolume(state.volume * 100);
      } else {
        await _playDirect(song, crossfadeId);
      }
    } catch (e) {
      print('Error in play: $e');
      if (crossfadeId == _activeCrossfadeId) {
        player.setVolume(state.volume * 100);
        await _playDirect(song, crossfadeId);
      }
    } finally {
      if (crossfadeId == _activeCrossfadeId) {
        _isTransitioning = false;
      }
    }
  }

  Future<void> _playDirect(Song song, int crossfadeId) async {
    _autoCrossfadeTriggered = false;
    state = state.copyWith(currentSong: song);
    final metadata = {
      'title': song.title,
      'artist': song.artist ?? 'Unknown Artist',
      'album': song.album ?? 'Unknown Album',
      if (song.artPath != null) 'artPath': song.artPath!,
      if (song.duration != null) 'duration': song.duration!,
    };
    await ref.read(audioServiceProvider).play(song.path, metadata: metadata);

    if (crossfadeId != _activeCrossfadeId) return;

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      await windowManager.setTitle(
        'Looper Player - ${song.title} - ${song.artist ?? 'Unknown Artist'}',
      );
    }

    if (Platform.isLinux) {
      final notification = LocalNotification(
        title: song.title,
        body: '${song.artist ?? 'Unknown Artist'}\n${song.album ?? 'Unknown Album'}',
      );
      await notification.show();
    }

    await DbService.isar.writeTxn(() async {
      final dbSong = await DbService.isar.songs
          .filter()
          .pathEqualTo(song.path)
          .findFirst();

      final songToUpdate = dbSong ?? song;
      songToUpdate.lastPlayed = DateTime.now();
      songToUpdate.playCount++;

      if (dbSong != null) {
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
    final settings = ref.read(settingsProvider);
    
    // Determine the next target state
    final currentPlaying = _targetPlayingState ?? state.isPlaying;
    final targetPlaying = !currentPlaying;
    _targetPlayingState = targetPlaying;

    if (targetPlaying) {
      if (settings.audioFocus) {
        final onCall = await ref.read(audioServiceProvider).isOnCall();
        if (onCall) {
          print('🎵 Cannot play/resume: Device is currently on a call.');
          _targetPlayingState = null;
          _showErrorSnackBar(
            'Playback blocked: Cannot play music during an active call',
            (l10n) => l10n.activeCallCannotPlay,
          );
          return;
        }
      }
    }

    final playPauseId = ++_activePlayPauseId;
    final audioSvc = ref.read(audioServiceProvider);

    // Cancel active volume fades on player
    audioSvc.cancelFade(player);

    if (!targetPlaying) {
      if (settings.fadePlayPauseStop) {
        final currentVol = player.state.volume / 100.0;
        await audioSvc.fadeVolume(player, currentVol, 0.0, Duration(milliseconds: settings.playPauseStopFadeLength));
        if (playPauseId != _activePlayPauseId) return;

        await audioSvc.pause();
      } else {
        await audioSvc.pause();
      }
    } else {
      if (player.state.playlist.medias.isEmpty && state.currentSong != null) {
        await play(state.currentSong!);
      } else {
        if (settings.fadePlayPauseStop) {
          player.setVolume(0.0);
          await audioSvc.resume();
          if (playPauseId != _activePlayPauseId) return;

          await audioSvc.fadeVolume(player, 0.0, state.volume, Duration(milliseconds: settings.playPauseStopFadeLength));
          if (playPauseId != _activePlayPauseId) return;

          player.setVolume(state.volume * 100);
        } else {
          player.setVolume(state.volume * 100);
          await audioSvc.resume();
        }
      }
    }

    if (playPauseId == _activePlayPauseId) {
      _targetPlayingState = null;
    }
  }

  Future<void> skipNext() async {
    if (_playlist.isEmpty) return;
    if (!_autoCrossfadeTriggered) {
      _isLastPlayManual = true;
    }
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
    _isLastPlayManual = true;
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
    ref.read(audioServiceProvider).cancelFade(player);
    state = state.copyWith(volume: volume);
    player.setVolume(volume * 100);
    ref.read(settingsProvider.notifier).updateVolume(volume);
  }

  Future<void> seek(Duration position) async {
    final settings = ref.read(settingsProvider);
    if (settings.fadeOnSeek && state.isPlaying && !state.isScrubbing) {
      final seekId = ++_activeSeekId;
      final audioSvc = ref.read(audioServiceProvider);

      audioSvc.cancelFade(player);

      final currentVol = player.state.volume / 100.0;
      await audioSvc.fadeVolume(player, currentVol, 0.0, Duration(milliseconds: settings.seekFadeLength));
      if (seekId != _activeSeekId) return;

      await player.seek(position);
      state = state.copyWith(position: position);
      if (seekId != _activeSeekId) return;

      await audioSvc.fadeVolume(player, 0.0, state.volume, Duration(milliseconds: settings.seekFadeLength));
      if (seekId != _activeSeekId) return;
      player.setVolume(state.volume * 100);
    } else {
      _activeSeekId++;
      ref.read(audioServiceProvider).cancelFade(player);
      await player.seek(position);
      state = state.copyWith(position: position);
      if (!state.isScrubbing) {
        player.setVolume(state.volume * 100);
      }
    }
  }

  void startScrubbing() {
    _activeSeekId++;
    ref.read(audioServiceProvider).cancelFade(player);
    state = state.copyWith(isScrubbing: true);
    player.setVolume(0);
  }

  void stopScrubbing() {
    _activeSeekId++;
    ref.read(audioServiceProvider).cancelFade(player);
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

  Future<FileActionResult> renameSong(Song song, String newTitle) async {
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
        if (fileRenamed) {
          song.path = newPath;
        }
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
        // Resume playing track from the new path / old path
        await playAtIndex(_currentIndex);
      } else {
        state = state.copyWith(queue: List.from(_playlist));
      }
    } catch (e) {
      print('Error renaming in DB: $e');
    }

    if (!dbSuccess) {
      return FileActionResult.failure;
    }
    return fileRenamed ? FileActionResult.success : FileActionResult.dbOnly;
  }

  Future<FileActionResult> deleteSong(Song song) async {
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

    if (!dbSuccess) {
      return FileActionResult.failure;
    }
    return fileDeleted ? FileActionResult.success : FileActionResult.dbOnly;
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

  void _showErrorSnackBar(String defaultMessage, String Function(AppLocalizations) getLocalizedMessage) {
    final context = scaffoldMessengerKey.currentContext;
    String message = defaultMessage;
    if (context != null) {
      try {
        final l10n = AppLocalizations.of(context);
        if (l10n != null) {
          message = getLocalizedMessage(l10n);
        }
      } catch (e) {
        print('Failed to get AppLocalizations: $e');
      }
    }

    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.redAccent.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(
          bottom: 24,
          left: 24,
          right: 24,
        ),
      ),
    );
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) {
    return PlaybackNotifier(ref);
  },
);
