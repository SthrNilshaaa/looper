import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mpv_audio_kit/mpv_audio_kit.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/providers.dart';
import 'package:looper_player/features/library/data/scanner.dart';
import 'package:window_manager/window_manager.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/features/playback/presentation/lyrics_notifier.dart';
import 'package:looper_player/features/playback/presentation/equalizer_notifier.dart';
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

  /// True when a song was loaded from saved state on startup but playback
  /// hasn't started yet (resumeOnStart = false). The player bar is hidden
  /// when this is true and isPlaying is false, preventing the stale
  /// "paused song" ghost bar from showing on every cold start.
  final bool isRestoredSession;

  final bool isSleepTimerActive;
  final Duration? sleepTimerDurationRemaining;
  final int? sleepTimerSongsRemaining;
  final Duration? sleepTimerDurationInitial;
  final int? sleepTimerSongsInitial;

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
    this.isRestoredSession = false,
    this.isSleepTimerActive = false,
    this.sleepTimerDurationRemaining,
    this.sleepTimerSongsRemaining,
    this.sleepTimerDurationInitial,
    this.sleepTimerSongsInitial,
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
    bool? isRestoredSession,
    bool? isSleepTimerActive,
    Object? sleepTimerDurationRemaining = _sentinel,
    Object? sleepTimerSongsRemaining = _sentinel,
    Object? sleepTimerDurationInitial = _sentinel,
    Object? sleepTimerSongsInitial = _sentinel,
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
      isRestoredSession: isRestoredSession ?? this.isRestoredSession,
      isSleepTimerActive: isSleepTimerActive ?? this.isSleepTimerActive,
      sleepTimerDurationRemaining: sleepTimerDurationRemaining == _sentinel 
          ? this.sleepTimerDurationRemaining 
          : sleepTimerDurationRemaining as Duration?,
      sleepTimerSongsRemaining: sleepTimerSongsRemaining == _sentinel 
          ? this.sleepTimerSongsRemaining 
          : sleepTimerSongsRemaining as int?,
      sleepTimerDurationInitial: sleepTimerDurationInitial == _sentinel 
          ? this.sleepTimerDurationInitial 
          : sleepTimerDurationInitial as Duration?,
      sleepTimerSongsInitial: sleepTimerSongsInitial == _sentinel 
          ? this.sleepTimerSongsInitial 
          : sleepTimerSongsInitial as int?,
    );
  }
}

const _sentinel = Object();

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final Ref ref;
  late final Player player;
  List<Song> _playlist = [];
  List<Song> _originalPlaylist = [];
  int _currentIndex = -1;
  bool _isTransitioning = false;
  bool _autoCrossfadeTriggered = false;
  bool _isLastPlayManual = true;
  int _activeCrossfadeId = 0;
  int _activeSeekId = 0;
  int _activePlayPauseId = 0;
  bool? _targetPlayingState;
  bool _isTogglePlaying = false;
  Timer? _silenceTimer;
  Timer? _songCompletionTimer;
  int _lastWidgetPositionUpdate = 0;
  int _manualQueueCount = 0;
  DateTime _lastSeekTime = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastPlayTime = DateTime.fromMillisecondsSinceEpoch(0);

  PlaybackNotifier(this.ref) : super(PlaybackState()) {
    player = ref.read(audioServiceProvider).player;
    ref.read(audioServiceProvider).onNext = skipNext;
    ref.read(audioServiceProvider).onPrevious = skipPrevious;
    ref.read(audioServiceProvider).onSeek = (duration) => seek(duration);
    ref.read(audioServiceProvider).onFavoriteToggle = toggleFavorite;
    ref.read(audioServiceProvider).onShuffleToggle = toggleShuffle;
    ref.read(audioServiceProvider).onRepeatToggle = nextRepeatMode;
    ref.read(audioServiceProvider).onPlay = () {
      if (!state.isPlaying) togglePlay();
    };
    ref.read(audioServiceProvider).onPause = () {
      if (state.isPlaying) togglePlay();
    };
    ref.read(audioServiceProvider).onPlayPause = togglePlay;
    _init();
    _initWidgetChannel();
    ref.listen<LyricsState>(lyricsProvider, (previous, next) {
      if (next.songId == state.currentSong?.id && !next.isLoading) {
        _updateWidgetState();
      }
    });
    ref.listen<AppSettings>(settingsProvider, (previous, next) {
      if (previous?.audioFocus != next.audioFocus ||
          previous?.resumeAfterCall != next.resumeAfterCall ||
          previous?.permanentAudioFocusChange != next.permanentAudioFocusChange ||
          previous?.audioFocusRequestOnPlay != next.audioFocusRequestOnPlay ||
          previous?.audioFocusReleaseOnPause != next.audioFocusReleaseOnPause ||
          previous?.audioFocusStopOnOtherSession != next.audioFocusStopOnOtherSession ||
          previous?.audioFocusRestartOnGain != next.audioFocusRestartOnGain) {
        ref.read(audioServiceProvider).applyAudioFocusPolicy(
          _getInterruptionPolicy(),
          requestFocusOnPlay: next.audioFocusRequestOnPlay,
          releaseFocusOnPause: next.audioFocusReleaseOnPause,
          stopOnOtherSession: next.audioFocusStopOnOtherSession,
          restartOnFocusGain: next.audioFocusRestartOnGain,
        );
      }
      if (previous?.enableAudioCache != next.enableAudioCache ||
          previous?.audioCacheSizeMB != next.audioCacheSizeMB ||
          previous?.audioCacheSecs != next.audioCacheSecs ||
          previous?.audioBackCacheSizeMB != next.audioBackCacheSizeMB) {
        ref.read(audioServiceProvider).configureCache(
          enabled: next.enableAudioCache,
          maxBytes: next.audioCacheSizeMB * 1024 * 1024,
          cacheSecs: next.audioCacheSecs,
          backBytes: next.audioBackCacheSizeMB * 1024 * 1024,
        );
      }
      if (previous?.exclusiveHardwareMode != next.exclusiveHardwareMode) {
        ref.read(audioServiceProvider).configureHardwareExclusive(next.exclusiveHardwareMode);
      }
      if (previous?.stopOnTaskRemoved != next.stopOnTaskRemoved) {
        ref.read(audioServiceProvider).setStopOnTaskRemoved(next.stopOnTaskRemoved);
      }
    });
  }

  void _updateNotification() {
    final song = state.currentSong;
    if (song != null) {
      final audioSvc = ref.read(audioServiceProvider);
      if (audioSvc.player.state.mediaSession != null) {
        audioSvc.player.setMediaSession(
          audioSvc.player.state.mediaSession!.copyWith(
            isFavorite: song.isFavorite,
          ),
        );
      }
    }
    _updateWidgetState();
  }

  Future<void> _init() async {
    player.stream.error.listen((err) {

    });

    player.stream.log.listen((entry) {

    });

    player.stream.internalLog.listen((entry) {

    });

    player.stream.playing.listen((playing) {
      if (_isTogglePlaying) {
        // Ignore native player updates while in the middle of play/pause transitions
        return;
      }
      if (!playing) {
        if (_isTransitioning || _autoCrossfadeTriggered) {
          // Ignore temporary pause/stop events while transitioning/opening a new song
          return;
        }
        // If the song is near its end, ignore playing: false because it's completing
        final remaining = state.duration - state.position;
        if (remaining.inMilliseconds > 0 && remaining.inMilliseconds < 6000) {
          return;
        }
        final now = DateTime.now();
        if (now.difference(_lastPlayTime).inMilliseconds < 1500) {
          return;
        }
      }
      if (state.isScrubbing) {

        // Ignore playing state changes while the user is scrubbing the seek bar
        // to prevent the play/pause button from flickering
        return;
      }
      if (DateTime.now().difference(_lastSeekTime).inMilliseconds < 400) {

        // Ignore playing state changes immediately after a seek/scrub operation
        // to prevent play/pause button state flickering
        return;
      }

      state = state.copyWith(isPlaying: playing);
      _updateNotification();
      if (!playing && ref.read(settingsProvider).persistQueue) {
        ref.read(settingsProvider.notifier).updateLastPosition(state.position.inMilliseconds);
      }
    });

    player.stream.position.listen((position) {
      if (!state.isScrubbing) {
        state = state.copyWith(position: position);
      }
      _checkAndUpdateLyrics();

      final now = DateTime.now().millisecondsSinceEpoch;
      if (state.isPlaying && now - _lastWidgetPositionUpdate > 2000) {
        _lastWidgetPositionUpdate = now;
        _updateWidgetState();
        if (ref.read(settingsProvider).persistQueue) {
          ref.read(settingsProvider.notifier).updateLastPosition(position.inMilliseconds);
        }
      }
    });

    player.stream.duration.listen((duration) {
      if (duration != Duration.zero) {
        state = state.copyWith(duration: duration);
      }
    });

    DateTime? lastCompletedTime;
    player.stream.completed.listen((completed) {
      debugPrint("======== COMPLETED ========");
      debugPrint("completed = $completed");
      debugPrint("position  = ${player.state.position}");
      debugPrint("duration  = ${player.state.duration}");
      debugPrint("playlist completed = ${player.state.completed}");

      if (completed) {
        if (_isTransitioning) {

          return;
        }
        _isTransitioning = true;
        final now = DateTime.now();
        if (now.difference(_lastPlayTime).inMilliseconds < 1500) {
          _isTransitioning = false;
          return;
        }
        if (lastCompletedTime != null && now.difference(lastCompletedTime!).inMilliseconds < 1000) {
          _isTransitioning = false;
          return;
        }
        lastCompletedTime = now;

        _songCompletionTimer?.cancel();

        void onSongFinished() {
          if (state.isSleepTimerActive && state.sleepTimerSongsRemaining != null) {
            final remaining = state.sleepTimerSongsRemaining! - 1;
            if (remaining <= 0) {
              state = state.copyWith(
                isSleepTimerActive: false,
                sleepTimerSongsRemaining: null,
                sleepTimerSongsInitial: null,
                sleepTimerDurationRemaining: null,
                sleepTimerDurationInitial: null,
              );
              player.pause();
              _isTransitioning = false;
              return;
            } else {
              state = state.copyWith(sleepTimerSongsRemaining: remaining);
            }
          }

          _isLastPlayManual = false;

          if (state.repeatMode == RepeatMode.one) {
            _isTransitioning = false;
            player.seek(Duration.zero);
            ref.read(audioServiceProvider).resume();
          } else {
            _isTransitioning = true;
            skipNext(isManual: false);
          }
        }

        final remaining = state.duration - state.position;
        if (remaining.inMilliseconds > 0 && remaining.inMilliseconds < 10000) {
          _songCompletionTimer = Timer(remaining + const Duration(milliseconds: 100), onSongFinished);
        } else {
          onSongFinished();
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

    // Apply cache and hardware configurations
    final audioSvc = ref.read(audioServiceProvider);
    audioSvc.applyAudioFocusPolicy(
      _getInterruptionPolicy(),
      requestFocusOnPlay: settings.audioFocusRequestOnPlay,
      releaseFocusOnPause: settings.audioFocusReleaseOnPause,
      stopOnOtherSession: settings.audioFocusStopOnOtherSession,
      restartOnFocusGain: settings.audioFocusRestartOnGain,
    );
    await audioSvc.configureCache(
      enabled: settings.enableAudioCache,
      maxBytes: settings.audioCacheSizeMB * 1024 * 1024,
      cacheSecs: settings.audioCacheSecs,
      backBytes: settings.audioBackCacheSizeMB * 1024 * 1024,
    );
    await audioSvc.configureHardwareExclusive(settings.exclusiveHardwareMode);
    await audioSvc.setStopOnTaskRemoved(settings.stopOnTaskRemoved);

    final savedSongIds = settings.lastQueueSongIds;
    final savedIndex = settings.lastQueueIndex;
    
    if (settings.persistQueue && savedSongIds.isNotEmpty) {
      final List<Song> loadedSongs = [];
      for (final id in savedSongIds) {
        final song = await DbService.isar.songs.get(id);
        if (song != null) {
          loadedSongs.add(song);
        }
      }
      if (loadedSongs.isNotEmpty) {
        _playlist = loadedSongs;
        _originalPlaylist = List.from(loadedSongs);
        _currentIndex = (savedIndex >= 0 && savedIndex < loadedSongs.length) ? savedIndex : 0;
        final song = _playlist[_currentIndex];
        state = state.copyWith(
          queue: List.from(_playlist),
          currentSong: song,
          isRestoredSession: true,
          position: Duration(milliseconds: settings.lastPositionMs),
          duration: song.duration != null ? Duration(milliseconds: song.duration!) : Duration.zero,
        );
        ref.read(lyricsProvider.notifier).fetchForSong(song);
        ref.read(equalizerProvider.notifier).onSongChanged(song);
        _updateWidgetState();
        
        final initialPos = Duration(milliseconds: settings.lastPositionMs);
        Future.delayed(const Duration(milliseconds: 500), () async {
          await play(song, forceDisableCrossfade: true, play: settings.resumeOnStart);
          if (settings.lastPositionMs > 0) {
            await seek(initialPos);
          }
        });
      }
    } else if (settings.persistQueue && settings.lastPlayedSongId != null) {
      final song = await DbService.isar.songs.get(settings.lastPlayedSongId!);
      if (song != null) {
        state = state.copyWith(
          currentSong: song,
          isRestoredSession: true,
          position: Duration(milliseconds: settings.lastPositionMs),
          duration: song.duration != null ? Duration(milliseconds: song.duration!) : Duration.zero,
        );
        ref.read(lyricsProvider.notifier).fetchForSong(song);
        ref.read(equalizerProvider.notifier).onSongChanged(song);
        _playlist = [song];
        _currentIndex = 0;
        _updateWidgetState(); // Sync initial song data with home screen widgets on launch
        
        final initialPos = Duration(milliseconds: settings.lastPositionMs);
        Future.delayed(const Duration(milliseconds: 500), () async {
          await play(song, forceDisableCrossfade: true, play: settings.resumeOnStart);
          if (settings.lastPositionMs > 0) {
            await seek(initialPos);
          }
        });
      }
    } else {
      await ref.read(settingsProvider.notifier).updateLastQueueState([], -1, null, positionMs: 0);
    }

    // Ensure dynamic queue is populated right after startup loading finishes
    await _ensureDynamicQueue();
  }

  Future<void> playAtIndex(int index) async {
    if (index >= 0 && index < _playlist.length) {
      final endOfManual = _currentIndex + _manualQueueCount;
      _manualQueueCount = (index < endOfManual) ? endOfManual - index : 0;
      _currentIndex = index;
      await play(_playlist[_currentIndex]);
    }
  }

  void setPlaylist(List<Song> songs, {int initialIndex = 0}) {
    // Extract manual queue songs before replacing the playlist
    final start = _currentIndex + 1;
    final end = (start + _manualQueueCount).clamp(0, _playlist.length);
    final manualSongs = (start < _playlist.length) ? _playlist.sublist(start, end) : <Song>[];

    _originalPlaylist = List.from(songs);

    if (state.isShuffle) {
      if (songs.isNotEmpty) {
        final currentSong = songs[initialIndex];
        final remaining = List<Song>.from(songs)..removeAt(initialIndex);
        remaining.shuffle();
        _playlist = [currentSong, ...remaining];
        _currentIndex = 0;
      } else {
        _playlist = [];
        _currentIndex = -1;
      }
    } else {
      _playlist = List.from(songs);
      _currentIndex = initialIndex;
    }

    // Re-insert manual queue songs after the new current song
    if (_currentIndex != -1 && manualSongs.isNotEmpty) {
      _playlist.insertAll(_currentIndex + 1, manualSongs);
      // Also insert into _originalPlaylist at corresponding position
      final origIdx = _originalPlaylist.indexWhere((s) => s.path == _playlist[_currentIndex].path);
      if (origIdx != -1) {
        _originalPlaylist.insertAll(origIdx + 1, manualSongs);
      } else {
        _originalPlaylist.addAll(manualSongs);
      }
      _manualQueueCount = manualSongs.length;
    } else {
      _manualQueueCount = 0;
    }

    state = state.copyWith(queue: List.from(_playlist));
    if (_playlist.isNotEmpty && _currentIndex != -1) {
      play(_playlist[_currentIndex]);
    }
  }

  Future<void> play(Song song, {bool forceDisableCrossfade = false, bool play = true}) async {

    _silenceTimer?.cancel();
    _songCompletionTimer?.cancel();
    final settings = ref.read(settingsProvider);
    if (play && settings.audioFocus) {
      final onCall = await ref.read(audioServiceProvider).isOnCall();
      if (onCall) {

        _showErrorSnackBar(
          'Playback blocked: Cannot play music during an active call',
          (l10n) => l10n.activeCallCannotPlay,
        );
        return;
      }
    }

    final isUrl = song.path.startsWith('http://') || song.path.startsWith('https://');
    if (!isUrl) {
      await _requestStoragePermissions();
      final file = File(song.path);
      if (!await file.exists()) {

        _showErrorSnackBar(
          'File not found or inaccessible: ${song.title}',
          (l10n) => 'File not found or inaccessible: ${song.title}',
        );
        return;
      }
    }

    final crossfadeId = ++_activeCrossfadeId;
    _isTransitioning = true;
    _lastPlayTime = DateTime.now();


    try {
      player.setVolume(state.volume * 100);

      await _playDirect(song, crossfadeId, play: play);

    } catch (e) {

      if (crossfadeId == _activeCrossfadeId) {
        try {

          player.setVolume(state.volume * 100);
          await _playDirect(song, crossfadeId, play: play);

        } catch (retryError) {

          _showErrorSnackBar(
            'Playback failed: ${retryError.toString()}',
            (l10n) => 'Playback failed: ${retryError.toString()}',
          );
          rethrow;
        }
      } else {

      }
    } finally {
      if (crossfadeId == _activeCrossfadeId) {
        int attempts = 0;

        while ((player.state.completed || (play && !state.isPlaying)) && attempts < 40) {
          await Future.delayed(const Duration(milliseconds: 25));
          attempts++;
        }

        _isTransitioning = false;
      }
    }
  }

  Future<void> _playDirect(Song song, int crossfadeId, {bool play = true}) async {
    _autoCrossfadeTriggered = false;
    _lastWidgetLyricLine = '';
    state = state.copyWith(
      currentSong: song,
      duration: song.duration != null ? Duration(milliseconds: song.duration!) : Duration.zero,
      position: Duration.zero,
      // Clear restored-session flag: from here on the song is actively playing.
      isRestoredSession: false,
    );
    ref.read(lyricsProvider.notifier).fetchForSong(song);
    ref.read(equalizerProvider.notifier).onSongChanged(song);
    
    // Apply equalizer settings for the song
    final settings = ref.read(settingsProvider);
    // Comment out song specific equalizer loading, always use global
    /*
    final gains = (song.hasCustomEqualizer && song.equalizerGains != null)
        ? song.equalizerGains!
        : settings.globalEqualizerGains;
    */
    final gains = settings.globalEqualizerGains;
    final customFilter = ref.read(equalizerProvider).customFilterString;

    final metadata = {
      'title': song.title,
      'artist': song.artist ?? 'Unknown Artist',
      'album': song.album ?? 'Unknown Album',
      if (song.artPath != null) 'artPath': song.artPath!,
      if (song.duration != null) 'duration': song.duration!,
    };
    final double targetVol = state.volume;
    final int fadeLength = settings.fadePlayPauseStop ? settings.playPauseStopFadeLength : 0;
    final bool shouldFade = fadeLength > 0 && play;
    if (shouldFade) {
      player.setVolume(0);
    } else {
      player.setVolume(state.volume * 100);
    }

    await ref.read(audioServiceProvider).play(
      song.path,
      metadata: metadata,
      play: play,
      equalizerGains: gains,
      equalizerEnabled: settings.equalizerEnabled,
      customFilter: customFilter,
      interruptionPolicy: _getInterruptionPolicy(),
      requestFocusOnPlay: settings.audioFocusRequestOnPlay,
      releaseFocusOnPause: settings.audioFocusReleaseOnPause,
      stopOnOtherSession: settings.audioFocusStopOnOtherSession,
      restartOnFocusGain: settings.audioFocusRestartOnGain,
    );

    if (play) {
      await ref.read(audioServiceProvider).resume();
    }

    if (shouldFade && crossfadeId == _activeCrossfadeId) {
      _fadeVolume(targetVol, Duration(milliseconds: fadeLength));
    }

    if (crossfadeId != _activeCrossfadeId) return;

    _updateWidgetState(); // Update home screen widgets instantly with the new song metadata

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
      if (play) {
        songToUpdate.lastPlayed = DateTime.now();
        songToUpdate.playCount++;
      }

      if (dbSong != null) {
        song.id = dbSong.id;
        song.isFavorite = dbSong.isFavorite;
        song.playCount = dbSong.playCount;
        song.lastPlayed = dbSong.lastPlayed;
      } else {
        song.id = songToUpdate.id;
      }

      await DbService.isar.songs.put(songToUpdate);
    });

    if (settings.persistQueue) {
      await ref.read(settingsProvider.notifier).updateLastPlayedSong(song.id);
    }

    final idx = _playlist.indexWhere((s) => s.path == song.path);
    if (idx != -1) {
      final endOfManual = _currentIndex + _manualQueueCount;
      _manualQueueCount = (idx < endOfManual) ? endOfManual - idx : 0;
      _currentIndex = idx;
    } else {
      if (_currentIndex == -1) {
        _playlist = [song];
        _originalPlaylist = [song];
        _currentIndex = 0;
        _manualQueueCount = 0;
      } else {
        final currentSong = _playlist[_currentIndex];
        _playlist.insert(_currentIndex + 1, song);
        final origIdx = _originalPlaylist.indexWhere((s) => s.path == currentSong.path);
        if (origIdx != -1) {
          _originalPlaylist.insert(origIdx + 1, song);
        } else {
          _originalPlaylist.add(song);
        }
        _currentIndex++;
      }
      state = state.copyWith(queue: List.from(_playlist));
    }
    _updateNotification();
    await _ensureDynamicQueue();
    await _saveQueueState();
  }

  void addToQueue(Song song) {
    // Remove duplicate upcoming songs if present
    final startSearchIndex = _currentIndex + _manualQueueCount;
    for (int i = _playlist.length - 1; i > startSearchIndex; i--) {
      if (_playlist[i].path == song.path) {
        _playlist.removeAt(i);
      }
    }
    // Also remove from _originalPlaylist to prevent duplicates
    _originalPlaylist.removeWhere((s) => s.path == song.path);

    if (state.isShuffle) {
      // Insert randomly into the remaining queue
      final minIndex = _currentIndex + 1;
      final maxIndex = _playlist.length;
      final insertIndex = minIndex >= maxIndex 
          ? minIndex 
          : minIndex + math.Random().nextInt(maxIndex - minIndex + 1);
      
      if (insertIndex >= _playlist.length) {
        _playlist.add(song);
      } else {
        _playlist.insert(insertIndex, song);
      }
      _originalPlaylist.add(song); // Keep original playlist appended
    } else {
      final insertIndex = _currentIndex + 1 + _manualQueueCount;
      if (insertIndex >= _playlist.length) {
        _playlist.add(song);
      } else {
        _playlist.insert(insertIndex, song);
      }

      // Also insert into _originalPlaylist at corresponding position
      final refSongIdx = _currentIndex + _manualQueueCount;
      if (refSongIdx >= 0 && refSongIdx < _playlist.length) {
        final refSong = _playlist[refSongIdx];
        final origIdx = _originalPlaylist.indexWhere((s) => s.path == refSong.path);
        if (origIdx != -1) {
          _originalPlaylist.insert(origIdx + 1, song);
        } else {
          _originalPlaylist.add(song);
        }
      } else {
        _originalPlaylist.add(song);
      }
    }
    _manualQueueCount++;

    state = state.copyWith(queue: List.from(_playlist));
  }

  void addNext(Song song) {
    // Remove from the upcoming queue (if present) to prevent immediate duplicate playback
    for (int i = _playlist.length - 1; i > _currentIndex; i--) {
      if (_playlist[i].path == song.path) {
        _playlist.removeAt(i);
        if (i <= _currentIndex + _manualQueueCount) {
          if (_manualQueueCount > 0) _manualQueueCount--;
        }
      }
    }
    _originalPlaylist.removeWhere((s) => s.path == song.path);

    final insertIndex = _currentIndex + 1;
    if (insertIndex >= _playlist.length) {
      _playlist.add(song);
    } else {
      _playlist.insert(insertIndex, song);
    }

    if (state.currentSong != null) {
      final origIdx = _originalPlaylist.indexWhere((s) => s.path == state.currentSong!.path);
      if (origIdx != -1) {
        _originalPlaylist.insert(origIdx + 1, song);
      } else {
        _originalPlaylist.add(song);
      }
    } else {
      _originalPlaylist.add(song);
    }
    _manualQueueCount++;

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
    if (_isTogglePlaying) {
      final currentPlaying = _targetPlayingState ?? state.isPlaying;
      final targetPlaying = !currentPlaying;
      _targetPlayingState = targetPlaying;
      state = state.copyWith(isPlaying: targetPlaying);
      _updateNotification();
      return;
    }

    _isTogglePlaying = true;
    _silenceTimer?.cancel();
    final settings = ref.read(settingsProvider);

    try {
      while (true) {
        final currentPlaying = _targetPlayingState ?? state.isPlaying;
        final targetPlaying = !currentPlaying;
        _targetPlayingState = targetPlaying;

        // Update UI state immediately to be ultra-responsive
        state = state.copyWith(isPlaying: targetPlaying);
        _updateNotification();

        if (!targetPlaying) {
          _songCompletionTimer?.cancel();
        }

        final audioSvc = ref.read(audioServiceProvider);

        if (targetPlaying) {
          if (settings.audioFocus) {
            final onCall = await ref.read(audioServiceProvider).isOnCall();
            if (onCall) {
              _showErrorSnackBar(
                'Playback blocked: Cannot play music during an active call',
                (l10n) => l10n.activeCallCannotPlay,
              );
              break;
            }
          }
        }

        if (!targetPlaying) {
          if (settings.fadePlayPauseStop && settings.playPauseStopFadeLength > 0) {
            await _fadeVolume(0.0, Duration(milliseconds: settings.playPauseStopFadeLength));
            if (_targetPlayingState != targetPlaying) {
              // Target state changed during fade, skip pause and process next loop iteration
              continue;
            }
          }
          await audioSvc.pause();
        } else {
          Song? songToPlay = state.currentSong;
          if (songToPlay == null) {
            if (_playlist.isNotEmpty) {
              if (_currentIndex >= 0 && _currentIndex < _playlist.length) {
                songToPlay = _playlist[_currentIndex];
              } else {
                songToPlay = _playlist.first;
                _currentIndex = 0;
              }
            } else {
              if (settings.lastPlayedSongId != null) {
                songToPlay = await DbService.isar.songs.get(settings.lastPlayedSongId!);
              }
              if (songToPlay == null) {
                final libSongs = await DbService.isar.songs.where().findAll();
                if (libSongs.isNotEmpty) {
                  songToPlay = libSongs.first;
                }
              }
            }
          }

          if (player.state.playlist.items.isEmpty || player.state.completed || state.duration == Duration.zero) {
            if (songToPlay != null) {
              await play(songToPlay);
            }
          } else {
            _lastPlayTime = DateTime.now(); // Record resumption time
            if (settings.fadePlayPauseStop && settings.playPauseStopFadeLength > 0) {
              player.setVolume(0);
              await audioSvc.resume();
              if (_targetPlayingState != targetPlaying) {
                // Target state changed during resume FFI call, skip fade and process next loop iteration
                continue;
              }
              await _fadeVolume(state.volume, Duration(milliseconds: settings.playPauseStopFadeLength));
            } else {
              player.setVolume(state.volume * 100);
              await audioSvc.resume();
            }
          }
        }

        // If the target state hasn't changed since we started this loop iteration, we are done!
        if (_targetPlayingState == targetPlaying) {
          break;
        }
      }
    } catch (e) {
      _showErrorSnackBar(
        'Playback action failed: ${e.toString()}',
        (l10n) => 'Playback action failed: ${e.toString()}',
      );
    } finally {
      // Small cooldown to let the audio hardware stabilize
      await Future.delayed(const Duration(milliseconds: 150));
      _isTogglePlaying = false;
      _targetPlayingState = null;
      // Sync the final FFI playing state to our state
      state = state.copyWith(isPlaying: player.state.playing);
      _updateNotification();
    }
  }

  Future<void> skipNext({bool isManual = true}) async {
    if (_playlist.isEmpty) return;
    _isLastPlayManual = isManual;

    final nextIndex = _currentIndex + 1;
    if (nextIndex >= _playlist.length) {
      if (state.repeatMode != RepeatMode.all) {
        await ref.read(audioServiceProvider).pause();
        return;
      }
    }

    _currentIndex++;
    if (_currentIndex >= _playlist.length) {
      if (state.repeatMode == RepeatMode.all) {
        if (state.isShuffle) {
          final newPlaylist = List<Song>.from(_originalPlaylist)..shuffle();
          if (_playlist.isNotEmpty && newPlaylist.isNotEmpty && newPlaylist.first.path == _playlist.last.path && newPlaylist.length > 1) {
            final swapIdx = 1 + math.Random().nextInt(newPlaylist.length - 1);
            final temp = newPlaylist[0];
            newPlaylist[0] = newPlaylist[swapIdx];
            newPlaylist[swapIdx] = temp;
          }
          _playlist = newPlaylist;
          _currentIndex = 0;
          state = state.copyWith(queue: List.from(_playlist));
        } else {
          _currentIndex = 0;
        }
      } else {
        _currentIndex = 0;
      }
    }
    if (_manualQueueCount > 0) {
      _manualQueueCount--;
    }

    await play(_playlist[_currentIndex]);
  }

  Future<void> skipPrevious({bool force = false}) async {
    if (_playlist.isEmpty) return;
    _isLastPlayManual = true;
    if (!force && state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    _currentIndex--;
    if (_currentIndex < 0) {
      _currentIndex = state.repeatMode == RepeatMode.all ? _playlist.length - 1 : 0;
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

  Future<void> toggleShuffle() async {
    final newState = !state.isShuffle;
    state = state.copyWith(isShuffle: newState);
    await ref.read(settingsProvider.notifier).updateShuffle(newState);

    if (newState) {
      // Turn Shuffle ON:
      // Generate a single shuffled playback order while keeping the current song active.
      if (_playlist.isEmpty) {
        _playlist = [];
        _currentIndex = -1;
      } else {
        final currentSong = _playlist[_currentIndex];
        final playedSongs = _playlist.sublist(0, _currentIndex);

        // Filter unplayed songs from original queue
        final remainingSongs = List<Song>.from(_originalPlaylist);
        for (final song in playedSongs) {
          final idx = remainingSongs.indexWhere((s) => s.path == song.path);
          if (idx != -1) remainingSongs.removeAt(idx);
        }
        final curIdx = remainingSongs.indexWhere((s) => s.path == currentSong.path);
        if (curIdx != -1) remainingSongs.removeAt(curIdx);

        // Shuffle only the remaining unplayed songs
        remainingSongs.shuffle();

        _playlist = [...playedSongs, currentSong, ...remainingSongs];
        _currentIndex = playedSongs.length;
      }
    } else {
      // Turn Shuffle OFF:
      // Restore the original queue order after the current song
      if (_playlist.isEmpty) {
        _playlist = [];
        _currentIndex = -1;
      } else {
        final currentSong = _playlist[_currentIndex];
        int newIndex = _originalPlaylist.indexWhere((s) => s.path == currentSong.path);
        if (newIndex == -1) {
          newIndex = _currentIndex.clamp(0, _originalPlaylist.length);
        }
        _playlist = List.from(_originalPlaylist);
        _currentIndex = newIndex;
      }
    }

    state = state.copyWith(queue: List.from(_playlist));
    await _saveQueueState();
    _updateNotification();
  }

  int songId(Song s) => s.id;

  void nextRepeatMode() {
    final nextMode = RepeatMode
        .values[(state.repeatMode.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeatMode: nextMode);
    ref.read(settingsProvider.notifier).updateRepeatMode(nextMode.index);
    _updateWidgetState();
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
    player.setVolume(volume * 100);
    ref.read(settingsProvider.notifier).updateVolume(volume);
  }

  Future<void> seek(Duration position) async {
    _songCompletionTimer?.cancel();
    _activeSeekId++;
    _lastSeekTime = DateTime.now();

    try {
      await player.seek(position);
      state = state.copyWith(position: position);
      if (!state.isScrubbing) {
        player.setVolume(state.volume * 100);
      }
      if (ref.read(settingsProvider).persistQueue) {
        ref.read(settingsProvider.notifier).updateLastPosition(position.inMilliseconds);
      }
    } catch (e) {
      debugPrint('Seek failed: $e');
      state = state.copyWith(position: position);
    }
  }

  void startScrubbing() {
    _activeSeekId++;
    _lastSeekTime = DateTime.now();
    state = state.copyWith(isScrubbing: true);
    player.setVolume(0);
  }

  void stopScrubbing() {
    _activeSeekId++;
    _lastSeekTime = DateTime.now();
    state = state.copyWith(
      isScrubbing: false,
      position: player.state.position,
    );
    player.setVolume(state.volume * 100);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex, {String? rotationSongPath}) async {
    if (_playlist.isEmpty) return;

    final targetSongPath = rotationSongPath ?? state.currentSong?.path;
    final rotationIdx = targetSongPath != null
        ? _playlist.indexWhere((s) => s.path == targetSongPath)
        : -1;

    if (rotationIdx == -1) {
      // Non-rotated standard reorder
      if (newIndex > oldIndex) newIndex -= 1;
      final song = _playlist.removeAt(oldIndex);
      _playlist.insert(newIndex, song);
    } else {
      // 1. Reconstruct the rotated list (displayed list)
      final List<Song> displayedQueue = [
        ..._playlist.sublist(rotationIdx),
        ..._playlist.sublist(0, rotationIdx),
      ];

      // 2. Perform the reorder on the rotated list
      if (newIndex > oldIndex) newIndex -= 1;
      final song = displayedQueue.removeAt(oldIndex);
      displayedQueue.insert(newIndex, song);

      // 3. Rotate it back to align rotationIdx with its original index
      final n = displayedQueue.length;
      final k = (n - rotationIdx) % n;

      _playlist = [
        ...displayedQueue.sublist(k),
        ...displayedQueue.sublist(0, k),
      ];
    }

    if (!state.isShuffle) {
      _originalPlaylist = List.from(_playlist);
    } else {
      final played = _playlist.sublist(0, _currentIndex);
      final current = _playlist[_currentIndex];
      final unplayed = _playlist.sublist(_currentIndex + 1);
      _originalPlaylist = [...played, current, ...unplayed];
    }

    // 4. Update state and save
    state = state.copyWith(queue: List.from(_playlist));
    if (state.currentSong != null) {
      _currentIndex = _playlist.indexWhere((s) => s.path == state.currentSong!.path);
    }
    await _saveQueueState();
  }

  Future<void> removeFromQueue(int index) async {
    if (index >= 0 && index < _playlist.length) {
      final song = _playlist[index];
      if (index == _currentIndex) {
        await skipNext();
      }
      final endOfManual = _currentIndex + _manualQueueCount;
      if (index > _currentIndex && index <= endOfManual) {
        if (_manualQueueCount > 0) _manualQueueCount--;
      }
      _playlist.removeAt(index);
      final origIdx = _originalPlaylist.indexWhere((s) => s.path == song.path);
      if (origIdx != -1) {
        _originalPlaylist.removeAt(origIdx);
      }
      state = state.copyWith(queue: List.from(_playlist));
      if (state.currentSong != null) {
        _currentIndex = _playlist.indexWhere((s) => s.path == state.currentSong!.path);
      }
      await _ensureDynamicQueue();
    }
  }

  Future<void> clearQueue() async {
    _playlist = [];
    _originalPlaylist = [];
    _currentIndex = -1;
    _manualQueueCount = 0;
    state = PlaybackState(
      volume: state.volume,
      isShuffle: state.isShuffle,
      repeatMode: state.repeatMode,
    );
    await player.stop();
    await _ensureDynamicQueue();
  }

  Future<void> toggleFavorite() async {
    final song = state.currentSong;
    if (song == null) return;

    // Toggle and persist
    final newFavoriteState = !song.isFavorite;
    await DbService.isar.writeTxn(() async {
      song.isFavorite = newFavoriteState;
      await DbService.isar.songs.put(song);
    });

    // Read a fresh instance back from DB to guarantee a new object reference
    // so Riverpod's select((s) => s.currentSong) detects the identity change
    // and rebuilds widgets (the like button, notification etc.)
    final freshSong = await DbService.isar.songs.get(song.id) ?? song;

    // Sync the in-memory playlist entry too
    final idx = _playlist.indexWhere((s) => s.id == freshSong.id);
    if (idx != -1) _playlist[idx] = freshSong;

    state = state.copyWith(
      currentSong: freshSong,
      queue: List.from(_playlist),
    );
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
      final audioStatusBefore = await Permission.audio.status;
      final storageStatusBefore = await Permission.storage.status;
      final manageStatusBefore = await Permission.manageExternalStorage.status;


      // Check if we already have permissions
      if (audioStatusBefore.isGranted ||
          storageStatusBefore.isGranted ||
          manageStatusBefore.isGranted) {

        return true;
      }

      // Request permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.audio,
        Permission.storage,
      ].request();

      final audioStatusAfter = statuses[Permission.audio] ?? PermissionStatus.denied;
      final storageStatusAfter = statuses[Permission.storage] ?? PermissionStatus.denied;


      bool isGranted = audioStatusAfter.isGranted || storageStatusAfter.isGranted;

      if (!isGranted) {

        final manageStatusAfter = await Permission.manageExternalStorage.request();

        if (manageStatusAfter.isGranted) {
          isGranted = true;
        }
      }

      return isGranted;
    } catch (e) {

      return true; // Fallback to let the app try physical operations
    }
  }

  Future<FileActionResult> renameSong(Song song, String newTitle) async {
    try {
      await _requestStoragePermissions();
    } catch (e) {

    }

    final sanitizedTitle = newTitle.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    if (sanitizedTitle.isEmpty) {
      return FileActionResult.failure;
    }

    final isCurrent = state.currentSong?.id == song.id;
    final wasPlaying = state.isPlaying;
    final lastPosition = state.position;

    if (isCurrent) {
      // Completely stop player to release file handle locks
      await player.stop();
      // Wait for player to completely release the file handle
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final file = File(song.path);
    final dir = file.parent.path;
    final ext = p.extension(song.path);
    final newPath = p.join(dir, '$sanitizedTitle$ext');

    bool fileRenamed = false;
    if (newPath != song.path) {
      try {
        if (newPath.toLowerCase() != song.path.toLowerCase() && await File(newPath).exists()) {

          if (isCurrent) {
            // Restore playback of the original song
            await play(song, play: wasPlaying);
            await seek(lastPosition);
          }
          return FileActionResult.failure;
        }

        if (await file.exists()) {
          await file.rename(newPath);
          fileRenamed = true;
        }
      } catch (e) {

      }
    } else {
      fileRenamed = true;
    }

    bool dbSuccess = false;
    try {
      await DbService.isar.writeTxn(() async {
        song.title = sanitizedTitle;
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
        // Resume playing track from the new path
        await play(song, play: wasPlaying);
        await seek(lastPosition);
      } else {
        state = state.copyWith(queue: List.from(_playlist));
      }
    } catch (e) {

      if (isCurrent) {
        // Fallback: restore player using original song/state
        await play(song, play: wasPlaying);
        await seek(lastPosition);
      }
    }

    if (!dbSuccess) {
      return FileActionResult.failure;
    }
    return (fileRenamed && newPath != song.path) ? FileActionResult.success : FileActionResult.dbOnly;
  }

  void updateSongEqualizer({required int songId, required bool hasCustom, List<double>? gains}) {
    // Update in playlist
    final idx = _playlist.indexWhere((s) => s.id == songId);
    if (idx != -1) {
      _playlist[idx].hasCustomEqualizer = hasCustom;
      _playlist[idx].equalizerGains = gains;
    }

    // Update in currentSong if it matches
    final song = state.currentSong;
    if (song != null && song.id == songId) {
      song.hasCustomEqualizer = hasCustom;
      song.equalizerGains = gains;
      state = state.copyWith(currentSong: song, queue: List.from(_playlist));
    } else {
      state = state.copyWith(queue: List.from(_playlist));
    }
  }

  void updateSongLyrics(int songId, String lyrics) {
    final idx = _playlist.indexWhere((s) => s.id == songId);
    if (idx != -1) {
      _playlist[idx].lyrics = lyrics;
    }

    final song = state.currentSong;
    if (song != null && song.id == songId) {
      song.lyrics = lyrics;
      state = state.copyWith(currentSong: song, queue: List.from(_playlist));
    } else {
      state = state.copyWith(queue: List.from(_playlist));
    }
  }

  void clearAllSongsEqualizer() {
    for (int i = 0; i < _playlist.length; i++) {
      _playlist[i].hasCustomEqualizer = false;
      _playlist[i].equalizerGains = null;
    }
    final song = state.currentSong;
    if (song != null) {
      song.hasCustomEqualizer = false;
      song.equalizerGains = null;
      state = state.copyWith(currentSong: song, queue: List.from(_playlist));
    } else {
      state = state.copyWith(queue: List.from(_playlist));
    }
  }

  /// Edits song metadata in the database (title, artist, album, year, genre, artPath).
  /// Does NOT rename the physical file — only updates the DB record.
  Future<bool> editSongMetadata(Song song, {
    String? title,
    String? artist,
    String? album,
    int? year,
    String? genre,
    String? artPath,
    String? lyrics,
  }) async {
    try {
      await DbService.isar.writeTxn(() async {
        if (title != null && title.isNotEmpty) song.title = title.trim();
        if (artist != null) song.artist = artist.trim().isEmpty ? null : artist.trim();
        if (album != null) song.album = album.trim().isEmpty ? null : album.trim();
        if (year != null) song.year = year == 0 ? null : year;
        if (genre != null) song.genre = genre.trim().isEmpty ? null : genre.trim();
        if (artPath != null) song.artPath = artPath.trim().isEmpty ? null : artPath.trim();
        song.lyrics = (lyrics == null || lyrics.trim().isEmpty) ? null : lyrics.trim();
        await DbService.isar.songs.put(song);
      });

      // Update the in-memory playlist
      final idx = _playlist.indexWhere((s) => s.id == song.id);
      if (idx != -1) _playlist[idx] = song;

      // Reflect changes in live playback state if this is the current song
      if (state.currentSong?.id == song.id) {
        state = state.copyWith(currentSong: song, queue: List.from(_playlist));
        _updateNotification();
        ref.read(lyricsProvider.notifier).fetchForSong(song, force: true);
      } else {
        state = state.copyWith(queue: List.from(_playlist));
      }
      return true;
    } catch (e) {

      return false;
    }
  }

  Future<FileActionResult> deleteSong(Song song) async {
    try {
      await _requestStoragePermissions();
    } catch (e) {

    }

    final isCurrent = state.currentSong?.id == song.id;
    final wasPlaying = state.isPlaying;

    if (isCurrent) {
      // Completely stop player to release file handle locks
      await player.stop();
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

    }

    bool dbSuccess = false;
    try {
      await DbService.isar.writeTxn(() async {
        await DbService.isar.songs.delete(song.id);
      });
      dbSuccess = true;

      // Update in-memory queue
      _playlist.removeWhere((s) => s.id == song.id);

      if (isCurrent) {
        if (_playlist.isNotEmpty) {
          if (_currentIndex >= _playlist.length) {
            _currentIndex = 0;
          }
          final nextSong = _playlist[_currentIndex];
          state = state.copyWith(
            currentSong: nextSong,
            queue: List.from(_playlist),
          );
          // Play or load the next song
          await play(nextSong, play: wasPlaying);
        } else {
          // Playlist is empty now
          _currentIndex = -1;
          state = PlaybackState(
            volume: state.volume,
            isShuffle: state.isShuffle,
            repeatMode: state.repeatMode,
            queue: [],
          );
          ref.read(equalizerProvider.notifier).onSongChanged(null);
          await ref.read(settingsProvider.notifier).updateLastPlayedSong(null);
        }
      } else {
        // Adjust _currentIndex if the deleted song was before the current one
        if (state.currentSong != null) {
          _currentIndex = _playlist.indexWhere((s) => s.id == state.currentSong!.id);
        }
        state = state.copyWith(queue: List.from(_playlist));
      }

      // Clean up orphaned artists and albums
      await _cleanUpOrphanedArtistsAndAlbums();
    } catch (e) {

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

  static const _widgetChannel = MethodChannel('com.looper.player/widget');
  String _lastWidgetLyricLine = '';

  void _initWidgetChannel() {
    if (!Platform.isAndroid) return;
    _widgetChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onWidgetAction':
          final action = call.arguments as String?;
          if (action == 'com.looper.player.ACTION_PLAY_PAUSE') {
            togglePlay();
          } else if (action == 'com.looper.player.ACTION_NEXT') {
            skipNext();
          } else if (action == 'com.looper.player.ACTION_PREV') {
            skipPrevious();
          } else if (action == 'com.looper.player.ACTION_SHUFFLE') {
            toggleShuffle();
          } else if (action == 'com.looper.player.ACTION_REPEAT') {
            nextRepeatMode();
          }
          break;
      }
    });
  }

  void _checkAndUpdateLyrics() {
    if (!Platform.isAndroid) return;
    try {
      final lyricsState = ref.read(lyricsProvider);
      final currentPosition = state.position;
      String currentLine = "";
      if (lyricsState.rawLrc != null) {
        int activeLineIndex = lyricsState.parsedLines.indexWhere(
          (line) => currentPosition >= line.startTime && currentPosition < line.endTime,
        );
        if (activeLineIndex == -1 && lyricsState.parsedLines.isNotEmpty) {
          if (currentPosition < lyricsState.parsedLines.first.startTime) {
            activeLineIndex = 0;
          } else if (currentPosition >= lyricsState.parsedLines.last.endTime) {
            activeLineIndex = lyricsState.parsedLines.length - 1;
          }
        }
        if (activeLineIndex != -1) {
          currentLine = lyricsState.parsedLines[activeLineIndex].text;
        }
      }
      if (currentLine != _lastWidgetLyricLine) {
        _lastWidgetLyricLine = currentLine;
        _updateWidgetState();
      }
    } catch (e, s) {

    }
  }

  Future<void> _updateWidgetState() async {
    if (!Platform.isAndroid) return;
    try {
      final song = state.currentSong;
      final lyricsState = ref.read(lyricsProvider);
      final currentPosition = state.position;
      String currentLine = "";
      String nextLine = "";
      if (lyricsState.rawLrc != null) {
        int activeLineIndex = lyricsState.parsedLines.indexWhere(
          (line) => currentPosition >= line.startTime && currentPosition < line.endTime,
        );
        if (activeLineIndex == -1 && lyricsState.parsedLines.isNotEmpty) {
          if (currentPosition < lyricsState.parsedLines.first.startTime) {
            activeLineIndex = 0;
          } else if (currentPosition >= lyricsState.parsedLines.last.endTime) {
            activeLineIndex = lyricsState.parsedLines.length - 1;
          }
        }
        if (activeLineIndex != -1) {
          currentLine = lyricsState.parsedLines[activeLineIndex].text;
          if (activeLineIndex + 1 < lyricsState.parsedLines.length) {
            nextLine = lyricsState.parsedLines[activeLineIndex + 1].text;
          }
        }
      }

      final accentColor = ref.read(settingsProvider).accentColor;

      await HomeWidget.saveWidgetData<String>('title', song?.title ?? 'No song playing');
      await HomeWidget.saveWidgetData<String>('artist', song?.artist ?? '');
      await HomeWidget.saveWidgetData<bool>('isPlaying', state.isPlaying);
      await HomeWidget.saveWidgetData<bool>('isShuffle', state.isShuffle);
      await HomeWidget.saveWidgetData<int>('repeatMode', state.repeatMode.index);
      await HomeWidget.saveWidgetData<String>('lyrics', currentLine);
      await HomeWidget.saveWidgetData<String>('nextLyrics', nextLine);
      await HomeWidget.saveWidgetData<String>('artPath', song?.artPath ?? '');
      await HomeWidget.saveWidgetData<int>('accentColor', accentColor);
      await HomeWidget.saveWidgetData<int>('position', currentPosition.inMilliseconds);
      await HomeWidget.saveWidgetData<int>('duration', state.duration.inMilliseconds);

      await HomeWidget.updateWidget(
        name: 'PlayerWidgetProvider',
        qualifiedAndroidName: 'com.looper.player.PlayerWidgetProvider',
      );
      await HomeWidget.updateWidget(
        name: 'PlayerWidgetProviderSquareArtwork',
        qualifiedAndroidName: 'com.looper.player.PlayerWidgetProviderSquareArtwork',
      );
      await HomeWidget.updateWidget(
        name: 'PlayerWidgetProviderSquareProgress',
        qualifiedAndroidName: 'com.looper.player.PlayerWidgetProviderSquareProgress',
      );
      await HomeWidget.updateWidget(
        name: 'PlayerWidgetProviderLargeLyrics',
        qualifiedAndroidName: 'com.looper.player.PlayerWidgetProviderLargeLyrics',
      );
    } catch (e, s) {

    }
  }

  Timer? _sleepTimer;

  void startSleepTimer({Duration? duration, int? songCount}) {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    if (duration != null) {
      state = state.copyWith(
        isSleepTimerActive: true,
        sleepTimerDurationRemaining: duration,
        sleepTimerDurationInitial: duration,
        sleepTimerSongsRemaining: null,
        sleepTimerSongsInitial: null,
      );

      _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!state.isSleepTimerActive || state.sleepTimerDurationRemaining == null) {
          timer.cancel();
          _sleepTimer = null;
          return;
        }

        final remaining = state.sleepTimerDurationRemaining! - const Duration(seconds: 1);
        if (remaining <= Duration.zero) {
          timer.cancel();
          _sleepTimer = null;
          state = state.copyWith(
            isSleepTimerActive: false,
            sleepTimerDurationRemaining: null,
            sleepTimerSongsRemaining: null,
            sleepTimerDurationInitial: null,
            sleepTimerSongsInitial: null,
          );
          player.pause();
        } else {
          state = state.copyWith(sleepTimerDurationRemaining: remaining);
        }
      });
    } else if (songCount != null) {
      state = state.copyWith(
        isSleepTimerActive: true,
        sleepTimerDurationRemaining: null,
        sleepTimerDurationInitial: null,
        sleepTimerSongsRemaining: songCount,
        sleepTimerSongsInitial: songCount,
      );
    }
  }

  void stopSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    state = state.copyWith(
      isSleepTimerActive: false,
      sleepTimerDurationRemaining: null,
      sleepTimerSongsRemaining: null,
      sleepTimerDurationInitial: null,
      sleepTimerSongsInitial: null,
    );
  }

  Future<void> _saveQueueState() async {
    final settings = ref.read(settingsProvider);
    if (!settings.persistQueue) return;
    final songIds = _playlist.map((s) => s.id).toList();
    await ref.read(settingsProvider.notifier).updateLastQueueState(
      songIds,
      _currentIndex,
      state.currentSong?.id,
      positionMs: state.position.inMilliseconds,
    );
  }

  Future<void> _ensureDynamicQueue() async {
    final allSongs = await DbService.isar.songs.where().findAll();
    if (allSongs.isEmpty) return;

    bool playlistChanged = false;

    // 1. If playlist is empty, populate it with a random song
    if (_playlist.isEmpty) {
      final randomSong = allSongs[math.Random().nextInt(allSongs.length)];
      _playlist = [randomSong];
      _originalPlaylist = [randomSong];
      _currentIndex = 0;
      _manualQueueCount = 0;
      playlistChanged = true;
    }

    // 2. Ensure we have at least 5 songs ahead of the current index (dynamic queue auto-fill)
    const int bufferSize = 5;
    while (_playlist.length - 1 - _currentIndex < bufferSize) {
      final lastSong = _playlist.isNotEmpty ? _playlist.last : null;
      var candidates = allSongs;
      if (lastSong != null) {
        candidates = allSongs.where((s) => s.path != lastSong.path).toList();
      }
      if (candidates.isEmpty) {
        candidates = allSongs;
      }
      final nextSong = candidates[math.Random().nextInt(candidates.length)];
      _playlist.add(nextSong);
      _originalPlaylist.add(nextSong);
      playlistChanged = true;
    }

    if (playlistChanged) {
      state = state.copyWith(queue: List.from(_playlist));
      await _saveQueueState();
    }
  }

  InterruptionPolicy _getInterruptionPolicy() {
    final settings = ref.read(settingsProvider);
    if (!settings.audioFocus) {
      return InterruptionPolicy.keepPlaying;
    }
    return settings.resumeAfterCall
        ? InterruptionPolicy.pauseAndResume
        : InterruptionPolicy.pauseOnly;
  }

  Timer? _fadeVolumeTimer;

  Future<void> _fadeVolume(double targetVolume, Duration duration) {
    final completer = Completer<void>();
    _fadeVolumeTimer?.cancel();
    if (duration.inMilliseconds <= 0) {
      player.setVolume(targetVolume * 100);
      return Future.value();
    }

    final double startVolume = player.state.volume / 100.0;
    final int steps = 15;
    final int stepMs = (duration.inMilliseconds / steps).round().clamp(10, 100);
    final double volumeStep = (targetVolume - startVolume) / steps;
    int currentStep = 0;

    _fadeVolumeTimer = Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      currentStep++;
      final double nextVolume = (startVolume + (volumeStep * currentStep)).clamp(0.0, 1.5);
      player.setVolume(nextVolume * 100);

      if (currentStep >= steps) {
        timer.cancel();
        player.setVolume(targetVolume * 100);
        completer.complete();
      }
    });
    return completer.future;
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _sleepTimer?.cancel();
    _fadeVolumeTimer?.cancel();
    super.dispose();
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) {
    return PlaybackNotifier(ref);
  },
);
