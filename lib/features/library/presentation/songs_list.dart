import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';

import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';

import 'package:file_picker/file_picker.dart';
import 'package:looper_player/l10n/app_localizations.dart';

class SongsList extends ConsumerWidget {
  final List<Song> songs;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const SongsList({
    super.key, 
    required this.songs,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${songs.length} ${l10n.songs}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final String? path = await FilePicker.platform.getDirectoryPath();
                      if (path != null) {
                        ref.read(libraryProvider.notifier).scanLibrary(path);
                      }
                    },
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: Text(l10n.addFolder, style: const TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.resetLibrary),
                          content: const Text('This will clear all songs, albums, and artists and perform a full rescan of your folders.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true), 
                              child: const Text('Reset', style: TextStyle(color: Colors.red))
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await ref.read(libraryProvider.notifier).resetAndRescan();
                      }
                    },
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: Text(l10n.resetLibrary, style: const TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      foregroundColor: Colors.red[300],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (shrinkWrap)
          ListView.builder(
            shrinkWrap: true,
            physics: physics,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return _SongTile(song: song, l10n: l10n);
            },
          )
        else
          Expanded(
            child: ListView.builder(
              shrinkWrap: false,
              physics: physics,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return _SongTile(song: song, l10n: l10n);
              },
            ),
          ),
      ],
    );
  }
}

void _showSongOptions(BuildContext context, WidgetRef ref, Song song, AppLocalizations l10n) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1A1A1A),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: song.artPath != null 
                      ? DecorationImage(image: FileImage(File(song.artPath!)), fit: BoxFit.cover)
                      : null,
                    color: Colors.white10,
                  ),
                  child: song.artPath == null ? const Icon(LucideIcons.music) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(song.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(song.artist ?? l10n.unknownArtist, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 32),
          ListTile(
            leading: const Icon(LucideIcons.playCircle, color: Colors.blueAccent),
            title: const Text('Play Next', style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () {
              ref.read(playbackProvider.notifier).addNext(song);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Will play next'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          ListTile(
            leading: const Icon(LucideIcons.listPlus, color: Colors.greenAccent),
            title: const Text('Add to Queue', style: TextStyle(fontWeight: FontWeight.w500)),
            onTap: () {
              ref.read(playbackProvider.notifier).addToQueue(song);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to queue'), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(LucideIcons.listMusic, color: Colors.orangeAccent),
            title: Text('Add to ${l10n.playlists}', style: const TextStyle(fontWeight: FontWeight.w500)),
            onTap: () {
              Navigator.pop(context);
              _showPlaylistSelector(context, ref, song, l10n);
            },
          ),
          ListTile(
            leading: Icon(
              song.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: song.isFavorite ? Colors.red : Colors.white70,
            ),
            title: Text(song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
            onTap: () {
              ref.read(libraryProvider.notifier).toggleFavorite(song);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}

void _showPlaylistSelector(BuildContext context, WidgetRef ref, Song song, AppLocalizations l10n) {
  final playlists = ref.watch(playlistProvider);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title: Text('Add to ${l10n.playlists}'),
      content: playlists.isEmpty 
        ? const Text('No playlists created yet.')
        : SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  leading: const Icon(LucideIcons.listMusic),
                  title: Text(playlist.name),
                  onTap: () async {
                    if (!playlist.songPaths.contains(song.path)) {
                      playlist.songPaths = [...playlist.songPaths, song.path];
                      playlist.dateModified = DateTime.now();
                      await DbService.isar.writeTxn(() => DbService.isar.playlists.put(playlist));
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to ${playlist.name}')),
                    );
                  },
                );
              },
            ),
          ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    ),
  );
}

class _SongTile extends ConsumerWidget {
  final Song song;
  final AppLocalizations l10n;

  const _SongTile({required this.song, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final bool isDynamic = settings.enableDynamicTheming;
    final isCurrent = ref.watch(playbackProvider).currentSong?.id == song.id;

    return AnimatedContainer(
      key: ValueKey('tile_${song.id}'),
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrent 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.5) 
          : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: song.artPath != null 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.file(
                  File(song.artPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('❌ List Image error: $error for path: ${song.artPath}');
                    return const Icon(LucideIcons.music, size: 20);
                  },
                ),
              )
            : (isCurrent && ref.watch(playbackProvider).isPlaying
                ? const Icon(LucideIcons.volume2, size: 20)
                : const Icon(LucideIcons.music, size: 20)),
        ),
        title: Text(
          song.title,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.normal : FontWeight.normal,
            color: isCurrent ? Theme.of(context).colorScheme.primary : null,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: InkWell(
          onTap: () async {
            if (song.artist != null) {
              final artistSongs = await DbService.isar.songs.filter().artistEqualTo(song.artist!).findAll();
              ref.read(appNavigationProvider.notifier).showCollection(
                title: song.artist!,
                subtitle: l10n.artists,
                songs: artistSongs,
              );
            }
          },
          child: Text(
            song.artist ?? l10n.unknownArtist,
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(LucideIcons.moreVertical, size: 18, color: Colors.grey),
              onPressed: () => _showSongOptions(context, ref, song, l10n),
            ),
            IconButton(
              icon: Icon(
                song.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: song.isFavorite ? Colors.red : Colors.grey,
                size: 18,
              ),
              onPressed: () => ref.read(libraryProvider.notifier).toggleFavorite(song),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(Duration(milliseconds: song.duration ?? 0)),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          ref.read(playbackProvider.notifier).play(song);
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
