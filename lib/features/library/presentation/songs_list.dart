import 'package:flutter/foundation.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/ui/widgets/global_playing_indicator.dart';

import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/playlists/presentation/playlist_view.dart';
import 'package:looper_player/features/playlists/data/playlist_service.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';

import 'package:file_picker/file_picker.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/screens/android/song/song_info_screen.dart';
import 'package:looper_player/ui/screens/android/widgets/song_details_bottom_sheet.dart';
import 'package:looper_player/ui/widgets/song_options_bottom_sheet.dart';

class SongsList extends ConsumerWidget {
  final List<Song> songs;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final String? searchQuery;
  final Playlist? playlist;
  final ScrollController? controller;

  const SongsList({
    super.key,
    required this.songs,
    this.shrinkWrap = false,
    this.physics,
    this.searchQuery,
    this.playlist,
    this.controller,
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
            controller: controller,
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
                playlist: playlist,
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
                controller: controller,
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
                    playlist: playlist,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}



class _SongTile extends ConsumerWidget {
  final Song song;
  final List<Song> songs;
  final AppLocalizations l10n;
  final String? searchQuery;
  final Playlist? playlist;

  const _SongTile({
    required this.song,
    required this.songs,
    required this.l10n,
    this.searchQuery,
    this.playlist,
  });

  Widget _buildHighlightedText({
    required BuildContext context,
    required String text,
    required String query,
    required TextStyle baseStyle,
    required TextStyle highlightStyle,
  }) {
    if (query.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);

    if (index == -1) {
      return Text(text, style: baseStyle);
    }

    final List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
      // Add text before match
      if (indexOfMatch > start) {
        spans.add(TextSpan(
          text: text.substring(start, indexOfMatch),
          style: baseStyle,
        ));
      }
      // Add matched text
      spans.add(TextSpan(
        text: text.substring(indexOfMatch, indexOfMatch + query.length),
        style: highlightStyle,
      ));
      start = indexOfMatch + query.length;
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final isCurrent = ref.watch(playbackProvider).currentSong?.path == song.path;

    String? lyricSnippet;
    if (searchQuery != null && searchQuery!.isNotEmpty && song.lyrics != null) {
      lyricSnippet = _getLyricSnippet(song.lyrics!, searchQuery!);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            OptimizedImage(
              imagePath: song.artPath,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isCurrent && ref.watch(playbackProvider).isPlaying ? 1.0 : 0.0,
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
            ),
          ],
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
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.quote,
                    size: 9,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildHighlightedText(
                      context: context,
                      text: lyricSnippet,
                      query: searchQuery ?? '',
                      baseStyle: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                      highlightStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onPressed: () => showSongOptionsBottomSheet(
          context: context,
          ref: ref,
          song: song,
          playlist: playlist,
        ),
      ),
      onTap: () {
        final index = songs.indexWhere((s) => s.path == song.path);
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

    int start = index;
    bool truncatedStart = false;
    while (start > 0 && lyrics[start - 1] != '\n') {
      start--;
      if (index - start > 40) {
        truncatedStart = true;
        break;
      }
    }

    int end = index + query.length;
    bool truncatedEnd = false;
    while (end < lyrics.length && lyrics[end] != '\n') {
      end++;
      if (end - index > 60) {
        truncatedEnd = true;
        break;
      }
    }

    String snippet = lyrics.substring(start, end).trim();
    if (truncatedStart) snippet = '...$snippet';
    if (truncatedEnd) snippet = '$snippet...';
    return snippet;
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
