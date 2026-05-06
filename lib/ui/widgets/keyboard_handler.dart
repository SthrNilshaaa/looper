import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

class KeyboardHandler extends ConsumerWidget {
  final Widget child;

  const KeyboardHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): () {
          ref.read(playbackProvider.notifier).togglePlay();
        },
        const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () {
          ref.read(playbackProvider.notifier).togglePlay();
        },
        const SingleActivator(LogicalKeyboardKey.mediaTrackNext): () {
          ref.read(playbackProvider.notifier).skipNext();
        },
        const SingleActivator(LogicalKeyboardKey.mediaTrackPrevious): () {
          ref.read(playbackProvider.notifier).skipPrevious();
        },
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          ref.read(playbackProvider.notifier).seekRelative(5);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          ref.read(playbackProvider.notifier).seekRelative(-5);
        },
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          ref.read(playbackProvider.notifier).adjustVolume(0.05);
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          ref.read(playbackProvider.notifier).adjustVolume(-0.05);
        },
        const SingleActivator(LogicalKeyboardKey.keyL): () {
           // Toggle lyrics could be added here
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
