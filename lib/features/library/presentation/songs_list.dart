import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'dart:io';
import 'dart:ui';
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
import 'package:looper_player/ui/screens/android/widgets/premium_section.dart';
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
                    tooltip: l10n.sortBy,
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
                            content: Text(
                              l10n.resetLibraryConfirm,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  l10n.reset,
                                  style: const TextStyle(color: Colors.red),
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
              return SongTile(
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
                  return SongTile(
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



class SongTile extends ConsumerWidget {
  final Song song;
  final List<Song> songs;
  final AppLocalizations l10n;
  final String? searchQuery;
  final Playlist? playlist;

  const SongTile({
    required this.song,
    required this.songs,
    required this.l10n,
    this.searchQuery,
    this.playlist,
    super.key,
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
    
    final isCurrent = ref.watch(playbackProvider.select((s) => s.currentSong?.path == song.path));
    final isPlaying = ref.watch(playbackProvider.select((s) => s.isPlaying));

    String? lyricSnippet;
    if (searchQuery != null && searchQuery!.isNotEmpty && song.lyrics != null) {
      lyricSnippet = _getLyricSnippet(song.lyrics!, searchQuery!);
    }

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 4, top: 0, bottom: 0),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            OptimizedImage(
              imagePath: song.artPath,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isCurrent && isPlaying ? 1.0 : 0.0,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
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
                color: Colors.white.withValues(alpha: 0.5),
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
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
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
                        color: Colors.white.withValues(alpha: 0.75),
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
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    isScrollControlled: true,
    builder: (context) {
      return Consumer(
        builder: (context, ref, child) {
          final state = ref.watch(libraryProvider);
          final settings = ref.watch(settingsProvider);
          final useBlur = settings.enableDynamicTheming && !settings.disableBlur;
          final isPureBlack = settings.darkTheme;
          final accentColor = Color(settings.accentColor);

          final sheetBg = isPureBlack 
              ? Colors.black 
              : (useBlur ? Colors.black.withValues(alpha: 0.6) : const Color(0xFF1E1E1E));

          Widget sheetContent = Container(
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: isPureBlack ? Colors.white10 : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          l10n.sortOrder,
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'DMSans',
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ref.read(libraryProvider.notifier).toggleSortOrder();
                        },
                        icon: Icon(
                          state.isAscending ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownAZ,
                          size: 18,
                        ),
                        label: Text(state.isAscending ? l10n.ascending : l10n.descending),
                        style: TextButton.styleFrom(
                          foregroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: PremiumSection(
                          borderRadius: BorderRadius.circular(20),
                          padding: EdgeInsets.zero,
                          useExpanded: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SortOption(
                                label: l10n.dateAdded,
                                icon: LucideIcons.calendar,
                                isSelected: state.sortStrategy == SongSortStrategy.dateAdded,
                                accentColor: accentColor,
                                isLast: false,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(libraryProvider.notifier)
                                      .setSortStrategy(SongSortStrategy.dateAdded);
                                  Navigator.pop(context);
                                },
                              ),
                              _SortOption(
                                label: l10n.title,
                                icon: LucideIcons.type,
                                isSelected: state.sortStrategy == SongSortStrategy.title,
                                accentColor: accentColor,
                                isLast: false,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(libraryProvider.notifier)
                                      .setSortStrategy(SongSortStrategy.title);
                                  Navigator.pop(context);
                                },
                              ),
                              _SortOption(
                                label: l10n.artist,
                                icon: LucideIcons.mic2,
                                isSelected: state.sortStrategy == SongSortStrategy.artist,
                                accentColor: accentColor,
                                isLast: false,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(libraryProvider.notifier)
                                      .setSortStrategy(SongSortStrategy.artist);
                                  Navigator.pop(context);
                                },
                              ),
                              _SortOption(
                                label: l10n.album,
                                icon: LucideIcons.disc,
                                isSelected: state.sortStrategy == SongSortStrategy.album,
                                accentColor: accentColor,
                                isLast: false,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(libraryProvider.notifier)
                                      .setSortStrategy(SongSortStrategy.album);
                                  Navigator.pop(context);
                                },
                              ),
                              _SortOption(
                                label: l10n.duration,
                                icon: LucideIcons.clock,
                                isSelected: state.sortStrategy == SongSortStrategy.duration,
                                accentColor: accentColor,
                                isLast: false,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(libraryProvider.notifier)
                                      .setSortStrategy(SongSortStrategy.duration);
                                  Navigator.pop(context);
                                },
                              ),
                              _SortOption(
                                label: l10n.year,
                                icon: LucideIcons.calendarDays,
                                isSelected: state.sortStrategy == SongSortStrategy.year,
                                accentColor: accentColor,
                                isLast: false,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(libraryProvider.notifier)
                                      .setSortStrategy(SongSortStrategy.year);
                                  Navigator.pop(context);
                                },
                              ),
                              _SortOption(
                                label: l10n.mostPlayed,
                                icon: LucideIcons.trendingUp,
                                isSelected: state.sortStrategy == SongSortStrategy.playCount,
                                accentColor: accentColor,
                                isLast: false,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(libraryProvider.notifier)
                                      .setSortStrategy(SongSortStrategy.playCount);
                                  Navigator.pop(context);
                                },
                              ),
                              _SortOption(
                                label: l10n.recentlyPlayed,
                                icon: LucideIcons.history,
                                isSelected: state.sortStrategy == SongSortStrategy.lastPlayed,
                                accentColor: accentColor,
                                isLast: true,
                                onTap: () {
                                  HapticFeedback.lightImpact();
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
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );

          final bool showBlur = useBlur && !settings.enableDynamicTheming;

          if (showBlur && !isPureBlack) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: sheetContent,
              ),
            );
          }

          return sheetContent;
        },
      );
    },
  );
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color accentColor;
  final bool isLast;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.accentColor,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.8,
            color: Colors.white.withValues(alpha: 0.04),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}
