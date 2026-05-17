import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:isar/isar.dart';

class CategoryDetailWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const CategoryDetailWrapper({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => Navigator.pop(context),
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
    return StreamBuilder<List<Album>>(
      stream: DbService.isar.albums.where().sortByName().watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final albums = snapshot.data!;
        if (albums.isEmpty) return const Center(child: Text('No albums found'));

        return GridView.builder(
          padding: const EdgeInsets.all(24),
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
                  subtitle: album.artist ?? 'Unknown Artist',
                  art: album.artPath,
                  songs: songs,
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Hero(
                      tag: 'collection_${album.name}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: OptimizedImage(
                          imagePath: album.artPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(album.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(album.artist ?? 'Unknown Artist', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
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

    if (artists.isEmpty) return const Center(child: Text('No artists found'));

    return GridView.builder(
      padding: const EdgeInsets.all(24),
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
              subtitle: 'Artist',
              art: artist.artPath,
              imageUrl: artist.artistImageUrl,
              songs: songs,
            );
          },
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: 'collection_${artist.name}',
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white10,
                    backgroundImage: artist.artistImageUrl != null ? FileImage(File(artist.artistImageUrl!)) : null,
                    child: artist.artistImageUrl == null ? const Icon(LucideIcons.user, size: 40) : null,
                  ),
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
    final genresMap = <String, List<Song>>{};
    for (var song in songs) {
      final genre = song.genre ?? 'Unknown';
      genresMap.putIfAbsent(genre, () => []).add(song);
    }
    final genres = genresMap.keys.toList()..sort();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.5,
      ),
      itemCount: genres.length,
      itemBuilder: (context, index) {
        final genre = genres[index];
        final genreSongs = genresMap[genre]!;
        return InkWell(
          onTap: () => ref.read(appNavigationProvider.notifier).showCollection(
            title: genre,
            subtitle: 'Genre',
            songs: genreSongs,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.music, color: Colors.blueAccent),
                const SizedBox(height: 8),
                Text(genre, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text('${genreSongs.length} songs', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    final foldersMap = <String, List<Song>>{};
    for (var song in songs) {
      final folder = Directory(song.path).parent.path;
      foldersMap.putIfAbsent(folder, () => []).add(song);
    }
    final folders = foldersMap.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folderPath = folders[index];
        final folderName = folderPath.split(Platform.pathSeparator).last;
        final folderSongs = foldersMap[folderPath]!;
        return ListTile(
          leading: const Icon(LucideIcons.folder, color: Colors.amberAccent),
          title: Text(folderName),
          subtitle: Text(folderPath, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text('${folderSongs.length} songs'),
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
