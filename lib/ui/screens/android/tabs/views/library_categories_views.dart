import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/l10n/app_localizations.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:isar/isar.dart';

class CategoryDetailWrapper extends ConsumerWidget {
  final String title;
  final Widget child;
  const CategoryDetailWrapper({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    String translatedTitle = title;
    switch (title) {
      case 'Albums':
        translatedTitle = l10n.albums;
        break;
      case 'Artists':
        translatedTitle = l10n.artists;
        break;
      case 'Genres':
        translatedTitle = l10n.genres;
        break;
      case 'Folders':
        translatedTitle = l10n.folders;
        break;
      case 'Queue':
        translatedTitle = l10n.queue;
        break;
      case 'History':
        translatedTitle = l10n.history;
        break;
      case 'Favorites':
        translatedTitle = l10n.favorites;
        break;
      case 'Playlists':
        translatedTitle = l10n.playlists;
        break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(translatedTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => ref.read(appNavigationProvider.notifier).goBack(),
        ),
      ),
      body: child,
    );
  }
}

class AlbumsGridView extends ConsumerWidget {
  const AlbumsGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<List<Album>>(
      stream: DbService.isar.albums.where().sortByName().watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final albums = snapshot.data!;
        if (albums.isEmpty) return Center(child: Text(l10n.noAlbumsFound));

        return GridView.builder(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 200),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.8,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) {
            final album = albums[index];
            return InkWell(
              onTap: () async {
                final songs = await DbService.isar.songs.filter().albumEqualTo(album.name).findAll();
                ref.read(appNavigationProvider.notifier).showCollection(
                  title: album.name,
                  subtitle: album.artist ?? l10n.unknownArtist,
                  art: album.artPath,
                  songs: songs,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: OptimizedImage(
                        imagePath: album.artPath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(album.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(album.artist ?? l10n.unknownArtist, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ArtistsGridView extends ConsumerWidget {
  const ArtistsGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final artists = library.artists;
    final l10n = AppLocalizations.of(context)!;

    if (artists.isEmpty) return Center(child: Text(l10n.noArtistsFound));

    return GridView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 200),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return InkWell(
          onTap: () async {
            final songs = await DbService.isar.songs.filter().artistEqualTo(artist.name).findAll();
            ref.read(appNavigationProvider.notifier).showCollection(
              title: artist.name,
              subtitle: l10n.artist,
              art: artist.artPath,
              imageUrl: artist.artistImageUrl,
              songs: songs,
            );
          },
          child: Column(
            children: [
              Expanded(
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white10,
                  backgroundImage: artist.artistImageUrl != null ? FileImage(File(artist.artistImageUrl!)) : null,
                  child: artist.artistImageUrl == null ? const Icon(LucideIcons.user, size: 40) : null,
                ),
              ),
              const SizedBox(height: 12),
              Text(artist.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }
}

class GenresGridView extends ConsumerWidget {
  const GenresGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Isar doesn't have a distinct query easily for genres if they are just strings in Songs.
    // We'll fetch all songs and group them. For larger libraries, we should cache this.
    final songs = ref.watch(libraryProvider).songs;
    final l10n = AppLocalizations.of(context)!;
    final genresMap = <String, List<Song>>{};
    for (var song in songs) {
      final genre = song.genre ?? l10n.unknown;
      genresMap.putIfAbsent(genre, () => []).add(song);
    }
    final genres = genresMap.keys.toList()..sort();

    return GridView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 200),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.35,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        final genreSongs = genresMap[genre]!;
        
        // Hash the genre string to produce a consistent vibrant color gradient
        final int hash = genre.hashCode;
        final double hue = (hash.abs() % 360).toDouble();
        final Color startColor = HSLColor.fromAHSL(1.0, hue, 0.70, 0.35).toColor();
        final Color endColor = HSLColor.fromAHSL(1.0, (hue + 45) % 360, 0.80, 0.18).toColor();

        // Get first song with art if available
        final firstSongWithArt = genreSongs.firstWhere(
          (s) => s.artPath != null,
          orElse: () => genreSongs.first,
        );

        return InkWell(
          onTap: () => ref.read(appNavigationProvider.notifier).showCollection(
            title: genre,
            subtitle: l10n.genre,
            songs: genreSongs,
          ),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Rotated Album Art in the bottom right corner
                if (firstSongWithArt.artPath != null)
                  Positioned(
                    bottom: -12,
                    right: -12,
                    child: Transform.rotate(
                      angle: 0.25,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: OptimizedImage(
                            imagePath: firstSongWithArt.artPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: Transform.rotate(
                      angle: 0.25,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.music,
                          size: 28,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                
                // Genre info on the left side
                Positioned(
                  left: 16,
                  top: 16,
                  bottom: 16,
                  right: 56, // Leave room so text doesn't overlap the album art too much
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        genre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${genreSongs.length} ${l10n.songs}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FoldersListView extends ConsumerWidget {
  const FoldersListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(libraryProvider).songs;
    final l10n = AppLocalizations.of(context)!;
    final foldersMap = <String, List<Song>>{};
    for (var song in songs) {
      final folder = Directory(song.path).parent.path;
      foldersMap.putIfAbsent(folder, () => []).add(song);
    }
    final folders = foldersMap.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 200),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folderPath = folders[index];
        final folderName = folderPath.split(Platform.pathSeparator).last;
        final folderSongs = foldersMap[folderPath]!;
        return ListTile(
          leading: const Icon(LucideIcons.folder, color: Colors.amberAccent),
          title: Text(folderName),
          subtitle: Text(folderPath, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text('${folderSongs.length} ${l10n.songs}'),
          onTap: () => ref.read(appNavigationProvider.notifier).showCollection(
            title: folderName,
            subtitle: folderPath,
            songs: folderSongs,
          ),
        );
      },
    );
  }
}
