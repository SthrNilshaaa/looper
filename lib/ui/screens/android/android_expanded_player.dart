import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:squiggly_slider/slider.dart';

class AndroidExpandedPlayer extends ConsumerWidget {
  const AndroidExpandedPlayer({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showMoreOptionsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  LucideIcons.listOrdered,
                  color: Colors.white,
                ),
                title: const Text(
                  'Add to Queue',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentSong = ref.read(playbackProvider).currentSong;
                  if (currentSong != null) {
                    ref.read(playbackProvider.notifier).addToQueue(currentSong);
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.heart, color: Colors.white),
                title: const Text(
                  'Toggle Favorite',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  final currentSong = ref.read(playbackProvider).currentSong;
                  if (currentSong != null) {
                    ref.read(playbackProvider.notifier).toggleFavorite();
                  }
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.edit2, color: Colors.white),
                title: const Text(
                  'Rename File',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not implemented yet')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.share2, color: Colors.white),
                title: const Text(
                  'Share File',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not implemented yet')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trash2, color: Colors.white),
                title: const Text(
                  'Delete File',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not implemented yet')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.info, color: Colors.white),
                title: const Text(
                  'Song Details & Frequency',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not implemented yet')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);
    final song = playback.currentSong;

    if (song == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Text('No song playing', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.chevronDown,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Text(
                    'Now Playing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.listMusic,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Open queue
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Large Album Art
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: OptimizedImage(
                        imagePath: song.artPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Song Info and Favorite Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist ?? 'Unknown Artist',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        song.isFavorite ? Icons.star : Icons.star_border,
                        color: song.isFavorite ? Colors.yellow : Colors.white,
                      ),
                      onPressed: () =>
                          ref.read(playbackProvider.notifier).toggleFavorite(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Seek Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.yellow[200],
                      inactiveTrackColor: const Color(0xFF2C2C2C),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: SquigglySlider(
                      value: playback.duration.inMilliseconds > 0
                          ? (playback.position.inMilliseconds /
                                    playback.duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                          : 0.0,
                      onChanged: (val) {
                        ref
                            .read(playbackProvider.notifier)
                            .seek(playback.duration * val);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(playback.position),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(playback.duration),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Playback Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.skipBack,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          ref.read(playbackProvider.notifier).skipPrevious(),
                    ),
                  ),
                  // Play/Pause
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: IconButton(
                      iconSize: 32,
                      icon: Icon(
                        playback.isPlaying
                            ? LucideIcons.pause
                            : LucideIcons.play,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          ref.read(playbackProvider.notifier).togglePlay(),
                    ),
                  ),
                  // Next
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.skipForward,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          ref.read(playbackProvider.notifier).skipNext(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Shuffle
                  Container(
                    decoration: BoxDecoration(
                      color: playback.isShuffle
                          ? Colors.yellow[200]
                          : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        LucideIcons.shuffle,
                        color: playback.isShuffle ? Colors.black : Colors.white,
                      ),
                      onPressed: () =>
                          ref.read(playbackProvider.notifier).toggleShuffle(),
                    ),
                  ),
                  // Repeat
                  Container(
                    decoration: BoxDecoration(
                      color: playback.repeatMode != RepeatMode.off
                          ? Colors.yellow[200]
                          : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        playback.repeatMode == RepeatMode.one
                            ? LucideIcons.repeat1
                            : LucideIcons.repeat,
                        color: playback.repeatMode != RepeatMode.off
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: () =>
                          ref.read(playbackProvider.notifier).nextRepeatMode(),
                    ),
                  ),
                  // Lyrics
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(LucideIcons.mic2, color: Colors.white),
                      onPressed: () {
                        // Open lyrics
                      },
                    ),
                  ),
                  // More Options (Three dots)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        LucideIcons.moreVertical,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          _showMoreOptionsBottomSheet(context, ref),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
