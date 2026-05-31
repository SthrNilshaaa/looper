import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/playback/presentation/lyrics_search_provider.dart';
import 'package:looper_player/core/ui_utils.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchResults {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  SearchResults({
    required this.songs,
    required this.albums,
    required this.artists,
  });
}

final searchResultsProvider = StreamProvider<SearchResults>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty)
    return Stream.value(SearchResults(songs: [], albums: [], artists: []));

  return DbService.isar.songs
      .filter()
      .titleContains(query, caseSensitive: false)
      .or()
      .artistContains(query, caseSensitive: false)
      .or()
      .albumContains(query, caseSensitive: false)
      .or()
      .lyricsContains(query, caseSensitive: false)
      .watch(fireImmediately: true)
      .asyncMap((songs) async {
        final albums = await DbService.isar.albums
            .filter()
            .nameContains(query, caseSensitive: false)
            .findAll();
        final artists = await DbService.isar.artists
            .filter()
            .nameContains(query, caseSensitive: false)
            .findAll();

        // Sort songs: top match songs name > lyrics match > others
        final lowerQuery = query.toLowerCase();
        final sortedSongs = List<Song>.from(songs);
        sortedSongs.sort((a, b) {
          int getSongScore(Song song) {
            final title = song.title.toLowerCase();
            final lyrics = (song.lyrics ?? '').toLowerCase();
            final artist = (song.artist ?? '').toLowerCase();
            final album = (song.album ?? '').toLowerCase();

            // 1. Top Match Songs Name
            if (title == lowerQuery) return 100;
            if (title.startsWith(lowerQuery)) return 90;
            if (title.contains(lowerQuery)) return 80;

            // 2. Lyrics Match
            if (lyrics.contains(lowerQuery)) return 50;

            // 3. Others (Artist or Album contain query)
            if (artist.contains(lowerQuery) || album.contains(lowerQuery)) return 30;

            return 0;
          }

          final scoreA = getSongScore(a);
          final scoreB = getSongScore(b);
          
          if (scoreA != scoreB) {
            return scoreB.compareTo(scoreA); // Higher score first
          }
          
          // Secondary sort: alphabetical by title
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });

        return SearchResults(songs: sortedSongs, albums: albums, artists: artists);
      });
});

class SearchView extends ConsumerWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Column(
      children: [
        Expanded(
          child: query.isEmpty
              ? _buildRecentSearches(context)
              : resultsAsync.when(
                  data: (results) => _buildResults(results, ref, context),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
        ),
      ],
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.search,
            size: 64,
            color: Colors.grey.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.searchLibraryHint,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    SearchResults results,
    WidgetRef ref,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (results.songs.isEmpty &&
        results.albums.isEmpty &&
        results.artists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.noResultsFound),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 180),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTopResult(results, ref, context),
        ),
        const SizedBox(height: 16),
        if (results.artists.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.artists,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.artists.length,
              itemBuilder: (context, index) =>
                  _ArtistResultCard(artist: results.artists[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (results.albums.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.albums,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.albums.length,
              itemBuilder: (context, index) =>
                  _AlbumResultCard(album: results.albums[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (results.songs.length > 1) ...[
          SongsList(
            songs: results.songs.sublist(1),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            searchQuery: ref.read(searchQueryProvider),
          ),
        ],
      ],
    );
  }

  Widget _buildTopResult(
    SearchResults results,
    WidgetRef ref,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (results.songs.isEmpty) return const SizedBox.shrink();
    final topSong = results.songs.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.topResult,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
        ),
        const SizedBox(height: 12),
        _SongResultCard(
          song: topSong,
          searchQuery: ref.read(searchQueryProvider),
        ),
      ],
    );
  }
}

class _SongResultCard extends ConsumerWidget {
  final Song song;
  final String? searchQuery;
  const _SongResultCard({required this.song, this.searchQuery});

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
    final colorScheme = Theme.of(context).colorScheme;
    final isCurrent = ref.watch(playbackProvider).currentSong?.path == song.path;
    final l10n = AppLocalizations.of(context)!;

    String? lyricSnippet;
    if (searchQuery != null && searchQuery!.isNotEmpty && song.lyrics != null) {
      lyricSnippet = _getLyricSnippet(song.lyrics!, searchQuery!);
    }

    return InkWell(
      onTap: () {
        if (searchQuery != null) {
          ref.read(lyricsSearchQueryProvider.notifier).state = searchQuery!;
        }
        ref.read(playbackProvider.notifier).play(song);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent
              ? colorScheme.primary.withOpacity(0.5)
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? colorScheme.primary.withOpacity(0.2)
                : Colors.white10.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: song.artPath != null
                        ? DecorationImage(
                            image: FileImage(File(song.artPath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.white10,
                  ),
                  child: song.artPath == null
                      ? const Icon(LucideIcons.music, size: 32)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist ?? l10n.unknownArtist,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      if (lyricSnippet == null) ...[
                        const SizedBox(height: 2),
                        Text(
                          song.album ?? l10n.unknownAlbum,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ],
            ),
            if (lyricSnippet != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.quote,
                          size: 11,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.matchingLyrics,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildHighlightedText(
                      context: context,
                      text: lyricSnippet,
                      query: searchQuery ?? '',
                      baseStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        fontStyle: FontStyle.italic,
                      ),
                      highlightStyle: TextStyle(
                        fontSize: 13,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        backgroundColor: colorScheme.primary.withOpacity(0.12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
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

class _ArtistResultCard extends ConsumerWidget {
  final Artist artist;
  const _ArtistResultCard({required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () async {
        final songs = await DbService.isar.songs
            .filter()
            .artistEqualTo(artist.name)
            .findAll();
        ref
            .read(appNavigationProvider.notifier)
            .showCollection(
              title: artist.name,
              subtitle: l10n.artist,
              songs: songs,
              art: artist.artPath,
            );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.withOpacity(0.1),
              backgroundImage: artist.artPath != null
                  ? FileImage(File(artist.artPath!))
                  : null,
              child: artist.artPath == null
                  ? const Icon(LucideIcons.user)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumResultCard extends ConsumerWidget {
  final Album album;
  const _AlbumResultCard({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () async {
        final songs = await DbService.isar.songs
            .filter()
            .albumEqualTo(album.name)
            .findAll();
        ref
            .read(appNavigationProvider.notifier)
            .showCollection(
              title: album.name,
              subtitle: album.artist ?? l10n.unknownArtist,
              songs: songs,
              art: album.artPath,
            );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: album.artPath != null
                    ? DecorationImage(
                        image: FileImage(File(album.artPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey.withOpacity(
                  ref.watch(settingsProvider).enableDynamicTheming ? 0.8 : 0.1,
                ),
              ),
              child: album.artPath == null
                  ? const Center(child: Icon(LucideIcons.music))
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              album.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
            ),
            Text(
              album.artist ?? l10n.unknownArtist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
