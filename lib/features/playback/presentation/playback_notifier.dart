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
import '../../search/data/youtube_music_service.dart';
import '../../search/presentation/youtube_search_notifier.dart';

enum RepeatMode { off, all, one }

class PlaybackState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final double volume;
  final bool isLoading;

  final List<Song> queue;

  PlaybackState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
    this.isLoading = false,
    this.queue = const [],
  });

  PlaybackState copyWith({
    Song? currentSong,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    RepeatMode? repeatMode,
    double? volume,
    bool? isLoading,
    List<Song>? queue,
  }) {
    return PlaybackState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
      isLoading: isLoading ?? this.isLoading,
      queue: queue ?? this.queue,
    );
  }
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  final Ref ref;
  late final Player player;
  List<Song> _playlist = [];
  int _currentIndex = -1;

  PlaybackNotifier(this.ref) : super(PlaybackState()) {
    player = ref.read(audioServiceProvider).player;
    ref.read(audioServiceProvider).onNext = skipNext;
    ref.read(audioServiceProvider).onPrevious = skipPrevious;
    _init();
  }

  Future<void> _init() async {
    player.stream.playing.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });

    player.stream.position.listen((position) {
      state = state.copyWith(position: position);
    });

    player.stream.duration.listen((duration) {
      state = state.copyWith(duration: duration);
    });

    player.stream.completed.listen((completed) {
      if (completed) {
        if (state.repeatMode == RepeatMode.one) {
          player.seek(Duration.zero);
          player.play();
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

  void setPlaylist(List<Song> songs, {int initialIndex = 0}) {
    _playlist = List.from(songs);
    if (state.isShuffle) {
      _playlist.shuffle();
      _currentIndex = _playlist.indexWhere(
        (s) => s.id == songs[initialIndex].id,
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
    state = state.copyWith(currentSong: song);
    final isYouTube = song.path.startsWith('youtube://');
    final videoId = isYouTube ? song.path.replaceFirst('youtube://', '') : null;

    final metadata = <String, dynamic>{
      'title': song.title,
      'artist': song.artist ?? 'Unknown Artist',
      'album': song.album ?? 'Unknown Album',
      if (song.artPath != null) 'artPath': song.artPath!,
      if (song.duration != null) 'duration': song.duration!,
      if (videoId != null) 'videoId': videoId,
    };

    String finalPath = song.path;
    if (isYouTube) {
      state = state.copyWith(
        isLoading: true,
        isPlaying: false,
        position: Duration.zero,
        duration: Duration.zero,
      );

      try {
        final streamUrl = await ref.read(youtubeMusicServiceProvider).getStreamUrl(videoId!);
        if (streamUrl == null || streamUrl.isEmpty) {
          state = state.copyWith(isLoading: false, isPlaying: false);
          return;
        }
        finalPath = streamUrl;

        print('Opening YouTube stream...');
        await ref.read(audioServiceProvider).play(finalPath, metadata: metadata);

        // Wait briefly for MediaKit to initialize
        await Future.delayed(const Duration(milliseconds: 800));

        final mediaDuration = ref.read(audioServiceProvider).player.state.duration;

        // Detect failed open
        if (mediaDuration == Duration.zero) {
          print('Media failed to initialize');
          state = state.copyWith(
            isLoading: false,
            isPlaying: false,
            duration: Duration.zero,
            position: Duration.zero,
          );
          return;
        }

        state = state.copyWith(
          isLoading: false,
          isPlaying: true,
          duration: mediaDuration,
        );
      } catch (e, stack) {
        print('YouTube playback failed: $e');
        print(stack);
        state = state.copyWith(
          isLoading: false,
          isPlaying: false,
          duration: Duration.zero,
          position: Duration.zero,
        );
        return;
      }
    } else {
      await ref.read(audioServiceProvider).play(finalPath, metadata: metadata);
    }

    await windowManager.setTitle(
      'Looper Player - ${song.title} - ${song.artist ?? 'Unknown Artist'}',
    );

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

    final idx = _playlist.indexWhere((s) => s.id == song.id);
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
  }

  void addToQueue(Song song) {
    if (_playlist.any((s) => s.id == song.id)) return;
    _playlist.add(song);
    state = state.copyWith(queue: List.from(_playlist));
  }

  void addNext(Song song) {
    // Remove if already in queue to avoid duplicates/unexpected behavior
    _playlist.removeWhere((s) => s.id == song.id);

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
    if (state.isPlaying) {
      await player.pause();
    } else {
      if (player.state.playlist.medias.isEmpty && state.currentSong != null) {
        await play(state.currentSong!);
      } else {
        await player.play();
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
        await player.pause();
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
        (s) => s.id == songId(state.currentSong!),
      );
    }
    ref.read(settingsProvider.notifier).updateShuffle(newState);
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
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final song = _playlist.removeAt(oldIndex);
    _playlist.insert(newIndex, song);
    state = state.copyWith(queue: List.from(_playlist));
    if (state.currentSong != null) {
      _currentIndex = _playlist.indexOf(state.currentSong!);
    }
  }

  void removeFromQueue(int index) {
    if (index == _currentIndex) {
      skipNext();
    }
    _playlist.removeAt(index);
    state = state.copyWith(queue: List.from(_playlist));
    if (state.currentSong != null) {
      _currentIndex = _playlist.indexOf(state.currentSong!);
    }
  }

  void clearQueue() {
    _playlist = [];
    _currentIndex = -1;
    state = state.copyWith(queue: [], currentSong: null, isPlaying: false);
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

  Future<void> playYouTube(YouTubeTrack track) async {
    // Create a temporary song object
    // Note: This won't be saved to Isar unless we explicitly do it.
    // We use a dummy ID for temporary songs or handle them specially.
    final song = Song()
      ..id = -1 // Dummy ID
      ..title = track.title
      ..artist = track.artist
      ..path = 'youtube://${track.videoId}'
      ..duration = track.duration?.inMilliseconds
      ..artPath = track.thumbnailUrl // For network images, we'll need to handle this in UI
      ..dateAdded = DateTime.now();

    await play(song);
  }
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) {
    return PlaybackNotifier(ref);
  },
);
