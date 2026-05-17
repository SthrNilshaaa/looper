import 'package:flutter/foundation.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/ui/widgets/global_playing_indicator.dart';

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
  final String? searchQuery;

  const SongsList({
    super.key,
    required this.songs,
    this.shrinkWrap = false,
    this.physics,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${songs.length} ${l10n.songs}',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showSortBottomSheet(context, ref, l10n),
                    icon: const Icon(LucideIcons.listFilter, size: 18),
                    tooltip: 'Sort By',
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (!Platform.isAndroid)
                    TextButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.resetLibrary),
                            content: const Text(
                              'This will clear all songs, albums, and artists and perform a full rescan of your folders.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(libraryProvider.notifier)
                              .resetAndRescan();
                        }
                      },
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: Text(
                        l10n.resetLibrary,
                        style: const TextStyle(fontSize: 13),
                      ),
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
            physics: physics ?? const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 180),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return _SongTile(
                song: song,
                l10n: l10n,
                songs: songs,
                searchQuery: searchQuery,
              );
            },
          )
        else
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(libraryProvider.notifier).scanSavedFolders(),
              displacement: 20,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              color: Theme.of(context).colorScheme.primary,
              child: ListView.builder(
                shrinkWrap: false,
                physics: physics ??
                    const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 180),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return _SongTile(
                    song: song,
                    l10n: l10n,
                    songs: songs,
                    searchQuery: searchQuery,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

void _showSongOptions(
  BuildContext context,
  WidgetRef ref,
  Song song,
  AppLocalizations l10n,
) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
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
          const Divider(color: Colors.white10, height: 32),
          ListTile(
            leading: const Icon(
              LucideIcons.playCircle,
              color: Colors.blueAccent,
            ),
            title: const Text(
              'Play Next',
              style: TextStyle(fontWeight: FontWeight.w500),
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
              style: TextStyle(fontWeight: FontWeight.w500),
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
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(
              LucideIcons.listMusic,
              color: Colors.orangeAccent,
            ),
            title: Text(
              'Add to ${l10n.playlists}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
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
            title: Text(
              song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
            ),
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

void _showPlaylistSelector(
  BuildContext context,
  WidgetRef ref,
  Song song,
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
                  final playlist = playlists[index];
                  return ListTile(
                    leading: const Icon(LucideIcons.listMusic),
                    title: Text(playlist.name),
                    onTap: () async {
                      if (!playlist.songPaths.contains(song.path)) {
                        playlist.songPaths = [...playlist.songPaths, song.path];
                        playlist.dateModified = DateTime.now();
                        await DbService.isar.writeTxn(
                          () => DbService.isar.playlists.put(playlist),
                        );
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

class _SongTile extends ConsumerWidget {
  final Song song;
  final List<Song> songs;
  final AppLocalizations l10n;
  final String? searchQuery;

  const _SongTile({
    required this.song,
    required this.songs,
    required this.l10n,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isCurrent = ref.watch(playbackProvider).currentSong?.id == song.id;

    String? lyricSnippet;
    if (searchQuery != null && searchQuery!.isNotEmpty && song.lyrics != null) {
      lyricSnippet = _getLyricSnippet(song.lyrics!, searchQuery!);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Hero(
        tag: 'song_art_${song.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              OptimizedImage(
                imagePath: song.artPath,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
              if (isCurrent && ref.watch(playbackProvider).isPlaying)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Center(
                      child: Image.asset(
                        'assets/android_icons/Playing.gif',
                        width: 24,
                        height: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isCurrent
              ? Theme.of(context).colorScheme.primary
              : Colors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              if (song.artist != null) {
                final artistSongs = await DbService.isar.songs
                    .filter()
                    .artistEqualTo(song.artist!)
                    .findAll();
                final artist = await DbService.isar.artists
                    .filter()
                    .nameEqualTo(song.artist!)
                    .findFirst();
                ref
                    .read(appNavigationProvider.notifier)
                    .showCollection(
                      title: song.artist!,
                      subtitle: l10n.artists,
                      art:
                          artist?.artPath ??
                          song.artPath, // Use song art as fallback
                      imageUrl: artist?.artistImageUrl,
                      songs: artistSongs,
                    );
              }
            },
            child: Text(
              song.artist ?? l10n.unknownArtist,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (lyricSnippet != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  LucideIcons.quote,
                  size: 10,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    lyricSnippet,
                    style: TextStyle(
                      color: Colors.blueAccent.withOpacity(0.7),
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () => _showSongOptions(context, ref, song, l10n),
      ),
      onTap: () {
        final index = songs.indexWhere((s) => s.id == song.id);
        if (index != -1) {
          ref
              .read(playbackProvider.notifier)
              .setPlaylist(songs, initialIndex: index);
        } else {
          ref.read(playbackProvider.notifier).play(song);
        }
      },
    );
  }

  String? _getLyricSnippet(String lyrics, String query) {
    final lowerLyrics = lyrics.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerLyrics.indexOf(lowerQuery);
    if (index == -1) return null;

    // Find the start of the line
    int start = index;
    while (start > 0 && lyrics[start - 1] != '\n') {
      start--;
      if (index - start > 40) break; // Limit backward search
    }

    // Find the end of the line
    int end = index + query.length;
    while (end < lyrics.length && lyrics[end] != '\n') {
      end++;
      if (end - index > 60) break; // Limit forward search
    }

    return lyrics.substring(start, end).trim();
  }
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  return "$twoDigitMinutes:$twoDigitSeconds";
}

void _showSortBottomSheet(
  BuildContext context,
  WidgetRef ref,
  AppLocalizations l10n,
) {
  final libraryState = ref.watch(libraryProvider);
  final currentStrategy = libraryState.sortStrategy;
  final isAscending = libraryState.isAscending;

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(libraryProvider);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sort Order',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          ref.read(libraryProvider.notifier).toggleSortOrder();
                        },
                        icon: Icon(
                          state.isAscending ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownAZ,
                          size: 18,
                        ),
                        label: Text(state.isAscending ? 'Ascending' : 'Descending'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _SortOption(
                            label: 'Date Added',
                            icon: LucideIcons.calendar,
                            isSelected: state.sortStrategy == SongSortStrategy.dateAdded,
                            onTap: () {
                              ref
                                  .read(libraryProvider.notifier)
                                  .setSortStrategy(SongSortStrategy.dateAdded);
                              Navigator.pop(context);
                            },
                          ),
                          _SortOption(
                            label: 'Title',
                            icon: LucideIcons.type,
                            isSelected: state.sortStrategy == SongSortStrategy.title,
                            onTap: () {
                              ref
                                  .read(libraryProvider.notifier)
                                  .setSortStrategy(SongSortStrategy.title);
                              Navigator.pop(context);
                            },
                          ),
                          _SortOption(
                            label: 'Artist',
                            icon: LucideIcons.mic2,
                            isSelected: state.sortStrategy == SongSortStrategy.artist,
                            onTap: () {
                              ref
                                  .read(libraryProvider.notifier)
                                  .setSortStrategy(SongSortStrategy.artist);
                              Navigator.pop(context);
                            },
                          ),
                          _SortOption(
                            label: 'Album',
                            icon: LucideIcons.disc,
                            isSelected: state.sortStrategy == SongSortStrategy.album,
                            onTap: () {
                              ref
                                  .read(libraryProvider.notifier)
                                  .setSortStrategy(SongSortStrategy.album);
                              Navigator.pop(context);
                            },
                          ),
                          _SortOption(
                            label: 'Duration',
                            icon: LucideIcons.clock,
                            isSelected: state.sortStrategy == SongSortStrategy.duration,
                            onTap: () {
                              ref
                                  .read(libraryProvider.notifier)
                                  .setSortStrategy(SongSortStrategy.duration);
                              Navigator.pop(context);
                            },
                          ),
                          _SortOption(
                            label: 'Year',
                            icon: LucideIcons.calendarDays,
                            isSelected: state.sortStrategy == SongSortStrategy.year,
                            onTap: () {
                              ref
                                  .read(libraryProvider.notifier)
                                  .setSortStrategy(SongSortStrategy.year);
                              Navigator.pop(context);
                            },
                          ),
                          _SortOption(
                            label: 'Most Played',
                            icon: LucideIcons.trendingUp,
                            isSelected: state.sortStrategy == SongSortStrategy.playCount,
                            onTap: () {
                              ref
                                  .read(libraryProvider.notifier)
                                  .setSortStrategy(SongSortStrategy.playCount);
                              Navigator.pop(context);
                            },
                          ),
                          _SortOption(
                            label: 'Recently Played',
                            icon: LucideIcons.history,
                            isSelected: state.sortStrategy == SongSortStrategy.lastPlayed,
                            onTap: () {
                              ref
                                  .read(libraryProvider.notifier)
                                  .setSortStrategy(SongSortStrategy.lastPlayed);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  color: Colors.white,
                  size: 12,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
