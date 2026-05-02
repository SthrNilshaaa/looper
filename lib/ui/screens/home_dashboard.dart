import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:one_player/features/library/domain/models/models.dart';
import 'package:one_player/features/library/presentation/library_notifier.dart';
import 'package:one_player/features/playback/presentation/playback_notifier.dart';
import 'package:one_player/core/navigation_provider.dart';
import 'package:one_player/core/db_service.dart';
import 'package:isar/isar.dart';

import 'package:file_picker/file_picker.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 600;
        final bool isMedium = constraints.maxWidth < 1000;
        final bool showLogo = constraints.maxWidth < 800;
        
        return ListView(
          padding: EdgeInsets.all(isNarrow ? 16 : 32),
          children: [
            if (showLogo)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/music_icon.svg',
                              height: 40,
                            ),
                            const SizedBox(width: 5),
                            SvgPicture.asset(
                              'assets/logo_text_icon.svg',
                              height: 40,
                            ),
                          ],
                        ),
                      ),
                        SizedBox(height: 16),
                    ],
                  ),
                
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                Text(
                  'Welcome Back', 
                  style: TextStyle(
                    fontSize: isNarrow ? 24 : 32, 
                    fontWeight: FontWeight.bold
                  )
                ),
                TextButton.icon(
                  onPressed: () async {
                    final String? path = await FilePicker.platform.getDirectoryPath();
                    if (path != null) {
                      ref.read(libraryProvider.notifier).scanLibrary(path);
                    }
                  },
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: Text(isNarrow ? 'Add' : 'Add Folder'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: isNarrow ? 8 : 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

             _buildQuickPicks(ref, isNarrow, isMedium),
            const SizedBox(height: 48),
            
            _buildRecentlyPlayed(ref, isNarrow),
            const SizedBox(height: 48),
            
            _buildTopArtists(ref, isNarrow),
          ],
        );
      },
    );
  }

  Widget _buildRecentlyPlayed(WidgetRef ref, bool isNarrow) {
    final recentSongs = ref.watch(libraryProvider).songs
        .where((s) => s.lastPlayed != null)
        .toList()
      ..sort((a, b) => b.lastPlayed!.compareTo(a.lastPlayed!));
      
    if (recentSongs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Played', 
          style: TextStyle(fontSize: isNarrow ? 18 : 20, fontWeight: FontWeight.bold)
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isNarrow ? 180 : 200,
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
                          color: Colors.grey.withOpacity(0.1),
                        ),
                        child: (song.artPath == null || !File(song.artPath!).existsSync()) 
                          ? const Center(child: Icon(LucideIcons.music)) 
                          : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildQuickPicks(WidgetRef ref, bool isNarrow, bool isMedium) {
    final songs = ref.watch(libraryProvider).songs.take(6).toList();
    if (songs.isEmpty) return const SizedBox.shrink();

    int crossAxisCount = 4;
    if (isNarrow) crossAxisCount = 1;
    else if (isMedium) crossAxisCount = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Picks', 
          style: TextStyle(fontSize: isNarrow ? 18 : 20, fontWeight: FontWeight.bold)
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
            return InkWell(
              onTap: () => ref.read(playbackProvider.notifier).play(song),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
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
                          Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildTopArtists(WidgetRef ref, bool isNarrow) {
    // This would ideally be based on play count
    final artists = ref.watch(libraryProvider).songs.map((s) => s.artist).whereType<String>().toSet().take(10).toList();
    if (artists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Artists', 
          style: TextStyle(fontSize: isNarrow ? 18 : 20, fontWeight: FontWeight.bold)
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
