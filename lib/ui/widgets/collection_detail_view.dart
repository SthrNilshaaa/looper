import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

class CollectionDetailView extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final String? artPath;
  final String? imageUrl;
  final List<Song> songs;

  const CollectionDetailView({
    super.key,
    required this.title,
    this.subtitle,
    this.artPath,
    this.imageUrl,
    required this.songs,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 700;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal:  isNarrow ? 16 : 32,
                  vertical: isNarrow ? 12 : 16,
                ),
                child: isNarrow
                    ? Column(
                        children: [
                          _buildArt(context, isNarrow),
                          const SizedBox(height: 24),
                          _buildInfo(context, ref, isNarrow),
                        ],
                      )
                    : Row(
                        children: [
                          _buildArt(context, isNarrow),
                          const SizedBox(width: 32),
                          Expanded(child: _buildInfo(context, ref, isNarrow)),
                        ],
                      ),
              ),
              // Songs List
              SongsList(
                songs: songs,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildArt(BuildContext context, bool isNarrow) {
    final double size = isNarrow ? 160 : 200;
    return OptimizedImage(
      imagePath: artPath,
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(16),
      placeholder: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          LucideIcons.music,
          size: isNarrow ? 48 : 64,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, WidgetRef ref, bool isNarrow) {
    return Column(
      crossAxisAlignment: isNarrow
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isNarrow ? 32 : 48,
            fontWeight: FontWeight.normal,
          ),
          textAlign: isNarrow ? TextAlign.center : TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: isNarrow ? 18 : 24,
              color: Colors.grey[400],
            ),
            textAlign: isNarrow ? TextAlign.center : TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        // const SizedBox(height: 16),
        // Text('${songs.length} songs', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: isNarrow
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                ref.read(playbackProvider.notifier).setPlaylist(songs);
              },
              icon: Icon(Icons.play_arrow_sharp),
              label: const Text('Play All'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isNarrow ? 12 : 18,
                  vertical: isNarrow ? 12 : 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton.filledTonal(
              onPressed: () {
                ref.read(playbackProvider.notifier).toggleShuffle();
                ref.read(playbackProvider.notifier).setPlaylist(songs);
              },
              icon: const Icon(LucideIcons.shuffle, size: 8),
            ),
          ],
        ),
      ],
    );
  }
}
