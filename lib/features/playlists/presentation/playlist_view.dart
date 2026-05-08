import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';

class PlaylistNotifier extends StateNotifier<List<Playlist>> {
  PlaylistNotifier() : super([]) {
    _loadPlaylists();
  }

  void _loadPlaylists() {
    DbService.isar.playlists
        .where()
        .sortByDateModifiedDesc()
        .watch(fireImmediately: true)
        .listen((playlists) {
          state = playlists;
        });
  }

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist()
      ..name = name
      ..songPaths = []
      ..dateCreated = DateTime.now()
      ..dateModified = DateTime.now();

    await DbService.isar.writeTxn(() => DbService.isar.playlists.put(playlist));
  }

  Future<void> deletePlaylist(int id) async {
    await DbService.isar.writeTxn(() => DbService.isar.playlists.delete(id));
  }
}

final playlistProvider =
    StateNotifierProvider<PlaylistNotifier, List<Playlist>>((ref) {
      return PlaylistNotifier();
    });

class PlaylistView extends ConsumerWidget {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: playlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.listMusic,
                    size: 64,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text('No playlists yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showCreateDialog(context, ref),
                    child: const Text('Create Playlist'),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.85,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: playlists.length,
              itemBuilder: (context, index) =>
                  _PlaylistCard(playlist: playlists[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Playlist name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(playlistProvider.notifier)
                    .createPlaylist(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _PlaylistCard extends ConsumerWidget {
  final Playlist playlist;
  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final songs = await DbService.isar.songs
            .filter()
            .anyOf(playlist.songPaths, (q, path) => q.pathEqualTo(path))
            .findAll();
        ref
            .read(appNavigationProvider.notifier)
            .showCollection(
              title: playlist.name,
              subtitle: 'Playlist',
              songs: songs,
            );
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primaryContainer
                    .withOpacity(
                      ref.watch(settingsProvider).enableDynamicTheming
                          ? 0.8
                          : 0.3,
                    ),
              ),
              child: const Center(child: Icon(LucideIcons.listMusic, size: 48)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.name,
            style: const TextStyle(fontWeight: FontWeight.normal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${playlist.songPaths.length} songs',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
