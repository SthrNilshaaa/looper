import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

import 'package:file_picker/file_picker.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    final settings = ref.watch(settingsProvider);
    final bool isDynamic = settings.enableDynamicTheming;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 600;
        final bool isMedium = constraints.maxWidth < 1000;
        final bool showLogo = MediaQuery.of(context).size.width < 800;
        
        return ListView(
          padding: EdgeInsets.only(top:isNarrow ? 4 : 8,left:isNarrow ? 16 : 32,right:isNarrow ? 16 : 32),
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
                           colorMapper: AccentColorMapper(Theme.of(context).colorScheme.primary),
                          
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
          style: TextStyle(fontSize: isNarrow ? 14 : 18, fontWeight: FontWeight.w400)
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 190 : 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return Container(
                width: isNarrow ? 120 : 140,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        final songs = await DbService.isar.songs.filter().albumEqualTo(album.name).findAll();
                        ref.read(appNavigationProvider.notifier).showCollection(
                          title: album.name,
                          subtitle: album.artist,
                          art: album.artPath,
                          songs: songs,
                        );
                      },
                      child: Container(
                        height: isNarrow ? 120 : 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: (album.artPath != null && File(album.artPath!).existsSync())
                            ? DecorationImage(image: FileImage(File(album.artPath!)), fit: BoxFit.cover)
                            : null,
                          color: Colors.grey.withOpacity(isDynamic ? 0.8 : 0.1),
                        ),
                        child: (album.artPath == null || !File(album.artPath!).existsSync()) 
                          ? const Center(child: Icon(LucideIcons.disc)) 
                          : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(album.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.normal)),
                    Text(album.artist ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
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
          style: TextStyle(fontSize: isNarrow ? 14 : 18, fontWeight: FontWeight.w400)
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 190 : 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recentSongs.length.clamp(0, 10),
            itemBuilder: (context, index) {
              final song = recentSongs[index];
              return Container(
                width: isNarrow ? 120 : 140,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => ref.read(playbackProvider.notifier).play(song),
                      child: Container(
                        height: isNarrow ? 120 : 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: (song.artPath != null && File(song.artPath!).existsSync())
                            ? DecorationImage(image: FileImage(File(song.artPath!)), fit: BoxFit.cover)
                            : null,
                          color: Colors.grey.withOpacity(isDynamic ? 0.8 : 0.1),
                        ),
                        child: (song.artPath == null || !File(song.artPath!).existsSync()) 
                          ? const Center(child: Icon(LucideIcons.music)) 
                          : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.normal)),
                    Text(song.artist ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPicks(WidgetRef ref, bool isNarrow, bool isMedium, bool isDynamic) {
    final songs = ref.watch(libraryProvider).songs.take(6).toList();
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
          style: TextStyle(fontSize: isNarrow ? 14 : 18, fontWeight: FontWeight.w400)
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
            final isCurrent = ref.watch(playbackProvider).currentSong?.id == song.id;
            
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
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: (song.artPath != null && File(song.artPath!).existsSync())
                          ? DecorationImage(image: FileImage(File(song.artPath!)), fit: BoxFit.cover)
                          : null,
                      ),
                      child: (song.artPath == null || !File(song.artPath!).existsSync()) 
                        ? const Icon(LucideIcons.music, size: 20) 
                        : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13)),
                          Text(song.artist ?? 'Unknown', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
  }

  Widget _buildTopArtists(WidgetRef ref, bool isNarrow, bool isDynamic) {
    // This would ideally be based on play count
    final artists = ref.watch(libraryProvider).songs.map((s) => s.artist).whereType<String>().toSet().take(10).toList();
    if (artists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Artists', 
          style: TextStyle(fontSize: isNarrow ? 14 : 18, fontWeight: FontWeight.w400)
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 110 : 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artistName = artists[index];
              return InkWell(
                onTap: () {
                  final artistSongs = ref.read(libraryProvider).songs
                      .where((s) => s.artist == artistName)
                      .toList();
                  ref.read(appNavigationProvider.notifier).showCollection(
                    title: artistName,
                    subtitle: 'Artist',
                    songs: artistSongs,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: isNarrow ? 80 : 100,
                  margin: const EdgeInsets.only(right: 24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: isNarrow ? 32 : 40,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        child: const Icon(LucideIcons.user),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artistName,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
