import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/ui_utils.dart';

class QueueView extends ConsumerWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: Platform.isAndroid ? 12 : 24,
          ),
          child: Row(
            children: [
              if (!Platform.isAndroid)
                const Text(
                  'Play Queue',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.normal),
                ),
              const Spacer(),
              if (playback.queue.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      ref.read(playbackProvider.notifier).clearQueue(),
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: Text(UiUtils.tr(context, 'Clear', 'साफ़ करें')),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ),
        Expanded(
          child: playback.queue.isEmpty
              ? Center(
                  child: Text(
                    UiUtils.tr(context, 'Queue is empty', 'कतार खाली है'),
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ReorderableListView.builder(
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 16,
                    bottom: Platform.isAndroid ? 200 : 16,
                  ),
                  itemCount: playback.queue.length,
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(playbackProvider.notifier)
                        .reorderQueue(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final song = playback.queue[index];
                    final isCurrent = playback.currentSong?.id == song.id;

                    return Dismissible(
                      key: ValueKey('queue_view_${song.path}_$index'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        ref
                            .read(playbackProvider.notifier)
                            .removeFromQueue(index);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        color: Colors.red.withOpacity(0.1),
                        child: const Icon(LucideIcons.x, color: Colors.red),
                      ),
                      child: AnimatedContainer(
                        key: ValueKey('queue_tile_${song.path}_$index'),
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.5)
                              : Colors.white.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: OptimizedImage(
                            imagePath: song.artPath,
                            width: 44,
                            height: 44,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Text(
                            song.title,
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.normal
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            song.artist ?? 'Unknown Artist',
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(right: 20.0),
                            child: const Icon(
                              LucideIcons.gripVertical,
                              size: 24,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () =>
                              ref.read(playbackProvider.notifier).playAtIndex(index),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
