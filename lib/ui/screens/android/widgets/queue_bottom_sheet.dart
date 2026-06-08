import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

import 'package:looper_player/l10n/app_localizations.dart';

class QueueBottomSheet extends ConsumerWidget {
  const QueueBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(playbackProvider.select((s) => s.queue));
    final currentSongPath = ref.watch(playbackProvider.select((s) => s.currentSong?.path));
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.playQueue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${queue.length} ${l10n.songs.toLowerCase()}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: queue.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(playbackProvider.notifier)
                    .reorderQueue(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final song = queue[index];
                final isCurrent = currentSongPath == song.path;

                return ListTile(
                  key: ValueKey('queue_sheet_${song.path}_$index'),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: OptimizedImage(
                      imagePath: song.artPath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                      color: isCurrent ? Colors.yellow[200] : Colors.white,
                      fontWeight: isCurrent
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    song.artist ?? 'Unknown Artist',
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCurrent)
                        const Icon(
                          LucideIcons.volume2,
                          color: Colors.yellow,
                          size: 20,
                        ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.x,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          ref
                              .read(playbackProvider.notifier)
                              .removeFromQueue(index);
                        },
                      ),
                      const Icon(LucideIcons.gripVertical, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    ref.read(playbackProvider.notifier).playAtIndex(index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
