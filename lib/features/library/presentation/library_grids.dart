import 'package:flutter/material.dart';
import 'package:looper_player/core/ui_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:isar/isar.dart';

// Providers for Albums and Artists
final albumsProvider = StreamProvider<List<Album>>((ref) {
  return DbService.isar.albums.where().sortByDateAddedDesc().watch(
    fireImmediately: true,
  );
});

final artistsProvider = StreamProvider<List<Artist>>((ref) {
  return DbService.isar.artists.where().sortByName().watch(
    fireImmediately: true,
  );
});

class AlbumsGrid extends ConsumerWidget {
  const AlbumsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDynamic = ref.watch(settingsProvider).enableDynamicTheming;
    final albumsAsync = ref.watch(albumsProvider);

    return albumsAsync.when(
      data: (albums) => GridView.builder(
        padding: EdgeInsets.all(24.s),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.s,
          childAspectRatio: 0.72,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) => _AlbumCard(album: albums[index]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _AlbumCard extends ConsumerWidget {
  final Album album;
  const _AlbumCard({required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDynamic = ref.watch(settingsProvider).enableDynamicTheming;
    final nav = ref.watch(appNavigationProvider);
    final isSelected =
        nav.activeItem == NavItem.collectionDetail &&
        nav.collectionTitle == album.name;

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
              subtitle: album.artist,
              art: album.artPath,
              songs: songs,
            );
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? const Color.fromARGB(
                  255,
                  53,
                  53,
                  53,
                ).withOpacity(isDynamic ? 0.3 : 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(color: Colors.white10.withOpacity(0.1), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  color: Colors.white.withOpacity(0.05),
                ),
                child: album.artPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: OptimizedImage(
                          imagePath: album.artPath,
                          fit: BoxFit.cover,
                          placeholder: const Center(
                            child: Icon(
                              LucideIcons.disc,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          LucideIcons.disc,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.name,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14.ts,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    album.artist ?? 'Unknown Artist',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12.ts),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArtistsGrid extends ConsumerWidget {
  const ArtistsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDynamic = ref.watch(settingsProvider).enableDynamicTheming;
    final artistsAsync = ref.watch(artistsProvider);

    return artistsAsync.when(
      data: (artists) => GridView.builder(
        padding: EdgeInsets.all(24.s),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 180.s,
          childAspectRatio: 0.8,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: artists.length,
        itemBuilder: (context, index) => _ArtistCard(artist: artists[index]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _ArtistCard extends ConsumerWidget {
  final Artist artist;
  const _ArtistCard({required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDynamic = ref.watch(settingsProvider).enableDynamicTheming;
    final nav = ref.watch(appNavigationProvider);
    final isSelected =
        nav.activeItem == NavItem.collectionDetail &&
        nav.collectionTitle == artist.name;

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
              art: artist.artPath,
              imageUrl: artist.artistImageUrl,
              songs: songs,
            );
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isSelected
              ? const Color.fromARGB(
                  255,
                  53,
                  53,
                  53,
                ).withOpacity(isDynamic ? 0.3 : 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(color: Colors.white10.withOpacity(0.1), width: 1)
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  color: Colors.white.withOpacity(0.05),
                ),
                child: ClipOval(
                  child: OptimizedImage(
                    imageUrl: artist.artistImageUrl,
                    imagePath: artist.artPath,
                    fit: BoxFit.cover,
                    placeholder: const Center(
                      child: Icon(
                        LucideIcons.user,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              artist.name,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14.ts),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
