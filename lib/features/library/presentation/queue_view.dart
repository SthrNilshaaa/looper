import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';

class QueueView extends ConsumerWidget {
  const QueueView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Text('Play Queue', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (playback.queue.isNotEmpty)
                TextButton.icon(
                  onPressed: () => ref.read(playbackProvider.notifier).clearQueue(),
                  icon: const Icon(LucideIcons.trash2, size: 18),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ),
        Expanded(
          child: playback.queue.isEmpty
            ? const Center(child: Text('Queue is empty'))
            : ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: playback.queue.length,
                onReorder: (oldIndex, newIndex) {
                  ref.read(playbackProvider.notifier).reorderQueue(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final song = playback.queue[index];
                  final isCurrent = playback.currentSong?.id == song.id;

                  return Dismissible(
                    key: ValueKey(song.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      ref.read(playbackProvider.notifier).removeFromQueue(index);
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: Colors.red.withOpacity(0.1),
                      child: const Icon(LucideIcons.x, color: Colors.red),
                    ),
                    child: Container(
                      key: ValueKey('tile_${song.id}'),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isCurrent ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: song.artPath != null 
                              ? DecorationImage(image: FileImage(File(song.artPath!)), fit: BoxFit.cover)
                              : null,
                          ),
                          child: song.artPath == null ? const Icon(LucideIcons.music) : null,
                        ),
                        title: Text(
                          song.title,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        subtitle: Text(song.artist ?? 'Unknown Artist', style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(LucideIcons.gripVertical, size: 18, color: Colors.grey),
                        onTap: () => ref.read(playbackProvider.notifier).play(song),
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
