import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:one_player/core/providers.dart';
import 'package:one_player/features/library/data/scanner.dart';
import 'package:window_manager/window_manager.dart';
import 'package:one_player/features/library/domain/models/models.dart';
import 'package:one_player/core/db_service.dart';
import 'package:one_player/features/settings/presentation/settings_notifier.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:isar/isar.dart';

enum RepeatMode { off, all, one }

class PlaybackState {
  final Song? currentSong;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final RepeatMode repeatMode;
  final double volume;

  final List<Song> queue;

  PlaybackState({
    this.currentSong,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.repeatMode = RepeatMode.off,
    this.volume = 1.0,
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
    state = state.copyWith(volume: settings.volume, isShuffle: settings.shuffle, repeatMode: RepeatMode.values[settings.repeatMode]);
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
      _currentIndex = _playlist.indexWhere((s) => s.id == songs[initialIndex].id);
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
    final metadata = {
      'title': song.title,
      'artist': song.artist ?? 'Unknown Artist',
      'album': song.album ?? 'Unknown Album',
      if (song.artPath != null) 'artPath': song.artPath!,
      if (song.duration != null) 'duration': song.duration!,
    };
    await ref.read(audioServiceProvider).play(song.path, metadata: metadata);
    
    await windowManager.setTitle('OnePlayer - ${song.title} - ${song.artist ?? 'Unknown Artist'}');
    await ref.read(settingsProvider.notifier).updateLastPlayedSong(song.id);

    await DbService.isar.writeTxn(() async {
      song.lastPlayed = DateTime.now();
      song.playCount++;
      await DbService.isar.songs.put(song);
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
    final songs = await DbService.isar.songs.filter().pathEqualTo(path).findAll();
    Song? song = songs.isEmpty ? null : songs.first;
    
    if (song == null) {
      // Create a temporary song object from metadata
      final metadata = await MetadataGod.readMetadata(file: path);
      // Extract and save artwork
      String? artPath;
      if (metadata?.picture != null) {
        final scanner = LibraryScanner(); // Need to save it using the same logic
        artPath = await scanner.saveAlbumArt(metadata?.album ?? 'unknown', metadata!.picture!.data);
      }

      song = Song()
        ..path = path
        ..title = metadata?.title ?? path.split('/').last
        ..artist = metadata?.artist
        ..album = metadata?.album
        ..duration = metadata?.durationMs?.toInt()
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
      _currentIndex = _playlist.indexWhere((s) => s.id == state.currentSong!.id);
    }
  }

  void nextRepeatMode() {
    final nextMode = RepeatMode.values[(state.repeatMode.index + 1) % RepeatMode.values.length];
    state = state.copyWith(repeatMode: nextMode);
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
}

final playbackProvider = StateNotifierProvider<PlaybackNotifier, PlaybackState>((ref) {
  return PlaybackNotifier(ref);
});
