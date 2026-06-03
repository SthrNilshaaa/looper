import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:io';
import 'db_service.dart';
import 'package:looper_player/features/library/domain/models/models.dart';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final Player player;

  // Callbacks
  void Function()? onNext;
  void Function()? onPrevious;
  void Function(Duration)? onSeek;
  void Function()? onFavoriteToggle;
  void Function()? onShuffleToggle;
  void Function()? onPlay;
  void Function()? onPause;

  bool _lastIsPlaying = false;
  bool _lastIsFavorite = false;
  bool _lastIsShuffle = false;

  MyAudioHandler(this.player) {
    if (Platform.isAndroid) {
      // Listen to player state changes and update the AudioService media item and state
      player.stream.playing.listen((playing) {
        updateControls(
          isPlaying: playing,
          isFavorite: _lastIsFavorite,
          isShuffle: _lastIsShuffle,
        );
      });

      player.stream.position.listen((position) {
        playbackState.add(
          playbackState.value.copyWith(
            updatePosition: position,
            bufferedPosition: player.state.buffer,
          ),
        );
      });

      player.stream.duration.listen((duration) {
        if (mediaItem.value != null) {
          mediaItem.add(mediaItem.value!.copyWith(duration: duration));
        }
      });



      // Initial state
      updateControls(
        isPlaying: false,
        isFavorite: false,
        isShuffle: false,
      );
    }
  }

  void updateControls({
    required bool isPlaying,
    required bool isFavorite,
    required bool isShuffle,
  }) {
    _lastIsPlaying = isPlaying;
    _lastIsFavorite = isFavorite;
    _lastIsShuffle = isShuffle;

    playbackState.add(
      playbackState.value.copyWith(
        playing: isPlaying,
        processingState: AudioProcessingState.ready,
        controls: [
          MediaControl.custom(
            androidIcon: isShuffle ? 'drawable/ic_shuffle' : 'drawable/ic_shuffle_off',
            label: isShuffle ? 'Shuffle On' : 'Shuffle Off',
            name: 'toggleShuffle',
          ),
          MediaControl.skipToPrevious,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.custom(
            androidIcon: isFavorite ? 'drawable/ic_like_filled' : 'drawable/ic_like',
            label: isFavorite ? 'Unlike' : 'Like',
            name: 'toggleFavorite',
          ),
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
      ),
    );
  }

  @override
  Future<dynamic> customAction(String name, [Map<String, dynamic>? extras]) async {
    switch (name) {
      case 'toggleFavorite':
        if (onFavoriteToggle != null) onFavoriteToggle!();
        break;
      case 'toggleShuffle':
        if (onShuffleToggle != null) onShuffleToggle!();
        break;
    }
    return super.customAction(name, extras);
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    if (Platform.isAndroid) {
      this.mediaItem.add(mediaItem);
    }
  }

  @override
  Future<void> play() async {
    if (onPlay != null) {
      onPlay!();
    } else {
      await player.play();
    }
  }

  @override
  Future<void> pause() async {
    if (onPause != null) {
      onPause!();
    } else {
      await player.pause();
    }
  }

  @override
  Future<void> skipToNext() async {
    if (onNext != null) onNext!();
  }

  @override
  Future<void> skipToPrevious() async {
    if (onPrevious != null) onPrevious!();
  }

  @override
  Future<void> seek(Duration position) async {
    if (onSeek != null) {
      onSeek!(position);
    } else {
      await player.seek(position);
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    try {
      final settings = await DbService.isar.appSettings.get(0);
      if (settings != null && settings.stopOnTaskRemoved) {
        await player.stop();
        await stop();
        exit(0);
      }
    } catch (e) {
      // ignore
    }
    await super.onTaskRemoved();
  }
}
