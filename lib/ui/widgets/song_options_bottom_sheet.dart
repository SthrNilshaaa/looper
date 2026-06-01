import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/ui/screens/android/widgets/song_details_bottom_sheet.dart';
import 'package:looper_player/ui/screens/android/song/song_info_screen.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/playlists/data/playlist_service.dart';

void showSongOptionsBottomSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Song song,
  Playlist? playlist,
  bool showDeleteOption = true,
  bool showRenameOption = true,
}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _SongOptionsSheetContent(
      song: song,
      playlist: playlist,
      showDeleteOption: showDeleteOption,
      showRenameOption: showRenameOption,
    ),
  );
}

class _SongOptionsSheetContent extends ConsumerWidget {
  final Song song;
  final Playlist? playlist;
  final bool showDeleteOption;
  final bool showRenameOption;

  const _SongOptionsSheetContent({
    required this.song,
    this.playlist,
    required this.showDeleteOption,
    required this.showRenameOption,
  });

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: song.title);
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text(l10n.renameSong, style: const TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: l10n.newTitle,
              labelStyle: const TextStyle(color: Colors.grey),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final success = await ref
                    .read(playbackProvider.notifier)
                    .renameSong(song, controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Song renamed successfully' : 'Failed to rename song',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(l10n.rename, style: const TextStyle(color: Colors.yellow)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Text(l10n.deleteSong, style: const TextStyle(color: Colors.white)),
          content: Text(
            l10n.deleteSongConfirm,
            style: const TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final success = await ref.read(playbackProvider.notifier).deleteSong(song);
                if (context.mounted) {
                  Navigator.pop(context);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Song deleted successfully' : 'Failed to delete song',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showPlaylistSelector(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final playlists = ref.watch(playlistProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Text('Add to ${l10n.playlists}'),
        content: playlists.isEmpty
            ? const Text('No playlists created yet.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final p = playlists[index];
                    return ListTile(
                      leading: const Icon(LucideIcons.listMusic),
                      title: Text(p.name),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        if (!p.songPaths.contains(song.path)) {
                          p.songPaths = [...p.songPaths, song.path];
                          p.dateModified = DateTime.now();
                          await DbService.isar.writeTxn(
                            () => DbService.isar.playlists.put(p),
                          );
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          messenger.showSnackBar(
                            SnackBar(content: Text('Added to ${p.name}')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Beautiful Standardized Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                OptimizedImage(
                  imagePath: song.artPath,
                  width: 50,
                  height: 50,
                  borderRadius: BorderRadius.circular(8),
                  placeholder: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.music),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        song.artist ?? l10n.unknownArtist,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(
                      LucideIcons.playCircle,
                      color: Colors.blueAccent,
                    ),
                    title: const Text(
                      'Play Next',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      ref.read(playbackProvider.notifier).addNext(song);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Will play next'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      LucideIcons.listPlus,
                      color: Colors.greenAccent,
                    ),
                    title: const Text(
                      'Add to Queue',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      ref.read(playbackProvider.notifier).addToQueue(song);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to queue'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      LucideIcons.listMusic,
                      color: Colors.orangeAccent,
                    ),
                    title: Text(
                      'Add to ${l10n.playlists}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showPlaylistSelector(context, ref, l10n);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      song.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: song.isFavorite ? Colors.red : Colors.white70,
                    ),
                    title: Text(
                      song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      ref.read(libraryProvider.notifier).toggleFavorite(song);
                      Navigator.pop(context);
                    },
                  ),
                  if (playlist != null)
                    ListTile(
                      leading: const Icon(
                        LucideIcons.trash2,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Remove from Playlist',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await PlaylistService.removeSongFromPlaylist(playlist!, song);
                        if (context.mounted) {
                          Navigator.pop(context);
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Removed from Playlist')),
                          );
                        }
                      },
                    ),
                  if (showRenameOption)
                    ListTile(
                      leading: const Icon(LucideIcons.edit2, color: Colors.white70),
                      title: const Text(
                        'Rename File',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showRenameDialog(context, ref);
                      },
                    ),
                  ListTile(
                    leading: const Icon(
                      LucideIcons.info,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      'Song Details',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SongDetailsBottomSheet(song: song),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      LucideIcons.activity,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      'Technical Info & Frequency',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongInfoScreen(song: song),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      LucideIcons.share2,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      'Share',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      ref.read(playbackProvider.notifier).shareSong(song);
                      Navigator.pop(context);
                    },
                  ),
                  if (showDeleteOption)
                    ListTile(
                      leading: const Icon(
                        LucideIcons.trash2,
                        color: Colors.redAccent,
                      ),
                      title: const Text(
                        'Delete File',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteDialog(context, ref);
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
