import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/core/navigation_provider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class SearchResults {
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> artists;

  SearchResults({required this.songs, required this.albums, required this.artists});
}

final searchResultsProvider = StreamProvider<SearchResults>((ref) {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return Stream.value(SearchResults(songs: [], albums: [], artists: []));
  
  return DbService.isar.songs
      .filter()
      .titleContains(query, caseSensitive: false)
      .or()
      .artistContains(query, caseSensitive: false)
      .or()
      .albumContains(query, caseSensitive: false)
      .watch(fireImmediately: true)
      .asyncMap((songs) async {
        final albums = await DbService.isar.albums.filter().nameContains(query, caseSensitive: false).findAll();
        final artists = await DbService.isar.artists.filter().nameContains(query, caseSensitive: false).findAll();
        return SearchResults(songs: songs, albums: albums, artists: artists);
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
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                ),
        ),
      ],
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.search, size: 64, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('Search your entire library', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResults(SearchResults results, WidgetRef ref, BuildContext context) {
    if (results.songs.isEmpty && results.albums.isEmpty && results.artists.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        _buildTopResult(results, ref, context),
        const SizedBox(height: 16),
        if (results.artists.isNotEmpty) ...[
          const Text('Artists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: results.artists.length,
              itemBuilder: (context, index) => _ArtistResultCard(artist: results.artists[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (results.albums.isNotEmpty) ...[
          const Text('Albums', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: results.albums.length,
              itemBuilder: (context, index) => _AlbumResultCard(album: results.albums[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (results.songs.length > 1) ...[
          const Text('Songs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
          const SizedBox(height: 12),
          SongsList(songs: results.songs.sublist(1), shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
        ],
      ],
    );
  }

  Widget _buildTopResult(SearchResults results, WidgetRef ref, BuildContext context) {
    if (results.songs.isEmpty) return const SizedBox.shrink();
    final topSong = results.songs.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Result', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
        const SizedBox(height: 12),
        _SongResultCard(song: topSong),
      ],
    );
  }
}

class _SongResultCard extends ConsumerWidget {
  final Song song;
  const _SongResultCard({required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCurrent = ref.watch(playbackProvider).currentSong?.id == song.id;
    
    return InkWell(
      onTap: () => ref.read(playbackProvider.notifier).play(song),
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
              : Colors.white10.withOpacity(0.05)
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: song.artPath != null 
                  ? DecorationImage(image: FileImage(File(song.artPath!)), fit: BoxFit.cover)
                  : null,
                color: Colors.white10,
              ),
              child: song.artPath == null ? const Icon(LucideIcons.music, size: 32) : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(song.artist ?? 'Unknown Artist', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(song.album ?? 'Unknown Album', style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.7))),
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
      ),
    );
  }
}

class _ArtistResultCard extends ConsumerWidget {
  final Artist artist;
  const _ArtistResultCard({required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        final songs = await DbService.isar.songs.filter().artistEqualTo(artist.name).findAll();
        ref.read(appNavigationProvider.notifier).showCollection(
          title: artist.name,
          subtitle: 'Artist',
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
              backgroundImage: artist.artPath != null ? FileImage(File(artist.artPath!)) : null,
              child: artist.artPath == null ? const Icon(LucideIcons.user) : null,
            ),
            const SizedBox(height: 8),
            Text(artist.name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
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
    return InkWell(
      onTap: () async {
        final songs = await DbService.isar.songs.filter().albumEqualTo(album.name).findAll();
        ref.read(appNavigationProvider.notifier).showCollection(
          title: album.name,
          subtitle: album.artist ?? 'Unknown Artist',
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
                  ? DecorationImage(image: FileImage(File(album.artPath!)), fit: BoxFit.cover)
                  : null,
                color: Colors.grey.withOpacity(ref.watch(settingsProvider).enableDynamicTheming ? 0.8 : 0.1),
              ),
              child: album.artPath == null ? const Center(child: Icon(LucideIcons.music)) : null,
            ),
            const SizedBox(height: 8),
            Text(album.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13)),
            Text(album.artist ?? 'Unknown Artist', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
