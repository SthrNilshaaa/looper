import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:looper_player/core/navigation_provider.dart';
import 'package:looper_player/ui/screens/android/song_info_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';
import 'widgets/premium_section.dart';
import 'widgets/song_details_bottom_sheet.dart';


class AndroidHomeTab extends ConsumerStatefulWidget {
  const AndroidHomeTab({super.key});

  @override
  ConsumerState<AndroidHomeTab> createState() => _AndroidHomeTabState();
}

class _AndroidHomeTabState extends ConsumerState<AndroidHomeTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  int _currentQuickPickPage = 0;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.listOrdered, color: Colors.white),
                title: const Text('Add to Queue', style: TextStyle(color: Colors.white)),
                onTap: () {
                  ref.read(playbackProvider.notifier).addToQueue(song);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  song.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: song.isFavorite ? Colors.red : Colors.white,
                ),
                title: Text(
                  song.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  ref.read(libraryProvider.notifier).toggleFavorite(song);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.info, color: Colors.white),
                title: const Text('Song Details', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => SongDetailsBottomSheet(song: song),
                  );
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.activity, color: Colors.white),
                title: const Text('Technical Info & Frequency', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SongInfoScreen(song: song),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.share2, color: Colors.white),
                title: const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () {
                  ref.read(playbackProvider.notifier).shareSong(song);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryProvider);
    final playbackState = ref.watch(playbackProvider);

    // Sort songs for Quick Picks (most played)
    final allSongs = List<Song>.from(library.songs);
    allSongs.sort((a, b) => b.playCount.compareTo(a.playCount));
    // Provide up to 18 songs for 3 pages of 6 items each
    final allQuickPicks = allSongs.take(18).toList();

    // Sort songs by date added (newest first)
    final dateAddedSongs = List<Song>.from(library.songs);
    dateAddedSongs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PremiumSection(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      width: 44,
                      height: 44,
                      useExpanded: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(appNavigationProvider.notifier).setItem(NavItem.search);
                      },
                      child: const Icon(
                        LucideIcons.search,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PremiumSection(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      width: 44,
                      height: 44,
                      useExpanded: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(appNavigationProvider.notifier).setItem(NavItem.settings);
                      },
                      child: const Icon(
                        LucideIcons.settings,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Picks Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Picks',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Today Mix for you',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    PremiumSection(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      height: 40,
                      useExpanded: false,
                      onTap: () {
                        if (allQuickPicks.isNotEmpty) {
                          HapticFeedback.mediumImpact();
                          // Shuffle the quick picks for a "Random" play experience as requested
                          final shuffledPicks = List<Song>.from(allQuickPicks)..shuffle();
                          ref
                              .read(playbackProvider.notifier)
                              .setPlaylist(shuffledPicks, initialIndex: 0);
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.shuffle, size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Play',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Picks Grid (PageView)
            SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth =
                      (constraints.maxWidth - 32).clamp(0.0, double.infinity);
                  final itemWidth =
                      ((availableWidth - 16) / 3).clamp(0.0, double.infinity);
                  final gridHeight =
                      ((itemWidth * 2) + 8).clamp(8.0, double.infinity);

                  final pageCount = (allQuickPicks.length / 6).ceil();
                  final validPageCount = pageCount == 0 ? 1 : pageCount;

                  return Column(
                    children: [
                      SizedBox(
                        height: gridHeight,
                        child: PageView.builder(
                          onPageChanged: (index) {
                            setState(() {
                              _currentQuickPickPage = index;
                            });
                          },
                          itemCount: validPageCount,
                          itemBuilder: (context, pageIndex) {
                            final startIndex = pageIndex * 6;
                            if (startIndex >= allQuickPicks.length &&
                                allQuickPicks.isNotEmpty) {
                              return const SizedBox();
                            }

                            final pageItems = allQuickPicks
                                .skip(startIndex)
                                .take(6)
                                .toList();

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1.0,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                itemCount: pageItems.length,
                                itemBuilder: (context, index) {
                                  final song = pageItems[index];
                                  final isPlaying =
                                      playbackState.currentSong?.id == song.id;

                                  return GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(playbackProvider.notifier)
                                          .setPlaylist(
                                            allQuickPicks,
                                            initialIndex: startIndex + index,
                                          );
                                    },
                                    onLongPress: () {
                                      HapticFeedback.mediumImpact();
                                      _showSongOptions(context, song);
                                    },
                                    child: Stack(
                                      children: [
                                        // Image
                                        Positioned.fill(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: OptimizedImage(
                                              imagePath: song.artPath,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        // Gradient overlay for text readability
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withAlpha(204),
                                                ],
                                                stops: const [0.5, 1.0],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Text
                                        Positioned(
                                          left: 8,
                                          bottom: 8,
                                          right: 8,
                                          child: Text(
                                            song.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Playing indicator overlay
                                        if (isPlaying && playbackState.isPlaying)
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.5),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/android_icons/Playing.gif',
                                                  width: 32,
                                                  height: 32,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(validPageCount, (index) {
                          final isActive = _currentQuickPickPage == index;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: isActive ? 16 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? Colors.white : Colors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Songs Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Songs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PremiumSection(
                      borderRadius: BorderRadius.circular(20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      height: 40,
                      useExpanded: false,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(appNavigationProvider.notifier).setItem(NavItem.songs);
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(LucideIcons.arrowRight, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Songs List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = dateAddedSongs[index];
                  final isCurrent = playbackState.currentSong?.id == song.id;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: [
                          OptimizedImage(
                            imagePath: song.artPath,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                          if (isCurrent && playbackState.isPlaying)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.4),
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
                        ],
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: TextStyle(
                        color: isCurrent ? Theme.of(context).colorScheme.primary : Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      song.artist ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        _showSongOptions(context, song);
                      },
                    ),
                    onTap: () {
                      ref
                          .read(playbackProvider.notifier)
                          .setPlaylist(dateAddedSongs, initialIndex: index);
                    },
                  );
                },
                childCount: dateAddedSongs.length > 10
                    ? 10
                    : dateAddedSongs.length,
              ),
            ),

            // if (dateAddedSongs.length > 10)
            //   SliverToBoxAdapter(
            //     child: Padding(
            //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            //       child: Center(
            //         child: TextButton.icon(
            //           onPressed: () {
            //             ref.read(appNavigationProvider.notifier).setItem(NavItem.songs);
            //           },
            //           icon: const Icon(LucideIcons.chevronRight, size: 16),
            //           label: const Text('View All'),
            //           style: TextButton.styleFrom(
            //             foregroundColor: Theme.of(context).colorScheme.primary,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),

            // Artists Row
            if (library.artists.isNotEmpty) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text(
                    'Artists',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: library.artists.length,
                    itemBuilder: (context, index) {
                      final artist = library.artists[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            final artistSongs = library.songs
                                .where((s) => s.artist == artist.name)
                                .toList();
                            final isLocalImage = artist.artistImageUrl != null && !artist.artistImageUrl!.startsWith('http');
                            final isNetworkImage = artist.artistImageUrl != null && artist.artistImageUrl!.startsWith('http');

                            ref.read(appNavigationProvider.notifier).showCollection(
                                  title: artist.name,
                                  subtitle: '${artistSongs.length} Songs',
                                  art: isLocalImage ? artist.artistImageUrl : (artist.artPath ?? (artistSongs.isNotEmpty ? artistSongs.first.artPath : null)),
                                  imageUrl: isNetworkImage ? artist.artistImageUrl : null,
                                  songs: artistSongs,
                                );
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context).colorScheme.surfaceContainer,
                                ),
                                child: Hero(
                                  tag: 'collection_${artist.name}',
                                  child: OptimizedImage(
                                    imagePath: artist.artistImageUrl != null && !artist.artistImageUrl!.startsWith('http')
                                        ? artist.artistImageUrl
                                        : null,
                                    imageUrl: artist.artistImageUrl != null && artist.artistImageUrl!.startsWith('http')
                                        ? artist.artistImageUrl
                                        : null,
                                    width: 90,
                                    height: 90,
                                    borderRadius: BorderRadius.circular(45),
                                    placeholder: const Icon(LucideIcons.user, color: Colors.white24, size: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  artist.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Bottom padding to clear Mini Player
            const SliverToBoxAdapter(child: SizedBox(height: 200)),
          ],
        ),
      ),
    );
  }
}
