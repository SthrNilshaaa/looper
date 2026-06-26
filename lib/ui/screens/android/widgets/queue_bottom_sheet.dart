import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/app_fonts.dart';

import 'package:looper_player/l10n/app_localizations.dart';

class QueueBottomSheet extends ConsumerWidget {
  const QueueBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(playbackProvider.select((s) => s.queue));
    final currentSongPath = ref.watch(playbackProvider.select((s) => s.currentSong?.path));
    final l10n = AppLocalizations.of(context)!;

    // Rotate the queue list so that the current song is at the top
    final currentIdx = queue.indexWhere((s) => s.path == currentSongPath);
    final List<Song> displayedQueue;
    if (currentIdx != -1) {
      displayedQueue = [
        ...queue.sublist(currentIdx),
        ...queue.sublist(0, currentIdx),
      ];
    } else {
      displayedQueue = List.from(queue);
    }

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
                  style: AppFonts.jostStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${queue.length} ${l10n.songs.toLowerCase()}',
                  style: AppFonts.jostStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: displayedQueue.length,
              onReorder: (oldIndex, newIndex) {
                if (newIndex == 0) newIndex = 1;
                ref
                    .read(playbackProvider.notifier)
                    .reorderQueue(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final song = displayedQueue[index];
                final isCurrent = currentSongPath == song.path;
                final originalIndex = queue.indexWhere((s) => s.path == song.path);

                return Material(
                  key: ValueKey('queue_sheet_${song.path}_$index'),
                  color: Colors.transparent,
                  child: ListTile(
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
                      style: AppFonts.jostStyle(
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
                      style: AppFonts.jostStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isCurrent
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                                      .removeFromQueue(originalIndex);
                                },
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.x,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                  ref
                                      .read(playbackProvider.notifier)
                                      .removeFromQueue(originalIndex);
                                },
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(LucideIcons.gripVertical, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                    onTap: () {
                      ref.read(playbackProvider.notifier).playAtIndex(originalIndex);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
