import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:looper_player/features/library/presentation/library_notifier.dart';
import 'package:looper_player/features/playback/presentation/playback_notifier.dart';
import 'package:looper_player/features/library/domain/models/models.dart';
import 'package:looper_player/ui/widgets/optimized_image.dart';

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
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RotationTransition(
                            turns: _spinController,
                            child: const Icon(
                              LucideIcons.disc,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            LucideIcons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Search is on another tab
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            LucideIcons.settings,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            // Settings
                          },
                        ),
                      ],
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
                    const Text(
                      'Quick Picks',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (allQuickPicks.isNotEmpty) {
                          ref
                              .read(playbackProvider.notifier)
                              .setPlaylist(allQuickPicks, initialIndex: 0);
                        }
                      },
                      icon: const Icon(LucideIcons.shuffle, size: 16),
                      label: const Text('Play'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                      constraints.maxWidth - 32; // 16 padding on each side
                  final itemWidth =
                      (availableWidth - 16) /
                      3; // 8px spacing between 3 items = 16px total spacing
                  final gridHeight =
                      (itemWidth * 2) + 8; // 2 rows + 8px spacing

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
                                        if (isPlaying)
                                          const Positioned(
                                            left: 20,
                                            bottom:
                                                30, // Positioned somewhere visible, or at center
                                            child: Icon(
                                              LucideIcons.barChart2,
                                              color: Colors.white,
                                              size: 32,
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
                    TextButton(
                      onPressed: () {
                        // View all
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF2C2C2C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View All'),
                          SizedBox(width: 4),
                          Icon(LucideIcons.arrowRight, size: 16),
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

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: OptimizedImage(
                        imagePath: song.artPath,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      song.artist ?? 'Unknown',
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                      onPressed: () {
                        // Options menu
                      },
                    ),
                    onTap: () {
                      ref
                          .read(playbackProvider.notifier)
                          .setPlaylist(dateAddedSongs, initialIndex: index);
                    },
                  );
                },
                childCount: dateAddedSongs.length > 20
                    ? 20
                    : dateAddedSongs.length,
              ),
            ),

            // Bottom padding to clear Mini Player
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
