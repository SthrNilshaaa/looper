import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'package:flutter_svg/svg.dart';
import 'package:looper_player/features/library/presentation/library_grids.dart';
import 'package:looper_player/features/settings/presentation/settings_notifier.dart';
import 'package:looper_player/ui/widgets/color_maper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/core/db_service.dart';
import 'package:isar/isar.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final bool isDynamic = settings.enableDynamicTheming;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 600;
        final bool isMedium = constraints.maxWidth < 1000;
        final bool showLogo = MediaQuery.of(context).size.width < 800;

        return ListView(
          padding: EdgeInsets.only(
            top: isNarrow ? 4 : 8,
            left: isNarrow ? 16 : 32,
            right: isNarrow ? 16 : 32,
          ),
          children: [
            if (showLogo)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 50,
                    child: SvgPicture.asset(
                      'assets/main_logo.svg',
                      fit: BoxFit.contain,
                      colorMapper: AccentColorMapper(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //      Text(
            //       'Welcome Back',
            //       style: TextStyle(
            //         fontSize: isNarrow ? 24 : 32,
            //         fontWeight: FontWeight.w400
            //       )
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 16),
            _buildQuickPicks(ref, isNarrow, isMedium, isDynamic),
            const SizedBox(height: 16),

            _buildRecentlyPlayed(ref, isNarrow, isDynamic),

            //const SizedBox(height: 16),
            _buildAlbumsIfSmall(ref, isNarrow, isDynamic),
            const SizedBox(height: 16),

            _buildTopArtists(ref, isNarrow, isDynamic),
          ],
        );
      },
    );
  }

  Widget _buildAlbumsIfSmall(WidgetRef ref, bool isNarrow, bool isDynamic) {
    final albums = ref.watch(albumsProvider).value ?? [];
    if (albums.length >= 6 || albums.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Albums',
          style: TextStyle(
            fontSize: isNarrow ? 14 : 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 200 : 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () async {
                    final songs = await DbService.isar.songs
                        .filter()
                        .albumEqualTo(album.name)
                        .findAll();
                    ref.read(appNavigationProvider.notifier).showCollection(
                          title: album.name,
                          subtitle: album.artist,
                          art: album.artPath,
                          songs: songs,
                        );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: isNarrow ? 120 : 140,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OptimizedImage(
                          imagePath: album.artPath,
                          height: isNarrow ? 104 : 124,
                          width: isNarrow ? 104 : 124,
                          borderRadius: BorderRadius.circular(12),
                          placeholder: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(
                                isDynamic ? 0.8 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Icon(LucideIcons.disc)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          album.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          album.artist ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyPlayed(WidgetRef ref, bool isNarrow, bool isDynamic) {
    final recentSongs = ref.watch(recentlyPlayedProvider).value ?? [];

    if (recentSongs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Played',
          style: TextStyle(
            fontSize: isNarrow ? 14 : 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 200 : 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentSongs.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final song = recentSongs[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => ref.read(playbackProvider.notifier).play(song),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: isNarrow ? 120 : 140,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OptimizedImage(
                          imagePath: song.artPath,
                          height: isNarrow ? 104 : 124,
                          width: isNarrow ? 104 : 124,
                          borderRadius: BorderRadius.circular(12),
                          placeholder: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(
                                isDynamic ? 0.8 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: Icon(LucideIcons.music)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          song.artist ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPicks(
    WidgetRef ref,
    bool isNarrow,
    bool isMedium,
    bool isDynamic,
  ) {
    final topSongsAsync = ref.watch(topSongsProvider);

    return topSongsAsync.when(
      data: (songs) {
        if (songs.isEmpty) return const SizedBox.shrink();

        int crossAxisCount = 4;
        if (isNarrow) {
          crossAxisCount = 2;
        } else if (isMedium) {
          crossAxisCount = 3;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Picks',
              style: TextStyle(
                fontSize: isNarrow ? 14 : 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 70,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final isCurrent =
                    ref.watch(playbackProvider).currentSong?.id == song.id;

                return InkWell(
                  onTap: () => ref.read(playbackProvider.notifier).play(song),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                          : Colors.white.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        OptimizedImage(
                          imagePath: song.artPath,
                          width: 54,
                          height: 54,
                          borderRadius: BorderRadius.circular(4),
                          placeholder: const Icon(LucideIcons.music, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                song.artist ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
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
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildTopArtists(WidgetRef ref, bool isNarrow, bool isDynamic) {
    final artistsAsync = ref.watch(artistsProvider);

    return artistsAsync.when(
      data: (artists) {
        if (artists.isEmpty) return const SizedBox.shrink();

        // Take a slice for featured artists
        final featuredArtists = artists.take(10).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Artists',
              style: TextStyle(
                fontSize: isNarrow ? 14 : 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: isNarrow ? 110 : 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredArtists.length,
                itemBuilder: (context, index) {
                  final artist = featuredArtists[index];
                  return _FeaturedArtistCard(
                    artist: artist,
                    isNarrow: isNarrow,
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FeaturedArtistCard extends ConsumerWidget {
  final Artist artist;
  final bool isNarrow;

  const _FeaturedArtistCard({
    required this.artist,
    required this.isNarrow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () async {
          final artistSongs = await DbService.isar.songs
              .filter()
              .artistEqualTo(artist.name)
              .findAll();
          ref.read(appNavigationProvider.notifier).showCollection(
                title: artist.name,
                subtitle: 'Artist',
                art: artist.artPath,
                imageUrl: artist.artistImageUrl,
                songs: artistSongs,
              );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: isNarrow ? 80 : 100,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Container(
                width: isNarrow ? 64 : 80,
                height: isNarrow ? 64 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: OptimizedImage(
                    imageUrl: artist.artistImageUrl,
                    imagePath: artist.artPath,
                    fit: BoxFit.cover,
                    placeholder: Container(
                      color: Colors.grey.withOpacity(0.1),
                      child: const Icon(LucideIcons.user, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                artist.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
