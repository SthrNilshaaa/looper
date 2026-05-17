import 'package:audio_service/audio_service.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:io';

class MyAudioHandler extends BaseAudioHandler with SeekHandler {
  final Player player;

  // Callbacks
  void Function()? onNext;
  void Function()? onPrevious;
  void Function(Duration)? onSeek;

  MyAudioHandler(this.player) {
    if (Platform.isAndroid) {
      // Listen to player state changes and update the AudioService media item and state
      player.stream.playing.listen((playing) {
        playbackState.add(
          playbackState.value.copyWith(
            playing: playing,
            processingState: AudioProcessingState.ready,
            controls: [
              MediaControl.skipToPrevious,
              if (playing) MediaControl.pause else MediaControl.play,
              MediaControl.skipToNext,
            ],
            systemActions: const {
              MediaAction.seek,
              MediaAction.seekForward,
              MediaAction.seekBackward,
            },
          ),
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

      player.stream.completed.listen((completed) {
        if (completed && onNext != null) {
          onNext!();
        }
      });

      // Initial state
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            MediaControl.skipToNext,
          ],
          processingState: AudioProcessingState.ready,
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
        ),
      );
    }
  }

  @override
  Future<void> updateMediaItem(MediaItem mediaItem) async {
    if (Platform.isAndroid) {
      this.mediaItem.add(mediaItem);
    }
  }

  @override
  Future<void> play() async {
    await player.play();
  }

  @override
  Future<void> pause() async {
    await player.pause();
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
}
