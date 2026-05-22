import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/library/presentation/songs_list.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:isar/isar.dart';

class CategoryDetailWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  const CategoryDetailWrapper({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    String translatedTitle = title;
    switch (title) {
      case 'Albums':
        translatedTitle = UiUtils.tr(context, 'Albums', 'एल्बम');
        break;
      case 'Artists':
        translatedTitle = UiUtils.tr(context, 'Artists', 'कलाकार');
        break;
      case 'Genres':
        translatedTitle = UiUtils.tr(context, 'Genres', 'शैलियां');
        break;
      case 'Folders':
        translatedTitle = UiUtils.tr(context, 'Folders', 'फ़ोल्डर');
        break;
      case 'Queue':
        translatedTitle = UiUtils.tr(context, 'Queue', 'कतार');
        break;
      case 'History':
        translatedTitle = UiUtils.tr(context, 'History', 'इतिहास');
        break;
      case 'Favorites':
        translatedTitle = UiUtils.tr(context, 'Favorites', 'पसंदीदा');
        break;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(translatedTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
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
        if (albums.isEmpty) return Center(child: Text(UiUtils.tr(context, 'No albums found', 'कोई एल्बम नहीं मिला')));

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
                  subtitle: album.artist ?? UiUtils.tr(context, 'Unknown Artist', 'अज्ञात कलाकार'),
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
                  Text(album.artist ?? UiUtils.tr(context, 'Unknown Artist', 'अज्ञात कलाकार'), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
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

    if (artists.isEmpty) return Center(child: Text(UiUtils.tr(context, 'No artists found', 'कोई कलाकार नहीं मिला')));

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
              subtitle: UiUtils.tr(context, 'Artist', 'कलाकार'),
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
    final genresMap = <String, List<Song>>{};
    for (var song in songs) {
      final genre = song.genre ?? UiUtils.tr(context, 'Unknown', 'अज्ञात');
      genresMap.putIfAbsent(genre, () => []).add(song);
    }
    final genres = genresMap.keys.toList()..sort();

    return GridView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 200),
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
            subtitle: UiUtils.tr(context, 'Genre', 'शैली'),
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
                Text('${genreSongs.length} ${UiUtils.tr(context, 'songs', 'गाने')}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
          trailing: Text('${folderSongs.length} ${UiUtils.tr(context, 'songs', 'गाने')}'),
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
